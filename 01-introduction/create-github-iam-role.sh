#!/bin/bash

# Script to create IAM role for GitHub Actions OIDC authentication
# Requires: AWS CLI configured with admin credentials
# Can be run locally or from GitHub Actions

set -e

# Load environment variables from file if running locally
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/env.local"

if [ -f "$ENV_FILE" ]; then
    echo "📄 Loading configuration from env.local..."
    source "$ENV_FILE"
fi

# Validate required variables
if [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ] || [ -z "$AWS_REGION" ] || [ -z "$TF_STATE_BUCKET" ]; then
    echo "❌ Error: Required environment variables not set"
    echo "Please configure GITHUB_ORG, GITHUB_REPO, AWS_REGION, and TF_STATE_BUCKET"
    exit 1
fi

ROLE_NAME="${IAM_ROLE_NAME:-GitHubActionsRole-ssh-tips}"
POLICY_NAME="${IAM_POLICY_NAME:-GitHubActionsPolicy-ssh-tips}"

echo "🚀 Creating IAM role for GitHub Actions OIDC..."
echo "   GitHub Repo: $GITHUB_ORG/$GITHUB_REPO"
echo "   Role Name: $ROLE_NAME"
echo ""

# Create OIDC provider if it doesn't exist
OIDC_PROVIDER_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, 'token.actions.githubusercontent.com')].Arn" --output text)

if [ -z "$OIDC_PROVIDER_ARN" ]; then
    echo "📋 Creating GitHub OIDC provider..."
    
    OIDC_PROVIDER_ARN=$(aws iam create-open-id-connect-provider \
        --url https://token.actions.githubusercontent.com \
        --client-id-list sts.amazonaws.com \
        # NOTE: The following thumbprint is GitHub's current OIDC root CA thumbprint as of June 2024.
        # If GitHub rotates their certificates, this value will change.
        # Always verify the latest thumbprint at:
        # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#updating-the-thumbprint
        --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
        --query 'OpenIDConnectProviderArn' \
        --output text)
    
    echo "✅ OIDC provider created: $OIDC_PROVIDER_ARN"
else
    echo "✅ OIDC provider already exists: $OIDC_PROVIDER_ARN"
fi

# Create trust policy
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "$OIDC_PROVIDER_ARN"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:$GITHUB_ORG/$GITHUB_REPO:*"
        }
      }
    }
  ]
}
EOF
)

# Create IAM role
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo "✅ IAM role $ROLE_NAME already exists"
    
    echo "🔄 Updating trust policy..."
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    aws iam update-assume-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-document file:///tmp/trust-policy.json
    rm /tmp/trust-policy.json
else
    echo "👤 Creating IAM role..."
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --description "Role for GitHub Actions to manage SSH Tips infrastructure"
    
    rm /tmp/trust-policy.json
    echo "✅ IAM role created"
fi

# Create IAM policy for permissions
POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformStateAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${TF_STATE_BUCKET}",
        "arn:aws:s3:::${TF_STATE_BUCKET}/*"
      ]
    },
    {
      "Sid": "EC2FullAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VPCAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeRouteTables",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMReadAccess",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:GetUser",
        "iam:GetInstanceProfile",
        "iam:ListAttachedRolePolicies"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:DeleteSecret",
        "secretsmanager:TagResource"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:ssh-tips/*"
    },
    {
      "Sid": "RDSAccess",
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:DescribeDBInstances",
        "rds:ModifyDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBSubnetGroups",
        "rds:AddTagsToResource",
        "rds:ListTagsForResource",
        "rds:RemoveTagsFromResource"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)

# Check if policy exists
EXISTING_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

if [ -z "$EXISTING_POLICY_ARN" ]; then
    echo "📜 Creating IAM policy..."
    echo "$POLICY_DOCUMENT" > /tmp/policy.json
    
    POLICY_ARN=$(aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document file:///tmp/policy.json \
        --description "Policy for GitHub Actions to manage SSH Tips infrastructure" \
        --query 'Policy.Arn' \
        --output text)
    
    rm /tmp/policy.json
    echo "✅ IAM policy created: $POLICY_ARN"
else
    echo "📜 Updating existing IAM policy..."
    POLICY_ARN=$EXISTING_POLICY_ARN
    
    # Delete old policy versions if at limit (AWS allows max 5 versions)
    OLD_VERSIONS=$(aws iam list-policy-versions \
        --policy-arn "$POLICY_ARN" \
        --query 'Versions[?!IsDefaultVersion].VersionId' \
        --output text)
    
    for VERSION in $OLD_VERSIONS; do
        echo "   Deleting old policy version: $VERSION"
        aws iam delete-policy-version \
            --policy-arn "$POLICY_ARN" \
            --version-id "$VERSION" 2>/dev/null || true
    done
    
    # Create new policy version
    echo "$POLICY_DOCUMENT" > /tmp/policy.json
    aws iam create-policy-version \
        --policy-arn "$POLICY_ARN" \
        --policy-document file:///tmp/policy.json \
        --set-as-default
    
    rm /tmp/policy.json
    echo "✅ IAM policy updated with new permissions"
fi

# Attach policy to role
echo "🔗 Attaching policy to role..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$POLICY_ARN" 2>/dev/null || echo "   (Policy already attached)"

# Get role ARN
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

echo ""
echo "✅ GitHub Actions IAM role configured successfully!"
echo ""

# Store secrets in AWS Secrets Manager
echo "💾 Storing configuration in AWS Secrets Manager..."

SECRET_NAME="ssh-tips/github-actions-config"

SECRET_VALUE=$(cat <<EOF
{
  "AWS_ROLE_ARN": "$ROLE_ARN",
  "TF_STATE_BUCKET": "$TF_STATE_BUCKET",
  "AWS_REGION": "$AWS_REGION"
}
EOF
)

# Check if secret exists
if aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --region "$AWS_REGION" 2>/dev/null; then
    echo "🔄 Updating existing secret..."
    aws secretsmanager put-secret-value \
        --secret-id "$SECRET_NAME" \
        --secret-string "$SECRET_VALUE" \
        --region "$AWS_REGION" > /dev/null
else
    echo "📝 Creating new secret..."
    aws secretsmanager create-secret \
        --name "$SECRET_NAME" \
        --description "GitHub Actions configuration for SSH Tips project" \
        --secret-string "$SECRET_VALUE" \
        --region "$AWS_REGION" > /dev/null
fi

echo "✅ Configuration stored in AWS Secrets Manager: $SECRET_NAME"
echo ""
echo "AWS_ROLE_ARN=$ROLE_ARN"
echo "TF_STATE_BUCKET=$TF_STATE_BUCKET"
echo "AWS_SECRETS_MANAGER_NAME=$SECRET_NAME"
echo ""

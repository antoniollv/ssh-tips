# Terraform State Backend

This directory uses an S3 backend for storing Terraform state.

## Prerequisites

Before running Terraform, you must create an S3 bucket for state storage.

### Create S3 Bucket (One-time setup)

**Via AWS Console:**

1. Go to AWS S3 Console
2. Create bucket with these settings:
   - **Bucket name:** `your-terraform-state-bucket` (choose a unique name)
   - **Region:** `us-east-1` (or your preferred region)
   - **Block all public access:** ✅ Enabled
   - **Versioning:** ✅ Enabled (recommended)
   - **Encryption:** ✅ SSE-S3 or SSE-KMS

**Via AWS CLI:**

```bash
# Set your bucket name
BUCKET_NAME="your-terraform-state-bucket"
AWS_REGION="us-east-1"

# Create bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $AWS_REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

## Local Development

### Initialize Terraform with backend configuration

```bash
cd 02-reverse-tunnel/terraform

terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=ssh-tips/02-reverse-tunnel/terraform.tfstate" \
  -backend-config="region=eu-west-1"
```

### Plan and Apply

```bash
# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy
```

## GitHub Actions

The workflow `.github/workflows/02-reverse-tunnel.yml` automatically configures the backend using secrets:

**Required Secrets:**

- `TF_STATE_BUCKET`: S3 bucket name for Terraform state
- `AWS_ROLE_ARN`: IAM role ARN for GitHub Actions OIDC
- `SSH_PUBLIC_KEY`: Default SSH public key for EC2 access

**To run the workflow:**

1. Go to GitHub Actions tab
2. Select "Deploy Case 1 - Reverse SSH Tunnel Infrastructure"
3. Click "Run workflow"
4. Choose action: `apply` or `destroy`
5. (Optional) Provide SSH public key

## Notes

- The S3 bucket is shared across all cases in this presentation
- State file path: `ssh-tips/02-reverse-tunnel/terraform.tfstate`
- This is one of the few infrastructure prerequisites for the presentation

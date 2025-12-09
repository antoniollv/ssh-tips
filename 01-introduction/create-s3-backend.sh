#!/bin/bash

# Script to create S3 bucket for Terraform state backend
# Requires: AWS CLI configured with appropriate credentials
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
if [ -z "$TF_STATE_BUCKET" ] || [ -z "$AWS_REGION" ]; then
    echo "❌ Error: Required environment variables not set"
    echo "Please configure TF_STATE_BUCKET and AWS_REGION"
    exit 1
fi

echo "🚀 Creating S3 bucket for Terraform state backend..."
echo "   Bucket: $TF_STATE_BUCKET"
echo "   Region: $AWS_REGION"
echo ""

# Check if bucket already exists
if aws s3api head-bucket --bucket "$TF_STATE_BUCKET" 2>/dev/null; then
    echo "✅ Bucket $TF_STATE_BUCKET already exists"
else
    echo "📦 Creating bucket..."
    
    # Create bucket (different command for us-east-1)
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$TF_STATE_BUCKET" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$TF_STATE_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    
    echo "✅ Bucket created"
fi

# Enable versioning
echo "🔄 Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$TF_STATE_BUCKET" \
    --versioning-configuration Status=Enabled

# Block public access
echo "🔒 Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$TF_STATE_BUCKET" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Enable encryption
echo "🔐 Enabling encryption..."
aws s3api put-bucket-encryption \
    --bucket "$TF_STATE_BUCKET" \
    --server-side-encryption-configuration \
        '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

echo ""
echo "✅ S3 backend configured successfully!"
echo ""
echo "📋 Bucket details:"
echo "   Name: $TF_STATE_BUCKET"
echo "   Region: $AWS_REGION"
echo ""

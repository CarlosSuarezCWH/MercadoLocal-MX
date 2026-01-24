#!/bin/bash
set -e

# Configuration
PROJECT_NAME="mercadolocal"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="${PROJECT_NAME}-tfstate-${ACCOUNT_ID}"
TABLE_NAME="${PROJECT_NAME}-tf-lock"

echo "Using AWS Account: $ACCOUNT_ID"
echo "Creating Bucket: $BUCKET_NAME"
echo "Creating DynamoDB Table: $TABLE_NAME"

# 1. Create S3 Bucket
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    echo "Bucket created."
else
    echo "Bucket already exists."
fi

# Enable Versioning
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
echo "Versioning enabled."

# Encrypt Bucket
aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
echo "Encryption enabled."

# 2. Create DynamoDB Table
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo "Table already exists."
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION"
    echo "DynamoDB Table created."
fi

echo ""
echo "----------------------------------------------------------------"
echo "Backend Setup Complete!"
echo "----------------------------------------------------------------"
echo "Update your backend.tf with the following:"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    dynamodb_table = \"$TABLE_NAME\""
echo "    encrypt        = true"
echo "  }"
echo "}"
echo "----------------------------------------------------------------"

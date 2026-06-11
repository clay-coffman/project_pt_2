#!/usr/bin/env bash
# One-time: create the S3 bucket that holds Terraform state. The name has to
# match terraform/backend.tf. S3 names are global, so change both if it's taken.
set -euo pipefail

BUCKET="cs312-mc-tfstate-coffmacl"
REGION="us-east-1"

if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "bucket $BUCKET already exists"
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET" \
    --versioning-configuration Status=Enabled
  echo "created $BUCKET"
fi

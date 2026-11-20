#!/usr/bin/env bash
# One-time setup: lets Vault issue short-lived, least-privilege AWS keys for Terraform.
set -euo pipefail

: "${VAULT_ADDR:?Set VAULT_ADDR}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Vault uses your AWS CLI keys ONCE so it can create temporary IAM users.
AK="$(aws configure get aws_access_key_id)"
SK="$(aws configure get aws_secret_access_key)"

echo "==> Enabling the AWS secrets engine"
vault secrets enable -path=aws aws 2>/dev/null || echo "    (already enabled)"

echo "==> Giving Vault permission to create temporary AWS users"
vault write aws/config/root access_key="$AK" secret_key="$SK" region="$AWS_REGION"

echo "==> Keys expire after 15 minutes (30 max)"
vault write aws/config/lease lease=15m lease_max=30m

echo "==> Guardrail role: EC2/VPC + S3 only, ${AWS_REGION} only"
POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Ec2AndVpcInOneRegion",
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": { "StringEquals": { "aws:RequestedRegion": "${AWS_REGION}" } }
    },
    {
      "Sid": "S3",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
)
vault write aws/roles/terraform-deployer credential_type=iam_user policy_document=@terraform-deployer-policy.json

echo "==> Test: requesting one set of temporary keys"
vault read aws/creds/terraform-deployer

echo
echo "Done. Wait ~10 seconds, then run: terraform init -upgrade && terraform plan"

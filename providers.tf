terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0"
    }
  }
}

# Vault provider reads VAULT_ADDR and VAULT_TOKEN from your terminal environment.
provider "vault" {}

# Ask Vault for temporary AWS keys (15-minute lifetime, EC2/VPC/S3 only).
data "vault_aws_access_credentials" "deployer" {
  backend = "aws"
  role    = "terraform-deployer"
}

# Same AWS provider as before; the keys now come from Vault.
provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.deployer.access_key
  secret_key = data.vault_aws_access_credentials.deployer.secret_key

  default_tags {
    tags = {
      Project          = "terraform-aws-webserver"
      ManagedBy        = "Terraform"
      CredentialSource = "Vault"
    }
  }
}

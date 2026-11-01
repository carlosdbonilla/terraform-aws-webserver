# Terraform AWS Web Server

Provisions an Apache web server on AWS EC2 using Terraform. This is a hands-on Infrastructure as Code (IaC) project covering the full Terraform lifecycle: `init` → `plan` → `apply` → `destroy`.

## Architecture

```
Terraform (local)
   │
   ▼
AWS Provider (us-east-1)
   ├── Data source: latest Amazon Linux 2023 AMI
   ├── Security Group (web-sg): allows inbound HTTP on port 80
   └── EC2 Instance (t3.micro)
          └── user_data script installs and starts Apache
                 └── Serves a web page at http://<public_ip>
```

## Tech Used

- **Terraform**: Infrastructure as Code
- **AWS**: EC2, Security Groups, IAM, AMI data source
- **Bash**: bootstrap script via `user_data`
- **Git / GitHub**: version control

## Project Structure

| File | Purpose |
|---|---|
| `main.tf` | Provider config, AMI lookup, security group, and EC2 instance |
| `variables.tf` | Configurable inputs (region, instance type) |
| `outputs.tf` | Prints the public IP and website URL after deployment |
| `.gitignore` | Keeps state files and secrets out of version control |
| `.terraform.lock.hcl` | Pins the AWS provider version for consistent runs |

## How to Run

**Prerequisites:** Terraform, AWS CLI configured with an IAM user (`aws configure`).

```bash
terraform init       # Download the AWS provider
terraform fmt        # Format the code
terraform validate   # Check the syntax
terraform plan       # Preview changes
terraform apply      # Create the infrastructure
terraform destroy    # Tear everything down
```

## Screenshots

### Plan: previewing 2 resources to create
![terraform plan](screenshots/plan.png)

### Apply: infrastructure created
![terraform apply](screenshots/apply.png)

### Live website
![website](screenshots/website.png)

### EC2 instance running in the AWS console
![ec2 console](screenshots/ec2-console.png)

### Destroy: clean teardown
![terraform destroy](screenshots/destroy.png)

## What I Learned

- **Declarative infrastructure**: describe the desired end state, and Terraform figures out how to get there.
- **Plan before apply**: `terraform plan` previews every change before anything is touched.
- **Dependency graph**: Terraform automatically created the security group before the EC2 instance, because the instance references it.
- **State**: the `.tfstate` file is how Terraform tracks what exists. It's excluded from Git because it can contain sensitive data.
- **Data sources**: looking up the latest AMI dynamically instead of hardcoding an ID.
- **Least privilege**: Terraform runs as a dedicated IAM user with EC2-only permissions, never the root account.
- **Cost control**: `terraform destroy` removes everything cleanly, with no orphaned resources.

## Next Steps

- Store state remotely in HCP Terraform (or S3) for team collaboration and state locking
- Refactor into reusable modules
- Build a custom VPC and subnets instead of using the default VPC
- Add HTTPS with a load balancer and certificate

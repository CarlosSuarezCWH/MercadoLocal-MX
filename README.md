# WordPress High Availability on AWS (Modular Terraform)

This project deploys a scalable, highly available WordPress infrastructure on AWS using Terraform modules.

## Architecture

- **Compute**: Autoscaling Group with EC2 (Amazon Linux 2023), Nginx, PHP 8.2 FPM.
- **Database**: Amazon Aurora MySQL Serverless v2.
- **Storage**: EFS (Elastic Throughput) for `/wp-content/uploads`.
- **Caching**: Amazon ElastiCache (Redis) for Object Cache.
- **Networking**: VPC across 3 AZs, ALB, NAT Gateways.
- **Security**: Strictly chained Security Groups.

## Prerequisites

- Terraform >= 1.3.0
- AWS Credentials configured
- S3 Bucket for Terraform State (update `environments/prod/backend.tf`)
- DynamoDB Table for Locking (update `environments/prod/backend.tf`)

## Directory Structure

```plaintext
├── modules/          # Reusable modules
│   ├── vpc/
│   ├── alb/
│   ├── asg/
│   ├── rds/
│   ├── efs/
│   ├── elasticache/
│   └── security/
├── environments/
│   └── prod/         # Production implementation
│       ├── main.tf
│       ├── variables.tf
│       └── ...
```

## How to Deploy

1. **Initialize**:
   ```bash
   cd environments/prod
   terraform init
   ```

2. **Plan**:
   ```bash
   terraform plan -out=tfplan
   ```

3. **Apply**:
   ```bash
   terraform apply tfplan
   ```

## Configuration

Update `environments/prod/variables.tf` or create a `terraform.tfvars` file with your specific values (DB passwords, etc.).

**Important**: The `backend.tf` file expects an existing S3 bucket. If you are deploying for the first time without a backend, comment out the `backend` block in `backend.tf`, deploy, and then migrate state.

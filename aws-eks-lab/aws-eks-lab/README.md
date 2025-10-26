# AWS EKS Lab – by Greg Roy
Professional-grade EKS environment showcasing DevOps & Terraform expertise.

### Features
- Terraform-managed EKS cluster (v19.21.0)
- Free-tier eligible t3.micro nodes
- CloudWatch integration
- Pre-provisioned Prometheus + Grafana
- S3 remote backend for state management

### Usage
```bash
cd terraform
terraform init -reconfigure
terraform validate
terraform plan
terraform apply
#LinkedIn: Greg Roy


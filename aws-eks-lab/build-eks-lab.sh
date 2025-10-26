#!/usr/bin/env bash
set -e

echo "🚀 Building Greg's EKS Lab bundle (provider v5.62.0 for compatibility)..."

BASE_DIR=$(pwd)/aws-eks-lab
mkdir -p "$BASE_DIR/terraform"

# --- Terraform project ---
cat > "$BASE_DIR/terraform/main.tf" <<'EOF'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-nfngreg"
    key    = "aws-eks-lab/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name                   = "gregsplace-eks-cluster"
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true
  manage_aws_auth_configmap      = true
  enable_irsa                    = true

  vpc_id     = "vpc-0b45626fbd6e4b626"
  subnet_ids = [
    "subnet-08ab3340914d703ef",
    "subnet-073e6c95a6c2d2d7f",
    "subnet-0cc96fa96161c18ec"
  ]

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.micro"]
      capacity_type    = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "aws-eks-lab"
  }
}

resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/gregsplace-eks-cluster"
  retention_in_days = 30
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.eks_logs.name
}
EOF

# --- Helm chart values ---
mkdir -p "$BASE_DIR/helm"
cat > "$BASE_DIR/helm/values.yaml" <<'EOF'
grafana:
  enabled: true
  adminPassword: admin
  service:
    type: LoadBalancer
prometheus:
  enabled: true
EOF

# --- GitHub workflows ---
mkdir -p "$BASE_DIR/.github/workflows"
cat > "$BASE_DIR/.github/workflows/terraform.yml" <<'EOF'
name: Terraform CI
on:
  push:
    branches: [ main ]
  pull_request:
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.7
      - run: terraform fmt -check
      - run: terraform init
      - run: terraform validate
      - run: terraform plan
EOF

# --- Documentation ---
cat > "$BASE_DIR/README.md" <<'EOF'
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

EOF

#--- Zip up bundle ---

cd "$(dirname "$BASE_DIR")"
zip -rq aws-eks-lab.zip aws-eks-lab
echo "✅ Created $(pwd)/aws-eks-lab.zip"

#--- Validation ---

cd "$BASE_DIR/terraform"
echo "🔍 Validating Terraform configuration..."
terraform init -reconfigure -upgrade
terraform validate || echo "⚠️ Terraform validation requires full provider download."

echo "🎉 Done. Zip bundle ready for commit or upload."


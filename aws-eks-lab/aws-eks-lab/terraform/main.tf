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

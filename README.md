# AWS EKS Lab

[![Latest Release](https://img.shields.io/github/v/release/groy75/aws-eks-lab?label=latest%20release&color=blue)](https://github.com/groy75/aws-eks-lab/releases)
[![Terraform](https://img.shields.io/badge/Terraform-Cloud%20Infrastructure-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS%20Cluster-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![License](https://img.shields.io/github/license/groy75/aws-eks-lab?color=lightgrey)](https://github.com/groy75/aws-eks-lab/blob/main/LICENSE)

Professional-grade AWS EKS lab project demonstrating Terraform-managed infrastructure, Helm-based monitoring, CloudWatch integration, and CI/CD workflows with Infracost.


# AWS Terraform Lab

A sandbox project to learn and test AWS infrastructure using Terraform.

## Setup

1. **Install Terraform & AWS CLI**
   ```bash
   brew install terraform awscli
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   ```

3. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

4. **Plan & Apply**
   ```bash
   terraform plan
   terraform apply -auto-approve
   ```

5. **Destroy**
   ```bash
   terraform destroy -auto-approve
   ```

This lab spins up a simple EC2 instance in your default region for practice. Safe to delete anytime — perfect for learning and teardown drills.

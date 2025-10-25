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

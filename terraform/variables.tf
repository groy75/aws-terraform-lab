variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ca-central-1"
}

variable "ami_id" {
  description = "AMI to use for the instance"
  type        = string
  default     = "ami-04a51fa97a0cbeccf" # Amazon Linux 2023 in ca-central-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

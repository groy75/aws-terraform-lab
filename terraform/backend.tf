terraform {
  backend "s3" {
    bucket = "greg-terraform-state"
    key    = "lab/terraform.tfstate"
    region = "ca-central-1"
  }
}

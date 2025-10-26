terraform {
  backend "s3" {
    bucket  = "terraform-state-nfngreg"
    key     = "lab/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

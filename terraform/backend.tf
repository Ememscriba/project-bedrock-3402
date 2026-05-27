terraform {
  backend "s3" {
    bucket  = "bedrock-terraform-state-3402"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

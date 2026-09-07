terraform {
  backend "s3" {
    bucket  = "bedrock-terraform-state-ememjohn"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

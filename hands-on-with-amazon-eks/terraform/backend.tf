terraform {
  backend "s3" {
    bucket         = "marcos-terraform-state-891377041385"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    bucket         = "marcos-terraform-state-533266962445"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

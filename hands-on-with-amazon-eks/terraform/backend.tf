terraform {
  backend "s3" {
    bucket         = "marcos-terraform-state-590184064814"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

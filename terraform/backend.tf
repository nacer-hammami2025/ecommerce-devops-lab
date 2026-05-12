terraform {
  backend "s3" {
    bucket         = "ansible-project-terraform-state-1778612108"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

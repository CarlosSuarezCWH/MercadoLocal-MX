terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-wordpress-ha-prod" # Replace with actual bucket
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

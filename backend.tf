terraform {
  backend "s3" {
    # Replace with your bucket name from setup_backend.sh
    # bucket         = "mercadolocal-tfstate-ACCOUNT_ID" 
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "mercadolocal-tf-lock"
    encrypt        = true
  }
}

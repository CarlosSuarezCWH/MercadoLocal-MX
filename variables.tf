variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "MercadoLocal"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  # In a real scenario, this should be passed securely or generated
  default     = "ChangeMe123!" 
}

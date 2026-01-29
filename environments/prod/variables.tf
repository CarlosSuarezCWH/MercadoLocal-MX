variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "wp-ha"
}

variable "environment" {
  default = "prod"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_app_subnets_cidr" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_data_subnets_cidr" {
  default = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_type" {
  default = "t3.medium"
}

variable "db_name" {
  default = "wordpressdb"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  sensitive = true
}

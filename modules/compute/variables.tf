variable "project_name" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_app_subnet_ids" {
  type = list(string)
}
variable "alb_sg_id" {}
variable "app_sg_id" {}
variable "db_password" {}
variable "db_endpoint" {}

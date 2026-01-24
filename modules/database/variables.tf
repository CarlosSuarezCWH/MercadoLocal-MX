variable "project_name" {}
variable "private_db_subnet_ids" {
  type = list(string)
}
variable "db_sg_id" {}
variable "db_password" {}

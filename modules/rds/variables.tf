variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_data_subnets" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

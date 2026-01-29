variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_data_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

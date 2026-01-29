variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "domain_name" {
  description = "Domain name for ACM and Host header (optional)"
  type        = string
  default     = ""
}

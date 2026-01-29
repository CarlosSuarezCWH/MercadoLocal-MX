variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnets_cidr" {
  description = "List of CIDR blocks for private application subnets"
  type        = list(string)
}

variable "private_data_subnets_cidr" {
  description = "List of CIDR blocks for private data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (1 for cost savings, 3 for HA)"
  type        = number
  default     = 1
}

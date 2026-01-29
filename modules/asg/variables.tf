variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_app_subnets" {
  description = "List of private subnet IDs for ASG"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "efs_id" {
  description = "EFS File System ID"
  type        = string
}

variable "db_host" {
  description = "Database Host Endpoint"
  type        = string
}

variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "db_username" {
  description = "Database Username"
  type        = string
}

variable "db_password" {
  description = "Database Password"
  type        = string
  sensitive   = true
}

variable "redis_host" {
  description = "Redis Host Endpoint"
  type        = string
}

variable "redis_port" {
  description = "Redis Port"
  type        = string
}

variable "min_size" {
  description = "Minimum size of ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of ASG"
  type        = number
  default     = 10
}

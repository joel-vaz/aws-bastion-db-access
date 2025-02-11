variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "database_sg_id" {
  description = "ID of the database security group"
  type        = string
}

variable "instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

locals {
  name_prefix = "${var.environment}-${var.project_name}-"
}

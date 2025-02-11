variable "environment" {
  description = "Environment name"
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

variable "ssm_parameter_prefix" {
  description = "SSM parameter prefix for storing database credentials"
  type        = string
  default     = "/bastion-app"
}

locals {
  name_prefix = "${var.environment}-"
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

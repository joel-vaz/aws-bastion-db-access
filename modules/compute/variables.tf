variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "bastion_sg_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "alb_sg_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "webserver_sg_id" {
  description = "ID of the web server security group"
  type        = string
}

variable "key_name" {
  description = "Name of existing EC2 key pair"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

locals {
  name_prefix = "${var.environment}-"
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

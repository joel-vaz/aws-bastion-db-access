variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

locals {
  name_prefix = "${var.environment}-${var.project_name}-"
  ssm_prefix  = "/${var.project_name}/${var.environment}"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

locals {
  name_prefix = "${var.environment}-"
  ssm_prefix  = "/bastion-app/${var.environment}"
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

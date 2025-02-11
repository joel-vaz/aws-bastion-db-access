# Get current region
data "aws_region" "current" {}

# Get current caller identity
data "aws_caller_identity" "current" {}

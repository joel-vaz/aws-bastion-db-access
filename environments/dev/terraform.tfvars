# Environment configuration
environment = "dev"
aws_region  = "us-west-2"

# Network configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]

# Instance configuration
instance_type = "t3.micro"

# SSL Certificate
# This needs to be updated with the actual certificate ARN
certificate_arn = "arn:aws:acm:REGION:ACCOUNT:certificate/CERTIFICATE-ID"

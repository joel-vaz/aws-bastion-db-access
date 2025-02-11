#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENV=$1
WORKSPACE_DIR="environments/$ENV"

echo "Validating $ENV infrastructure..."
cd "$WORKSPACE_DIR"

# Function to check resource status
check_resource() {
    local message=$1
    local command=$2

    echo -n "Checking $message... "
    if eval "$command" > /dev/null 2>&1; then
        echo "OK"
        return 0
    else
        echo "FAILED"
        return 1
    fi
}

# 1. VPC and Network
echo -e "\nNetwork Infrastructure:"
vpc_id=$(terraform output -raw vpc_id)
check_resource "VPC exists" "aws ec2 describe-vpcs --vpc-id $vpc_id"
check_resource "Subnets" "aws ec2 describe-subnets --filters \"Name=vpc-id,Values=$vpc_id\""

# 2. Bastion Host
echo -e "\nBastion Host:"
bastion_ip=$(terraform output -raw bastion_public_ip)
check_resource "Bastion IP" "ping -c 1 $bastion_ip"
check_resource "SSH port" "nc -zv $bastion_ip 22"

# 3. Load Balancer
echo -e "\nLoad Balancer:"
alb_dns=$(terraform output -raw alb_dns_name)
check_resource "ALB DNS resolution" "nslookup $alb_dns"
check_resource "HTTPS port" "nc -zv $alb_dns 443"

# 4. Auto Scaling Group
echo -e "\nAuto Scaling Group:"
asg_name=$(terraform output -raw asg_name)
check_resource "ASG instances" "aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $asg_name"

# 5. Database
echo -e "\nDatabase:"
db_endpoint=$(terraform output -raw db_endpoint)
db_host=${db_endpoint%:*}
check_resource "Database endpoint" "nc -zv $db_host 3306"

# Summary
echo -e "\nValidation Summary:"
echo "VPC ID: $vpc_id"
echo "Bastion IP: $bastion_ip"
echo "ALB DNS: $alb_dns"
echo "DB Endpoint: $db_endpoint"

# Additional checks
echo -e "\nSecurity Checks:"
check_resource "Security Groups" "aws ec2 describe-security-groups --filters \"Name=vpc-id,Values=$vpc_id\""

echo -e "\nInfrastructure validation complete!"

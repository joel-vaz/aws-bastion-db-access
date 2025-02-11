#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENV=$1
PROJECT_NAME="bastion-app"
WORKSPACE_DIR="../environments/$ENV"

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

# Get security group IDs
webserver_sg_id=$(terraform output -raw webserver_sg_id)
db_sg_id=$(terraform output -raw database_sg_id)

# Get subnet IDs
private_subnet_ids=$(terraform output -json private_subnet_ids | jq -r 'join(",")')
public_subnet_ids=$(terraform output -json public_subnet_ids | jq -r 'join(",")')

# 1. VPC and Network
echo -e "\nNetwork Infrastructure:"
vpc_id=$(terraform output -raw vpc_id)
check_resource "VPC exists" "aws ec2 describe-vpcs --vpc-id $vpc_id"
check_resource "Subnets" "aws ec2 describe-subnets --filters \"Name=vpc-id,Values=$vpc_id\""
check_resource "NAT Gateway" "aws ec2 describe-nat-gateways --filter \"Name=vpc-id,Values=$vpc_id\" \"Name=state,Values=available\""
check_resource "Internet Gateway" "aws ec2 describe-internet-gateways --filters \"Name=attachment.vpc-id,Values=$vpc_id\""
check_resource "Private Subnets" "aws ec2 describe-subnets --filters \"Name=vpc-id,Values=$vpc_id\" \"Name=tag:Name,Values=*private*\" --query 'Subnets[?MapPublicIpOnLaunch==\`false\`]'"
check_resource "Public Subnets" "aws ec2 describe-subnets --filters \"Name=vpc-id,Values=$vpc_id\" \"Name=tag:Name,Values=*public*\" --query 'Subnets[?MapPublicIpOnLaunch==\`true\`]'"

# 2. Security Groups
echo -e "\nSecurity Groups:"
check_resource "ALB Security (443)" "aws ec2 describe-security-groups --filters \"Name=vpc-id,Values=$vpc_id\" \"Name=ip-permission.to-port,Values=443\""
check_resource "Bastion Security (22)" "aws ec2 describe-security-groups --filters \"Name=vpc-id,Values=$vpc_id\" \"Name=ip-permission.to-port,Values=22\""
check_resource "Database Security (3306)" "aws ec2 describe-security-groups --filters \"Name=vpc-id,Values=$vpc_id\" \"Name=ip-permission.to-port,Values=3306\""
check_resource "Web to NAT" "aws ec2 describe-network-interfaces --filters \"Name=group-id,Values=$webserver_sg_id\" \"Name=description,Values=*NAT*\""
check_resource "Web to DB" "aws ec2 describe-security-groups --group-ids $db_sg_id --filters \"Name=ip-permission.from-port,Values=3306\" \"Name=ip-permission.group-id,Values=$webserver_sg_id\""

# 3. Compute Resources
echo -e "\nCompute Resources:"
check_resource "Bastion Host" "aws ec2 describe-instances --filters \"Name=tag:Name,Values=*bastion*\" \"Name=instance-state-name,Values=running\""
check_resource "Load Balancer" "aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, \`${ENV}-\`)]'"
check_resource "Auto Scaling Group" "aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?contains(AutoScalingGroupName, \`${ENV}-\`)]'"
check_resource "Web Servers in Private Subnet" "aws ec2 describe-instances --filters \"Name=tag:aws:autoscaling:groupName,Values=${ENV}-*-web-asg\" \"Name=subnet-id,Values=$private_subnet_ids\""
check_resource "Bastion in Public Subnet" "aws ec2 describe-instances --filters \"Name=tag:Name,Values=*bastion*\" \"Name=subnet-id,Values=$public_subnet_ids\""

# 4. Database
echo -e "\nDatabase:"
check_resource "RDS Instance" "aws rds describe-db-instances --query \"DBInstances[?contains(DBInstanceIdentifier, '${ENV}-')]\""
check_resource "DB in Private Subnet" "aws rds describe-db-subnet-groups --db-subnet-group-name ${ENV}-${PROJECT_NAME}-db-subnet"
check_resource "DB Encryption" "aws rds describe-db-instances --db-instance-identifier ${ENV}-${PROJECT_NAME}-db --query 'DBInstances[?StorageEncrypted==\`true\`]'"

# Summary
echo -e "\nValidation Summary:"
echo "VPC ID: $vpc_id"
echo "Bastion IP: $(terraform output -raw bastion_public_ip)"
echo "ALB DNS: $(terraform output -raw alb_dns_name)"
echo "DB Endpoint: $(terraform output -raw db_endpoint)"

echo -e "\nInfrastructure validation complete!"

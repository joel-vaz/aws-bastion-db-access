#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI is not configured properly"
    exit 1
fi

ENV=$1
BASTION_KEY_PATH=~/.ssh/bastion-${ENV}.pem

# Ensure .ssh directory exists with proper permissions
if [ ! -d ~/.ssh ]; then
    echo "Creating .ssh directory..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
fi

# Remove existing key if it exists
[ -f "$BASTION_KEY_PATH" ] && rm -f "$BASTION_KEY_PATH"

# Get the key from SSM
echo "Retrieving bastion SSH key..."
aws ssm get-parameter \
    --name "/bastion-app/${ENV}/bastion/ssh_private_key" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text > $BASTION_KEY_PATH || {
    echo "Error: Failed to retrieve SSH key from SSM"
    exit 1
}

# Set correct permissions
chmod 400 $BASTION_KEY_PATH

# Get bastion IP
echo "Getting bastion IP..."
BASTION_IP=$(cd ../environments/$ENV && terraform output -raw bastion_public_ip) || {
    echo "Error: Failed to get bastion IP. Make sure you have deployed the infrastructure"
    exit 1
}

echo "Connecting to bastion host..."
ssh -i $BASTION_KEY_PATH ec2-user@$BASTION_IP

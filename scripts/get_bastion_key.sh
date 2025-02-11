#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENV=$1
BASTION_KEY_PATH=~/.ssh/bastion-${ENV}.pem

# Get the key from SSM
echo "Retrieving bastion SSH key..."
aws ssm get-parameter \
    --name "/bastion-app/${ENV}/bastion/ssh_private_key" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text > $BASTION_KEY_PATH

# Set correct permissions
chmod 400 $BASTION_KEY_PATH

echo "SSH key saved to: $BASTION_KEY_PATH"
echo "To connect: ssh -i $BASTION_KEY_PATH ec2-user@<bastion-ip>"

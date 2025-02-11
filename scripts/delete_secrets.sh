#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <environment> [region]"
    exit 1
fi

ENV=$1
REGION=${2:-us-west-2}
PREFIX="/bastion-app/$ENV"

echo "Deleting secrets for environment: $ENV in region: $REGION"

# Delete database credentials
aws ssm delete-parameter \
    --name "$PREFIX/database/username" \
    --region "$REGION"

aws ssm delete-parameter \
    --name "$PREFIX/database/password" \
    --region "$REGION"

# Delete JWT secret
aws ssm delete-parameter \
    --name "$PREFIX/jwt_secret" \
    --region "$REGION"

echo "All secrets deleted successfully from SSM Parameter Store"

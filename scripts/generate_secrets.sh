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

echo "Generating secrets for environment: $ENV in region: $REGION"

# Store database credentials
DB_USERNAME="admin"
DB_PASSWORD=$(openssl rand -base64 32)

aws ssm put-parameter \
    --name "$PREFIX/database/username" \
    --value "$DB_USERNAME" \
    --type "String" \
    --description "Database username for ${ENV} environment" \
    --overwrite \
    --region "$REGION"

aws ssm put-parameter \
    --name "$PREFIX/database/password" \
    --value "$DB_PASSWORD" \
    --type "SecureString" \
    --description "Database password for ${ENV} environment" \
    --overwrite \
    --region "$REGION"

# Store JWT secret
JWT_SECRET=$(openssl rand -base64 32)
aws ssm put-parameter \
    --name "$PREFIX/jwt_secret" \
    --value "$JWT_SECRET" \
    --type "SecureString" \
    --description "JWT secret for ${ENV} environment" \
    --overwrite \
    --region "$REGION"

echo "All secrets generated and stored successfully in SSM Parameter Store"

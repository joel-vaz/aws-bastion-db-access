#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get metadata token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

check_requirement() {
    echo -n "Checking $1... "
    if eval $2 &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        [ ! -z "$3" ] && echo "  $3"
        return 1
    fi
}

# Core Requirements Check
echo "Core Requirements:"
check_requirement "SSH Access (22)" "netstat -ln | grep ':22.*LISTEN'" "SSH port not listening"
check_requirement "Internet Access" "curl -s --connect-timeout 5 amazon.com" "No internet connectivity"

# Security Configuration
echo -e "\nSecurity Configuration:"
check_requirement "SSH Password Auth" "grep '^PasswordAuthentication no' /etc/ssh/sshd_config" "SSH password authentication is enabled"

# Print Network Info
echo -e "\nNetwork Configuration:"
echo "Default Route:"
ip route | grep default
echo -e "\nListening Ports:"
netstat -ln | grep 'LISTEN'

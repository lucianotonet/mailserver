#!/bin/bash

# Function to display usage
show_usage() {
    echo "Usage: $0 email add <email> <password>"
    echo "Example: $0 email add user@domain.com mypassword"
    exit 1
}

# Check if docker-mailserver setup script exists
if [ ! -f "./config/setup.sh" ]; then
    echo "Downloading docker-mailserver setup script..."
    curl -o "./config/setup.sh" https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master/setup.sh
    chmod +x "./config/setup.sh"
fi

# Check command line arguments
if [ "$1" = "email" ] && [ "$2" = "add" ] && [ -n "$3" ] && [ -n "$4" ]; then
    ./config/setup.sh email add "$3" "$4"
else
    show_usage
fi 
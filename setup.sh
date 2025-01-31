#!/bin/bash

# Create required directories
mkdir -p maildata
mkdir -p mailstate
mkdir -p maillogs
mkdir -p config

# Set correct permissions
chmod -R 0700 maildata
chmod -R 0700 mailstate
chmod -R 0700 maillogs
chmod -R 0700 config

# Create initial configuration files if they don't exist
touch config/postfix-accounts.cf
touch config/postfix-virtual.cf

echo "Setup completed successfully!"

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
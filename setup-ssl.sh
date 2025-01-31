#!/bin/bash

# Load environment variables
source .env

# Create SSL directory structure
mkdir -p "./ssl/${DOMAINNAME}"

# Generate self-signed certificate for initial setup
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "./ssl/${DOMAINNAME}/privkey.pem" \
  -out "./ssl/${DOMAINNAME}/fullchain.pem" \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=Mail Server/OU=IT/CN=${HOSTNAME}"

# Set proper permissions
chmod 600 "./ssl/${DOMAINNAME}/privkey.pem"
chmod 644 "./ssl/${DOMAINNAME}/fullchain.pem"

echo "SSL certificates generated successfully!"
echo "Please replace these self-signed certificates with Let's Encrypt certificates when possible." 
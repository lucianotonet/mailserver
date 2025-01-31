#!/bin/bash

# Set hostname and domainname
hostnamectl set-hostname mail.tonet.dev || hostname mail.tonet.dev
echo "mail.tonet.dev" > /etc/hostname
echo "tonet.dev" > /etc/domainname

# Update hosts file
echo "127.0.0.1 mail.tonet.dev mail localhost localhost.localdomain" > /etc/hosts
echo "::1 mail.tonet.dev mail localhost localhost.localdomain" >> /etc/hosts

# Start the mailserver
exec /usr/local/bin/start-mailserver.sh 
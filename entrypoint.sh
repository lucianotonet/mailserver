#!/bin/bash

# Set hostname and domainname
hostname mail.tonet.dev
echo "mail.tonet.dev" > /etc/hostname
echo "tonet.dev" > /etc/domainname

# Start the mailserver
exec /usr/local/bin/start-mailserver.sh 
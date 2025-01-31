#!/bin/bash

# Debug information
echo "Current hostname: $(hostname)"
echo "Current domainname: $(hostname -d)"
echo "Contents of /etc/hostname: $(cat /etc/hostname)"
echo "Contents of /etc/hosts: $(cat /etc/hosts)"

# Start the mailserver
exec /usr/local/bin/start-mailserver.sh 
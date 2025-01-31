mkdir -p ssl && sudo chmod 755 ssl
certbot certonly --standalone -d mail.tonet.dev --non-interactive --agree-tos -m admin@tonet.dev
cp /etc/letsencrypt/live/mail.tonet.dev/* ./ssl/ 
docker compose config
docker compose up -d
docker exec mailserver postconf -n
docker exec mailserver dovecot -n 
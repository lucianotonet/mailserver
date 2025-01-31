#!/bin/bash

# Configurações
DOMAIN="tonet.dev"
MAIL_HOST="mail.${DOMAIN}"
SSL_DIR="config/ssl"

# Cria diretórios necessários
mkdir -p "${SSL_DIR}/demoCA"

# Gera chave privada
openssl genrsa -out "${SSL_DIR}/${MAIL_HOST}-key.pem" 4096

# Gera certificado auto-assinado
openssl req -new -x509 -key "${SSL_DIR}/${MAIL_HOST}-key.pem" \
    -out "${SSL_DIR}/${MAIL_HOST}-cert.pem" \
    -days 3650 \
    -subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=Tonet Dev/OU=Mail/CN=${MAIL_HOST}"

# Cria CA
openssl req -new -x509 \
    -keyout "${SSL_DIR}/demoCA/cakey.pem" \
    -out "${SSL_DIR}/demoCA/cacert.pem" \
    -days 3650 \
    -nodes \
    -subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=Tonet Dev CA/OU=Mail CA/CN=${DOMAIN}"

# Define permissões
chmod 600 "${SSL_DIR}/${MAIL_HOST}-key.pem"
chmod 644 "${SSL_DIR}/${MAIL_HOST}-cert.pem"
chmod 600 "${SSL_DIR}/demoCA/cakey.pem"
chmod 644 "${SSL_DIR}/demoCA/cacert.pem"

echo "Certificados SSL gerados com sucesso em ${SSL_DIR}" 
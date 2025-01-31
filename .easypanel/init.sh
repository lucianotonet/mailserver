#!/bin/bash

# Carrega variáveis de ambiente do EasyPanel
if [ -f "/app/.easypanel/.env" ]; then
    source /app/.easypanel/.env
else
    # Valores padrão caso não exista o arquivo
    DATA_PATH="/root/mailserver/mail-data"
    STATE_PATH="/root/mailserver/mail-state"
    LOGS_PATH="/root/mailserver/mail-logs"
    CONFIG_PATH="/root/mailserver/config"
    SSL_PATH="/root/mailserver/ssl"
    HOSTNAME="mail.tonet.dev"
    DOMAINNAME="tonet.dev"
fi

# Criar diretórios necessários
mkdir -p "${SSL_PATH}/${DOMAINNAME}"
mkdir -p "${DATA_PATH}"
mkdir -p "${STATE_PATH}"
mkdir -p "${LOGS_PATH}"
mkdir -p "${CONFIG_PATH}"

# Gerar certificados SSL se não existirem
if [ ! -f "${SSL_PATH}/${DOMAINNAME}/privkey.pem" ] || [ ! -f "${SSL_PATH}/${DOMAINNAME}/fullchain.pem" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${SSL_PATH}/${DOMAINNAME}/privkey.pem" \
        -out "${SSL_PATH}/${DOMAINNAME}/fullchain.pem" \
        -subj "/C=BR/ST=SP/L=Sao Paulo/O=Mail Server/OU=IT/CN=${HOSTNAME}"
    
    # Definir permissões corretas
    chmod 600 "${SSL_PATH}/${DOMAINNAME}/privkey.pem"
    chmod 644 "${SSL_PATH}/${DOMAINNAME}/fullchain.pem"
fi

# Definir permissões dos diretórios
chmod -R 0700 "${DATA_PATH}"
chmod -R 0700 "${STATE_PATH}"
chmod -R 0700 "${LOGS_PATH}"
chmod -R 0700 "${CONFIG_PATH}"

echo "Inicialização concluída com sucesso!" 
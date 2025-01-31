#!/bin/bash

# Configurações
DOMAIN="tonet.dev"
MAIL_DOMAIN="tonet.dev"
MAIL_HOSTNAME="mail.tonet.dev"

# Criar estrutura de diretórios
mkdir -p config data state logs ssl/${DOMAIN}

# Copiar arquivo .env
cp .env.example .env

# Gerar certificados SSL iniciais
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/${DOMAIN}/privkey.pem \
    -out ssl/${DOMAIN}/fullchain.pem \
    -subj "/C=BR/ST=SP/L=Sao Paulo/O=Mail Server/CN=${MAIL_HOSTNAME}"

# Ajustar permissões
chmod 600 ssl/${DOMAIN}/privkey.pem ssl/${DOMAIN}/fullchain.pem

# Criar arquivo de contas inicial (se não existir)
touch config/postfix-accounts.cf
touch config/postfix-virtual.cf

echo "Ambiente local configurado com sucesso!"
echo "Para fazer deploy:"
echo "1. git add ."
echo "2. git commit -m 'update: configuração atualizada'"
echo "3. git push origin main"

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
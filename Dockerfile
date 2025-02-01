# Use a imagem oficial do docker-mailserver como base
FROM docker.io/mailserver/docker-mailserver:latest

# Define variáveis de ambiente padrão
ENV HOSTNAME=mail.tonet.dev \
    DOMAINNAME=tonet.dev \
    MAIL_DOMAIN=tonet.dev \
    MAIL_HOSTNAME=mail.tonet.dev \
    POSTMASTER_ADDRESS=postmaster@tonet.dev \
    SSL_TYPE=manual \
    LETSENCRYPT_DOMAIN=mail.tonet.dev \
    TZ=America/Sao_Paulo \
    DMS_DEBUG=1 \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ENABLE_FAIL2BAN=1 \
    ENABLE_POSTGREY=1 \
    ONE_DIR=1 \
    PERMIT_DOCKER=network \
    POSTFIX_INET_PROTOCOLS=ipv4 \
    DOVECOT_INET_PROTOCOLS=ipv4 \
    OVERRIDE_HOSTNAME=mail.tonet.dev \
    DMS_HOSTNAME=mail.tonet.dev \
    DMS_DOMAINNAME=tonet.dev

# Instala o netcat para healthcheck
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Cria diretórios necessários
RUN mkdir -p /tmp/docker-mailserver/ssl/demoCA \
    && mkdir -p /var/mail \
    && mkdir -p /var/mail-state \
    && mkdir -p /var/log/mail \
    && mkdir -p /etc/letsencrypt/live/tonet.dev

# Gera certificados SSL temporários para desenvolvimento
RUN openssl genrsa -out /tmp/docker-mailserver/ssl/mail.tonet.dev-key.pem 4096 \
    && openssl req -new -x509 \
        -key /tmp/docker-mailserver/ssl/mail.tonet.dev-key.pem \
        -out /tmp/docker-mailserver/ssl/mail.tonet.dev-cert.pem \
        -days 3650 \
        -subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=Tonet Dev/OU=Mail/CN=mail.tonet.dev" \
    && openssl req -new -x509 \
        -keyout /tmp/docker-mailserver/ssl/demoCA/cakey.pem \
        -out /tmp/docker-mailserver/ssl/demoCA/cacert.pem \
        -days 3650 \
        -nodes \
        -subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=Tonet Dev CA/OU=Mail CA/CN=tonet.dev" \
    && chmod 600 /tmp/docker-mailserver/ssl/mail.tonet.dev-key.pem \
    && chmod 644 /tmp/docker-mailserver/ssl/mail.tonet.dev-cert.pem \
    && chmod 600 /tmp/docker-mailserver/ssl/demoCA/cakey.pem \
    && chmod 644 /tmp/docker-mailserver/ssl/demoCA/cacert.pem \
    && ln -sf /tmp/docker-mailserver/ssl/mail.tonet.dev-key.pem /etc/letsencrypt/live/tonet.dev/privkey.pem \
    && ln -sf /tmp/docker-mailserver/ssl/mail.tonet.dev-cert.pem /etc/letsencrypt/live/tonet.dev/fullchain.pem

# Copia os arquivos de configuração
COPY config/ /tmp/docker-mailserver/
COPY setup.sh /
COPY entrypoint.sh /usr/local/bin/

# Define permissões
RUN chmod +x /setup.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Expõe as portas necessárias
EXPOSE 25 465 587 993

# Define volumes
VOLUME [ "/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver" ]

# Define o diretório de trabalho
WORKDIR /app

# Copia o script de inicialização do EasyPanel
COPY .easypanel/init.sh /app/init.sh
RUN chmod +x /app/init.sh

# Define o entrypoint
ENTRYPOINT ["/bin/sh", "-c", "/app/init.sh && /usr/local/bin/start-mailserver.sh"] 
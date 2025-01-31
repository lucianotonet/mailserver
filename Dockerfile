# Use a imagem oficial do docker-mailserver como base
FROM mailserver/docker-mailserver:latest

# Define variáveis de ambiente padrão
ENV HOSTNAME=mail.tonet.dev \
    DOMAINNAME=tonet.dev \
    MAIL_DOMAIN=tonet.dev \
    MAIL_HOSTNAME=mail.tonet.dev \
    POSTMASTER_ADDRESS=postmaster@tonet.dev \
    SSL_TYPE=self-signed \
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

# Cria diretório SSL
RUN mkdir -p /tmp/docker-mailserver/ssl/demoCA

# Copia os certificados SSL
COPY config/ssl/mail.tonet.dev-key.pem /tmp/docker-mailserver/ssl/
COPY config/ssl/mail.tonet.dev-cert.pem /tmp/docker-mailserver/ssl/
COPY config/ssl/demoCA/cacert.pem /tmp/docker-mailserver/ssl/demoCA/
COPY config/ssl/demoCA/cakey.pem /tmp/docker-mailserver/ssl/demoCA/

# Define permissões dos certificados
RUN chmod 600 /tmp/docker-mailserver/ssl/mail.tonet.dev-key.pem \
    && chmod 644 /tmp/docker-mailserver/ssl/mail.tonet.dev-cert.pem \
    && chmod 600 /tmp/docker-mailserver/ssl/demoCA/cakey.pem \
    && chmod 644 /tmp/docker-mailserver/ssl/demoCA/cacert.pem

# Copia os arquivos de configuração
COPY config/hostname.conf /etc/hostname
COPY config/domainname.conf /etc/domainname
COPY config/ /tmp/docker-mailserver/
COPY setup.sh /

# Dá permissão de execução ao script de setup
RUN chmod +x /setup.sh

# Expõe as portas necessárias
EXPOSE 25 465 587 993

# Define o volume para persistência dos dados
VOLUME [ "/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver" ]

# Copia o script de inicialização
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define o comando padrão
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [] 
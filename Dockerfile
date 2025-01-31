# Use a imagem oficial do docker-mailserver como base
FROM mailserver/docker-mailserver:latest

# Define variáveis de ambiente padrão
ENV TZ=America/Sao_Paulo \
    SSL_TYPE=letsencrypt \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ENABLE_FAIL2BAN=1 \
    ENABLE_POSTGREY=1 \
    MAIL_DOMAIN=tonet.dev \
    MAIL_HOSTNAME=mail.tonet.dev \
    PERMIT_DOCKER=network \
    ONE_DIR=1 \
    ENABLE_POSTFIX_VIRTUAL_TRANSPORT=1 \
    POSTFIX_DAGENT=lmtp:dovecot:24 \
    REPORT_RECIPIENT=1

# Instala o netcat para healthcheck
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Copia os arquivos de configuração
COPY config/ /tmp/docker-mailserver/
COPY setup.sh /

# Dá permissão de execução ao script de setup
RUN chmod +x /setup.sh

# Expõe as portas necessárias
EXPOSE 25 465 587 993

# Define o volume para persistência dos dados
VOLUME [ "/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver" ]

# Define o comando padrão
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"] 
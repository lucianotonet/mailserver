# Use a imagem oficial do docker-mailserver como base
FROM docker-mailserver/docker-mailserver:latest

# Define variáveis de ambiente padrão
ENV TZ=America/Sao_Paulo \
    SSL_TYPE=letsencrypt \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ENABLE_FAIL2BAN=1 \
    ENABLE_POSTGREY=1 \
    MAIL_DOMAIN=tonet.dev \
    MAIL_HOSTNAME=mail.tonet.dev

# Copia os arquivos de configuração
COPY config/ /tmp/docker-mailserver/
COPY setup.sh /

# Dá permissão de execução ao script de setup
RUN chmod +x /setup.sh

# Expõe as portas necessárias
EXPOSE 25 465 587 993

# Define o volume para persistência dos dados
VOLUME [ "/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver" ]

# Define o ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/dms-wrapper.sh"] 
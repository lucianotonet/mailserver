# Use a imagem oficial do docker-mailserver como base
FROM mailserver/docker-mailserver:latest

# Define argumentos que podem ser passados durante o build
ARG MAIL_DOMAIN
ARG MAIL_HOSTNAME
ARG TZ=America/Sao_Paulo

# Define variáveis de ambiente padrão
ENV MAIL_DOMAIN=${MAIL_DOMAIN:-tonet.dev} \
    MAIL_HOSTNAME=${MAIL_HOSTNAME:-mail.tonet.dev} \
    TZ=${TZ} \
    SSL_TYPE=letsencrypt \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ENABLE_FAIL2BAN=1 \
    ENABLE_POSTGREY=1

# Cria diretórios necessários
RUN mkdir -p /var/mail \
    /var/mail-state \
    /var/log/mail \
    /tmp/docker-mailserver

# Copia os arquivos de configuração
COPY config/ /tmp/docker-mailserver/
COPY setup.sh /

# Dá permissão de execução ao script de setup
RUN chmod +x /setup.sh

# Expõe as portas necessárias
EXPOSE 25 465 587 993

# Define o volume para persistência dos dados
VOLUME [ "/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver" ]

# Mantém o ENTRYPOINT original da imagem base
ENTRYPOINT ["/usr/local/bin/dms-wrapper.sh"]

# Mantém o CMD original da imagem base
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"] 
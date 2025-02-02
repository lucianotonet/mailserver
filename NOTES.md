# Notas de Desenvolvimento - Mailserver

## Informações do Ambiente
- **Sistema**: Windows 10 (win32 10.0.22000)
- **Shell**: Git Bash (C:\Program Files\Git\bin\bash.exe)
- **Workspace**: D:/LucianoTonet/mailserver
- **Repositório**: github.com:lucianotonet/mailserver.git

## Configurações Importantes

### Portas e Protocolos
- SMTP: 25 (sem SSL), 465 (SSL), 587 (TLS)
- IMAP: 143 (sem SSL, disponível para compatibilidade), 993 (SSL, recomendado)
- POP3: 110 (sem SSL), 995 (SSL)

### Domínios e Hostnames
- Domínio Principal: tonet.dev
- Hostname do Mail: mail.tonet.dev
- Roundcube URL: tonetdev-roundcube.i3bl61.easypanel.host

### Credenciais e Acessos
- Usuário Padrão: admin@tonet.dev
- Diretório de Emails: /var/mail/%d/%n
- Formato: Maildir

## Lições Aprendidas

### 1. Configuração do Docker
- Usar a imagem base `docker.io/mailserver/docker-mailserver:latest`
- NÃO tentar gerenciar o usuário vmail (já existe na imagem base)
- Manter volumes persistentes para:
  ```yaml
  volumes:
    - maildata:/var/mail
    - maildata:/var/lib/dovecot
    - maildata:/etc/postfix
    - mail-state:/var/mail-state
    - mail-logs:/var/log/mail
    - mail-config:/tmp/docker-mailserver
    - ssl-certs:/etc/ssl/docker-mailserver
  ```

### 2. Configuração do EasyPanel
- Nome do serviço deve usar hífen (-) e não underscore (_)
  - Correto: tonetdev-mailserver
  - Errado: tonetdev_mailserver
- Links entre containers devem usar o nome do serviço EasyPanel
- Roundcube deve apontar para o nome do serviço, não IP ou hostname

### 3. Configuração SSL/TLS
- Certificados devem estar em `/etc/ssl/docker-mailserver/`
- Permissões importantes:
  - key.pem: 600
  - cert.pem: 644
- Estrutura de certificados:
  ```
  /etc/ssl/docker-mailserver/
  ├── key.pem
  └── cert.pem
  ```

### 4. Dovecot
- Arquivo de configuração em `config/dovecot.cf`
- Configurações críticas:
  ```
  disable_plaintext_auth = no  # Permite autenticação sem SSL (porta 143)
  ssl = yes                    # Habilita SSL mas não força seu uso
  auth_mechanisms = plain login
  mail_location = maildir:/var/mail/%d/%n
  listen = *                   # Escuta em todas as interfaces
  ```
- Portas IMAP:
  - 143: Disponível para compatibilidade (sem SSL)
  - 993: Recomendada para uso geral (SSL)

### 5. Postfix
- Arquivo principal em `/etc/postfix/main.cf`
- Não tentar criar manualmente, deixar a imagem base gerenciar
- Configurações importantes no ambiente:
  ```
  myhostname = mail.tonet.dev
  mydomain = tonet.dev
  ```

### 6. Roundcube
- Configurações críticas no `.env`:
  ```
  ROUNDCUBEMAIL_DEFAULT_HOST=tonetdev-mailserver
  ROUNDCUBEMAIL_DEFAULT_PORT=143
  ROUNDCUBEMAIL_SMTP_SERVER=tonetdev-mailserver
  ROUNDCUBEMAIL_SMTP_PORT=25
  ROUNDCUBEMAIL_PLUGINS=archive,zipdownload
  ```

## Problemas Comuns e Soluções

### 1. Erro "SSL required for authentication"
- Solução temporária: `disable_plaintext_auth = no` no Dovecot
- Solução permanente: Configurar SSL corretamente
- Alternativa: Usar porta 143 para clientes que não suportam SSL

### 2. Erro de conexão Roundcube
- Usar nome do serviço EasyPanel (com hífen)
- Verificar se as portas estão corretas
- Testar primeiro sem SSL/TLS

### 3. Problemas de Persistência
- Usar volume `maildata` compartilhado
- Manter permissões consistentes
- Não tentar gerenciar usuário vmail

### 4. Problemas de Conexão IMAP
- Verificar se a porta está aberta (143 ou 993)
- Confirmar configurações do cliente
- Para porta 143:
  - Verificar se `disable_plaintext_auth = no`
  - Confirmar que `listen = *` está configurado
  - Testar com `telnet mail.tonet.dev 143`

## Fluxo de Trabalho Ideal

1. **Setup Inicial**
   ```bash
   ./setup.sh email add admin@tonet.dev senha123
   ```

2. **Verificação de Configuração**
   ```bash
   docker exec mailserver setup debug show-mail-logs
   docker exec mailserver postconf -n
   docker exec mailserver dovecot -n
   ```

3. **Teste de Conexão**
   ```bash
   # Teste IMAP sem SSL
   telnet mail.tonet.dev 143
   # Teste IMAP com SSL
   openssl s_client -connect mail.tonet.dev:993
   ```

4. **Monitoramento**
   ```bash
   docker exec mailserver supervisorctl status
   docker logs -f mailserver
   ```

## Próximos Passos Recomendados

1. Implementar SSL/TLS corretamente
2. Configurar DKIM, SPF e DMARC
3. Ajustar políticas de spam
4. Implementar backup automatizado
5. Configurar monitoramento
6. Considerar desativar porta 143 após migração de todos os clientes para SSL

## Referências Úteis
- [Docker Mailserver Docs](https://docker-mailserver.github.io/docker-mailserver/edge/)
- [EasyPanel Docs](https://easypanel.io/docs)
- [Roundcube Docs](https://github.com/roundcube/roundcubemail/wiki)
- [Dovecot Docs](https://doc.dovecot.org/)
- [Postfix Docs](http://www.postfix.org/documentation.html) 
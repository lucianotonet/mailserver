# Docker Mailserver with EasyPanel Integration

Este é um servidor de email completo e seguro baseado em Docker, otimizado para deploy via EasyPanel. O projeto utiliza Postfix como MTA (Mail Transfer Agent) e Dovecot como MDA (Mail Delivery Agent), com suporte completo a DKIM, SPF e DMARC para garantir a entregabilidade dos emails.

## Características Principais

- 📧 Servidor de email completo (SMTP, IMAP, POP3)
- 🔒 Configuração segura com SSL/TLS
- 🛡️ Proteção contra spam com SpamAssassin
- 🦠 Antivírus integrado com ClamAV
- 🔑 Suporte a DKIM, SPF e DMARC
- 🚀 Deploy automatizado via EasyPanel
- 📱 Webmail moderno (Roundcube/Rainloop)
- 🔄 Backup e restauração simplificados
- 🛡️ Proteção contra ataques com Fail2ban

## Configuração Inicial

1. Clone o repositório
2. Copie .env.example para .env e configure as variáveis:
   ```bash
   cp .env.example .env
   ```
   
   Variáveis importantes:
   - `DOMAIN`: Seu domínio principal (ex: tonet.dev)
   - `HOSTNAME`: Nome do servidor (ex: mail.tonet.dev)
   - `SSL_TYPE`: Tipo de SSL (letsencrypt/manual/self-signed)
   - `ENABLE_FAIL2BAN`: Recomendado deixar como 1
   - `ENABLE_SPAMASSASSIN`: Recomendado deixar como 1
   - `SPAMASSASSIN_SPAM_TO_INBOX`: 0 para spam ir para pasta Junk

3. Execute o setup inicial para criar a primeira conta:
   ```bash
   ./setup.sh email add admin@seudominio.com senha123
   ```

4. Inicie o servidor:
   ```bash
   docker-compose up -d
   ```

## Configuração DNS

1. Registros A:
   ```
   mail.seudominio.com.  IN A    SEU_IP_SERVIDOR
   ```

2. Registro MX:
   ```
   seudominio.com.    IN MX 10   mail.seudominio.com.
   ```

3. Registro SPF (TXT para seudominio.com):
   ```
   v=spf1 mx a ip4:SEU_IP_SERVIDOR ~all
   ```

4. Registro DKIM:
   ```bash
   # Gerar chaves DKIM (já feito automaticamente no primeiro deploy)
   docker exec mailserver opendkim-genkey -s mail -d seudominio.com
   
   # Ver a chave gerada
   docker exec mailserver cat /etc/opendkim/keys/mail.txt
   ```
   
   Adicionar registro TXT para mail._domainkey.seudominio.com com o valor mostrado

5. Registro DMARC (TXT para _dmarc.seudominio.com):
   ```
   v=DMARC1; p=none; rua=mailto:postmaster@seudominio.com
   ```

## Gerenciamento de Contas

### Criar nova conta:
```bash
docker exec mailserver setup email add usuario@seudominio.com
```

### Listar contas:
```bash
docker exec mailserver setup email list
```

### Alterar senha:
```bash
docker exec mailserver setup email update usuario@seudominio.com
```

### Deletar conta:
```bash
docker exec mailserver setup email del usuario@seudominio.com
```

## Interfaces de Webmail Recomendadas

1. **Roundcube** (Interface web moderna):
   ```bash
   docker run -d \
     --name roundcube \
     --network mailserver_default \
     -e ROUNDCUBEMAIL_DEFAULT_HOST=tls://mail.seudominio.com \
     -e ROUNDCUBEMAIL_SMTP_SERVER=tls://mail.seudominio.com \
     -p 8000:80 \
     roundcube/roundcubemail
   ```

2. **Rainloop** (Alternativa leve):
   ```bash
   docker run -d \
     --name rainloop \
     --network mailserver_default \
     -p 8001:80 \
     hardware/rainloop
   ```

## Configuração de Clientes de Email

### Configurações IMAP:
- Servidor: mail.seudominio.com
- Porta: 993 (SSL/TLS)
- Autenticação: Normal Password
- Usuário: email completo

### Configurações SMTP:
- Servidor: mail.seudominio.com
- Porta: 587 (STARTTLS)
- Autenticação: Normal Password
- Usuário: email completo

## Configuração do Webmail (Roundcube)

### Deploy via EasyPanel

1. No EasyPanel, acesse a seção "Services"
2. Clique em "Create Service"
3. Selecione "Roundcube" no catálogo
4. Configure os seguintes campos:
   - App Service Name: roundcube
   - App Service Image: roundcube/roundcubemail:1.6.9-apache
   - Default Host: mail.tonet.dev
   - Default Port: 143
   - SMTP Server: mail.tonet.dev
   - SMTP Port: 587
   - Plugins: archive,zipdownload
   - Upload Max File Size: 5M

5. Clique em "Create" para iniciar o deploy

### Acesso ao Webmail

1. Após o deploy, o Roundcube estará disponível em:
   ```
   https://roundcube.tonet.dev
   ```

2. Use suas credenciais de email para fazer login:
   - Usuário: seu_email@tonet.dev
   - Senha: sua_senha_de_email

### Configurações de Segurança

1. O Roundcube já está configurado para usar SSL/TLS
2. As conexões IMAP e SMTP são criptografadas
3. O limite de upload está definido em 5MB por padrão
4. Os plugins básicos estão habilitados:
   - archive: para arquivamento de mensagens
   - zipdownload: para download em lote

### Troubleshooting

Se encontrar problemas de conexão:

1. Verifique se o servidor de email está online:
   ```bash
   docker exec mailserver supervisorctl status
   ```

2. Teste as portas IMAP e SMTP:
   ```bash
   telnet mail.tonet.dev 143
   telnet mail.tonet.dev 587
   ```

3. Verifique os logs do Roundcube:
   ```bash
   docker logs roundcube
   ```

## Deploy no EasyPanel

1. Adicione as variáveis de ambiente no EasyPanel (copie do seu .env local)
2. Configure o webhook do GitHub para deploy automático
3. O deploy será automático após cada push na branch main

## Monitoramento e Manutenção

### Verificar logs:
```bash
docker exec mailserver setup debug show-mail-logs
```

### Verificar filas de email:
```bash
docker exec mailserver postqueue -p
```

### Limpar filas de email:
```bash
docker exec mailserver postsuper -d ALL
```

### Verificar status dos serviços:
```bash
docker exec mailserver supervisorctl status
```

## Testes e Validação

1. Teste SMTP:
   ```bash
   telnet mail.seudominio.com 25
   ```

2. Teste IMAP:
   ```bash
   telnet mail.seudominio.com 143
   ```

3. Verificação de registros DNS:
   - https://mxtoolbox.com/SuperTool.aspx
   - https://dmarcian.com/dkim-inspector/
   - https://www.mail-tester.com/

4. Teste de envio:
   ```bash
   docker exec mailserver swaks --to test@gmail.com --from seu@dominio.com
   ```

## Backup

### Backup manual:
```bash
docker exec mailserver setup backup
```

O backup será salvo em `/var/mail-state/backup/`

### Restauração:
```bash
docker exec mailserver setup restore
```

## Segurança

1. Fail2ban já está configurado por padrão
2. SpamAssassin está ativo
3. ClamAV está disponível para antivírus
4. Todas as portas importantes usam SSL/TLS
5. DKIM, SPF e DMARC protegem contra spoofing

## Troubleshooting

1. Se emails não chegam, verifique:
   - Logs: `docker exec mailserver setup debug show-mail-logs`
   - Filas: `docker exec mailserver postqueue -p`
   - Registros DNS: use mxtoolbox.com

2. Se não consegue enviar, verifique:
   - Portas abertas (25, 587, 465)
   - Registros DNS reversos
   - Se o IP não está em blacklists

3. Problemas de autenticação:
   - Verifique as credenciais
   - Confirme as portas corretas
   - Verifique se SSL/TLS está configurado

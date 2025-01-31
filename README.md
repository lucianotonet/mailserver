# Docker Mailserver

Este repositório contém a configuração do servidor de email usando docker-mailserver.

## Configuração Inicial

1. Clone o repositório
2. Copie .env.example para .env e configure as variáveis
3. Execute o setup inicial:
   ```bash
   ./setup.sh email add luciano@tonet.dev senha
   ```
4. Inicie o servidor:
   ```bash
   docker-compose up -d
   ```

## Deploy no EasyPanel

1. Adicione as variáveis de ambiente no EasyPanel
2. Configure o webhook do GitHub
3. O deploy será automático após cada push na branch main

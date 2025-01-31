#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Domínio a ser verificado
DOMAIN="tonet.dev"
MAIL_HOST="mail.${DOMAIN}"

echo -e "${YELLOW}Verificando registros DNS para ${DOMAIN}...${NC}\n"

# Verifica registro A
echo -e "${YELLOW}Verificando registro A para ${MAIL_HOST}...${NC}"
if host -t A ${MAIL_HOST} > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Registro A encontrado:${NC}"
    host -t A ${MAIL_HOST}
else
    echo -e "${RED}✗ Registro A não encontrado${NC}"
    echo "Adicione um registro A apontando para: 103.199.186.117"
fi
echo

# Verifica registro MX
echo -e "${YELLOW}Verificando registro MX para ${DOMAIN}...${NC}"
if host -t MX ${DOMAIN} > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Registro MX encontrado:${NC}"
    host -t MX ${DOMAIN}
else
    echo -e "${RED}✗ Registro MX não encontrado${NC}"
    echo "Adicione um registro MX apontando para: ${MAIL_HOST}"
fi
echo

# Verifica registro SPF
echo -e "${YELLOW}Verificando registro SPF para ${DOMAIN}...${NC}"
if host -t TXT ${DOMAIN} | grep "v=spf1" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Registro SPF encontrado:${NC}"
    host -t TXT ${DOMAIN} | grep "v=spf1"
else
    echo -e "${RED}✗ Registro SPF não encontrado${NC}"
    echo "Adicione um registro TXT com: v=spf1 mx a:${MAIL_HOST} -all"
fi
echo

# Verifica registro DMARC
echo -e "${YELLOW}Verificando registro DMARC para ${DOMAIN}...${NC}"
if host -t TXT _dmarc.${DOMAIN} > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Registro DMARC encontrado:${NC}"
    host -t TXT _dmarc.${DOMAIN}
else
    echo -e "${RED}✗ Registro DMARC não encontrado${NC}"
    echo "Adicione um registro TXT para _dmarc com: v=DMARC1; p=none; rua=mailto:postmaster@${DOMAIN}"
fi
echo

# Verifica registro DKIM
echo -e "${YELLOW}Verificando registro DKIM para ${DOMAIN}...${NC}"
if host -t TXT mail._domainkey.${DOMAIN} > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Registro DKIM encontrado:${NC}"
    host -t TXT mail._domainkey.${DOMAIN}
else
    echo -e "${RED}✗ Registro DKIM não encontrado${NC}"
    echo "O registro DKIM será gerado após o servidor estar funcionando"
fi
echo

echo -e "${YELLOW}Verificação concluída!${NC}" 
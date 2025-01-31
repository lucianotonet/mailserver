# Crie um arquivo dns-records.txt com estes registros
cat > dns-records.txt <<EOF
MX @ 10 mail.tonet.dev
TXT @ v=spf1 mx -all
CNAME mail tonet.dev
A mail <103.199.186.117>
EOF 
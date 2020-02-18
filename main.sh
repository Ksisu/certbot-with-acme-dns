#!/bin/bash

##
# Configure acme-dns server
##
if [[ -z "${BASE_DOMAIN}" ]]; then
  echo "[ERROR] BASE_DOMAIN not defined!"
  exit 1
fi
if [[ -z "${PUBLIC_IP}" ]]; then
  echo "[ERROR] PUBLIC_IP not defined!"
  exit 1
fi
if [[ -z "${ADMIN_EMAIL}" ]]; then
  echo "[ERROR] ADMIN_EMAIL not defined!"
  exit 1
fi

sed -i "s/<<<BASE_DOMAIN>>>/$BASE_DOMAIN/g" /etc/acme-dns/config.cfg
sed -i "s/<<<PUBLIC_IP>>>/$PUBLIC_IP/g" /etc/acme-dns/config.cfg
sed -i "s/<<<ADMIN_EMAIL>>>/admin.$BASE_DOMAIN/g" /etc/acme-dns/config.cfg

##
# Start acme-dns server
##
acme-dns &

result=""
counter=300
while [[ $counter -gt 0 && "$result" -ne "200" ]]; do
  sleep 1
  result=$(curl --write-out %{http_code} \
    --silent \
    --output /dev/null \
    http://localhost:8080/health)
  echo "[INFO] Check acme-dns server status... $result"
done

if [ "$result" -ne "200" ]; then
  echo "[ERROR] Timeout acme-dns server starting!"
  exit 1
fi


##
# Create certificate at the first time or renew if already exist
##
certbot certificates | grep "$BASE_DOMAIN"
status=$?
if [ $status -ne 0 ]; then
  echo "[INFO] Certificate not found for $BASE_DOMAIN. Create one..."
  certbot certonly \
    -d "*.$BASE_DOMAIN" \
    -d "$BASE_DOMAIN" \
    --email="$ADMIN_EMAIL" \
    --agree-tos \
    --manual-public-ip-logging-ok \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --preferred-challenges dns \
    --manual --manual-auth-hook /etc/letsencrypt-scripts/acme-dns-auth.py \
    --non-interactive
else
  echo "[INFO] Renew certificates"
  certbot renew
fi

echo "===================================="
echo "[INFO] Script finished"

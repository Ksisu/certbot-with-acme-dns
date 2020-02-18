FROM ubuntu:16.04

ENV BASE_DOMAIN=
ENV PUBLIC_IP=
ENV ADMIN_EMAIL=

RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y universe && \
  add-apt-repository -y ppa:certbot/certbot && \
  add-apt-repository -y ppa:longsleep/golang-backports && \
  apt-get update && \
  apt-get install -y certbot curl python python-pip golang-go git && \
  pip install requests

RUN go get -v github.com/joohoi/acme-dns && \
  cp ~/go/bin/acme-dns /usr/local/bin/acme-dns && \
  mkdir /etc/acme-dns/ /var/lib/acme-dns

RUN mkdir /etc/letsencrypt-scripts && \
  curl -o /etc/letsencrypt-scripts/acme-dns-auth.py \
    https://raw.githubusercontent.com/joohoi/acme-dns-certbot-joohoi/master/acme-dns-auth.py && \
  chmod 0700 /etc/letsencrypt-scripts/acme-dns-auth.py && \
  sed -i 's#https://auth.acme-dns.io#http://localhost:8080#g' /etc/letsencrypt-scripts/acme-dns-auth.py

COPY acme-dns-config.cfg /etc/acme-dns/config.cfg 

EXPOSE 53
EXPOSE 53/udp

VOLUME ["/var/lib/acme-dns", "/etc/letsencrypt", "/var/lib/letsencrypt"]

COPY main.sh /main.sh
CMD ["/main.sh"] 

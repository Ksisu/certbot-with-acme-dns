# Certbot with acme-dns
It's a docker image for generating wildcard certificates with [Let’s Encrypt](https://letsencrypt.org/).

Bases on Bryan Roessler's article: [Autorenewing wildcard LetsEncrypt certificates on Namecheap using certbot + acme-dns](https://blog.bryanroessler.com/2019-02-09-automatic-certbot-namecheap-acme-dns/).

Useful links:
 * [https://github.com/joohoi/acme-dns](https://github.com/joohoi/acme-dns) - Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely.
 * [https://github.com/joohoi/acme-dns-certbot-joohoi](https://github.com/joohoi/acme-dns-certbot-joohoi) - Certbot client hook for acme-dns
 * [https://certbot.eff.org](https://certbot.eff.org)

### How to use
TODO: Setup the main dns server (see Bryan Roessler's article)

You have to have a public ip address and open the port number `53`.

The image use 3 volumes, you have to create and mount them here:
 * `/var/lib/acme-dns`
 * `/etc/letsencrypt`
 * `/var/lib/letsencrypt`

Setup the environment variables:
 * `BASE_DOMAIN` - your domain name. If you want certificate for a `*.myexampledomain.com`, then set it to `myexampledomain.com`
 * `PUBLIC_IP` - your public ip address
 * `ADMIN_EMAIL` - your email address. (Let’s Encrypt will send you warning if the certificate will be expire soon)

```bash
docker run --rm \
  -v "$(pwd)/var-lib-acme-dns:/var/lib/acme-dns" \
  -v "$(pwd)/etc-letsencrypt:/etc/letsencrypt" \
  -v "$(pwd)/var-lib-letsencrypt:/var/lib/letsencrypt" \
  -p 53:53 -p 53:53/udp \
  --env-file=.env \
  ksisu/acme-dns-certbot
```

For the first run you will see an error message to like "set this cname dns record too on your main server".
TODO


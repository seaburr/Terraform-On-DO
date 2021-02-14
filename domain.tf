resource "digitalocean_domain" "web-domain" {
   name = "barista.cloud"
   ip_address = digitalocean_loadbalancer.loadbalancer.ip
}

resource "digitalocean_record" "CNAME-www" {
  domain = digitalocean_domain.web-domain.name
  type = "CNAME"
  name = "www"
  value = "@"
}
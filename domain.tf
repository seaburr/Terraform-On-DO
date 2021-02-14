resource "digitalocean_domain" "web-domain" {
   name = var.host_name
   ip_address = digitalocean_loadbalancer.loadbalancer.ip
}

resource "digitalocean_record" "CNAME-www" {
  domain = digitalocean_domain.web-domain.name
  type = "CNAME"
  name = "www"
  value = "@"
}
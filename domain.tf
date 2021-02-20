resource "digitalocean_domain" "web-domain" {
   name = var.host_name
}

resource "digitalocean_record" "CNAME-www" {
  domain = digitalocean_domain.web-domain.id
  type = "CNAME"
  name = "www"
  value = "@"
}
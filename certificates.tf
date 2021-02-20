resource "digitalocean_certificate" "ssl-cert" {
  name    = "${var.deployment_name}-le-ssl"
  type    = "lets_encrypt"
  domains = [ digitalocean_domain.web-domain.name ]

  lifecycle {
    create_before_destroy = true
  }
}
resource "digitalocean_certificate" "ssl-cert" {
  name    = "${var.deployment_name}-le-ssl"
  type    = "lets_encrypt"
  domains = [ var.host_name ]
}
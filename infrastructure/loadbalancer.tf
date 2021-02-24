resource "digitalocean_loadbalancer" "loadbalancer" {
  name = "${var.deployment_name}-lb"
  region = var.digitalocean_region
  droplet_tag = "web-nodes"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port = 443
    entry_protocol = "https"

    target_port = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.ssl-cert.name
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }
}


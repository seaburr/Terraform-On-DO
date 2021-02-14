resource "digitalocean_loadbalancer" "loadbalancer" {
  name = "${var.deployment_name}-lb"
  region = var.digitalocean_region

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = [ digitalocean_droplet.web-node-1.id, digitalocean_droplet.web-node-2.id ]
}


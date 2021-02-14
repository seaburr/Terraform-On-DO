resource "digitalocean_tag" "web-tag" {
  name = "web-nodes"
}

resource "digitalocean_tag" "nfs-tag" {
    name = "nfs-node"
}

resource "digitalocean_tag" "cluster-tag" {
    name = var.deployment_name
}
resource "digitalocean_tag" "web-tag" {
  name = "web-nodes"
}

resource "digitalocean_tag" "nfs-tag" {
    name = "nfs-node"
}
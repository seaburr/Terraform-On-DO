resource "digitalocean_volume" "nfs-volume" {
  region                  = var.digitalocean_region
  name                    = "${var.deployment_name}-volume"
  size                    = var.volume_size
  initial_filesystem_type = "ext4"
  description             = "web-node volume"
}

resource "digitalocean_volume_attachment" "nfs-mount" {
  droplet_id = digitalocean_droplet.nfs-node.id
  volume_id  = digitalocean_volume.nfs-volume.id
}
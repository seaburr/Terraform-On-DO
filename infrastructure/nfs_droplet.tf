resource "digitalocean_droplet" "nfs-node" {
  image = var.droplet_distro
  name = "${var.deployment_name}-nfs"
  region = var.digitalocean_region
  size = var.droplet_size
  private_networking = true
  monitoring = true
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key_name.id
  ]
  tags = [ digitalocean_tag.nfs-tag.id ]
  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_key)
    timeout = "2m"
  }
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Run updates
      "sudo dnf update -y"
    ]
  }
}
resource "digitalocean_droplet" "nfs-node" {
  image = "ubuntu-18-04-x64"
  name = "${var.deployment_name}-nfs"
  region = var.digitalocean_region
  size = "s-1vcpu-1gb"
  private_networking = true
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
      # Install NFS
      "sudo apt-get update",
      "sudo apt-get -y install nfs-kernel-server"
    ]
  }
}
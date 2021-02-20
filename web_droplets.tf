resource "digitalocean_droplet" "web-node-1" {
  image = "ubuntu-18-04-x64"
  name = "${var.deployment_name}-1"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key_name.id
  ]
    tags = [ digitalocean_tag.web-tag.id ]
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
      # install nginx
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }
}

resource "digitalocean_droplet" "web-node-2" {
  image = "ubuntu-18-04-x64"
  name = "${var.deployment_name}-2"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key_name.id
  ]
  tags = [ digitalocean_tag.web-tag.id ]
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
      # Install Apache
      "sudo apt-get update",
      "sudo apt-get -y install apache2",
      # Install NFS
      "sudo apt-get -y install nfs-common"
    ]
  }
}
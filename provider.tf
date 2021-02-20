terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "2.5.1"
        }
    }
}

data "digitalocean_ssh_key" "ssh_key_name" {
    name = var.key_name
}
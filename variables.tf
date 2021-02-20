# DigitalOcean general configuration.

variable "do_token" {
    description = "DigitalOcean API access token."
}
variable "private_key" {
    description = "Path to private key bound to the digitalocean_ssh_key. Used for provisioning."
    type = string
}

provider "digitalocean" {
    token = var.do_token
}

variable "digitalocean_region" {
    description = "Defines which region resources should be deployed into. Default: nyc1"
    type = string
    default = "nyc1"
}

variable "deployment_name" {
    description = "Desired prefix for infrastructure deployed."
    type = string
}

variable "key_name" {
    description = "Friendly name of the SSH key that will be deployed into droplets and used for provisioning."
    type = string
}

# DigitalOcean load balancer configuration.

variable "host_name" {
    type = string
}

# DigitalOcean database configuration.

variable "database_name" {
    description = "Desired name of the Wordpress database. Default: wordpress"
    type = string
    default = "wordpress"
}

variable "database_user" {
    description = "Desired name of the Wordpress database user. Default: wordpress"
    type = string
    default = "wordpress"
}

# DigitalOcean volume configuration.

variable "volume_size" {
    description = "Desired size of volume in gigabytes (GiB). Default: 5"
    type = number
    default = 5
}
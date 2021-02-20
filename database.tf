resource "digitalocean_database_cluster" "mysql-database" {
  name       = "${var.deployment_name}-db"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = var.digitalocean_region
  node_count = 1
}

resource "digitalocean_database_db" "database-name" {
  cluster_id = digitalocean_database_cluster.mysql-database.id
  name       = var.database_name
}

resource "digitalocean_database_user" "database-user" {
  cluster_id = digitalocean_database_cluster.mysql-database.id
  name       = var.database_user
  mysql_auth_plugin = "mysql_native_password"
}

resource "digitalocean_database_firewall" "database-firewall" {
  cluster_id = digitalocean_database_cluster.mysql-database.id

  rule {
    type  = "ip_addr"
    value = digitalocean_droplet.web-node-1.ipv4_address
  }

  rule {
    type  = "ip_addr"
    value = digitalocean_droplet.web-node-2.ipv4_address
  }
}
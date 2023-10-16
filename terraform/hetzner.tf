variable "hcloud_token" {
}

provider "hcloud" {
  token = var.hcloud_token
}

locals {
  network_range = "10.0.0.0/8"
  subnet_range  = "10.0.0.0/24"

  internal_ips = {
    # production
    "pluto" = "10.0.0.2"
  }
}

# Network
resource "hcloud_network" "internal" {
  name     = "production"
  ip_range = local.network_range
}

resource "hcloud_network_subnet" "servers" {
  network_id   = hcloud_network.internal.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = local.subnet_range
}

# Hosts
module "host" {
  source            = "./modules/hetzner_host"
  count             = 1
  name              = "pluto"
  volume_size       = 0
  server_type       = "cpx41"
  keep_disk         = false
  delete_protection = true
  network_id        = hcloud_network.internal.id
  internal_ips      = local.internal_ips
  dns_zone_ids      = module.dns_alpakabook_de.zone_id
}

# Output
output "servers" {
  value = { for a in module.host.*.attributes : a.hostname => a }
}





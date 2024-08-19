variable "name" { type = string }
variable "ssh_key_location" { type = string }
variable "server_type" { type = string }
variable "network_id" { type = string }
variable "internal_ips" { type = map(any) }
variable "extra_ports_tcp" {
  type    = list(number)
  default = []
}
variable "extra_ports_udp" {
  type    = list(number)
  default = []
}
variable "monitoring_ports" {
  type    = bool
  default = false
}
variable "delete_protection" {
  type    = bool
  default = false
}
variable "ttl" {
  type    = number
  default = 300
}

# Firewall

resource "hcloud_firewall" "firewall" {
  name = "${var.name}_firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = var.extra_ports_tcp
    content {
      direction = "in"
      protocol  = "tcp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  dynamic "rule" {
    for_each = var.extra_ports_udp
    content {
      direction = "in"
      protocol  = "udp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

# Server
resource "hcloud_server" "server" {
  name               = var.name
  image              = "debian-11"
  server_type        = var.server_type
  location           = "nbg1"
  user_data          = templatefile("${path.module}/cloud_init.tpl", { ssh_key = file(${ssh_key_location}) })
  firewall_ids       = [hcloud_firewall.firewall.id]
  backups            = false
  keep_disk          = false
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection

  network {
    network_id = var.network_id
    ip         = var.internal_ips[var.name]
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image
    ]
  }
}


output "attributes" {
  value = tomap({
    "public_ipv4"  = hcloud_server.server.ipv4_address,
    "private_ipv4" = var.internal_ips[var.name]
    "public_ipv6"  = hcloud_server.server.ipv6_address,
    "subnet_ipv6"  = hcloud_server.server.ipv6_network,
    # "volume"       = hcloud_volume.volume_0.linux_device,
    "hostname" = var.name
  })
}

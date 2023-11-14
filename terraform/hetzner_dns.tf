variable "hcloud_dns_token" {}

variable "notebooks" {}

variable "name" {}


provider "hetznerdns" {
  apitoken = var.hcloud_dns_token
}

locals {
  ttl = 300
}

# module
module "dns_zone" {
  source = "./modules/hetzner_dns_zone"
  domain = var.domain

  ipv4 = module.host[0].attributes.public_ipv4
  ipv6 = module.host[0].attributes.public_ipv6
}

# cnames
resource "hetznerdns_record" "cnames" {
  for_each = { for num in flatten(var.notebooks[*]) : num => num }

  zone_id = module.dns_zone.zone_id
  name    = each.value
  value   = "${var.domain}."
  type    = "CNAME"
  ttl     = local.ttl
}

resource "hetznerdns_record" "main_cnames" {

  zone_id = module.dns_zone.zone_id
  name    = var.name
  value   = "${var.domain}."
  type    = "CNAME"
  ttl     = local.ttl
}


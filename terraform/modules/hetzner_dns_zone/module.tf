variable "domain" {}
variable "ipv4" { default = null }
variable "ipv6" { default = null }
variable "ttl" { default = 300 }


# https://docs.hetzner.com/dns-console/dns/general/authoritative-name-servers/

resource "hetznerdns_zone" "zone" {
  name = var.domain
  ttl  = var.ttl
}

resource "hetznerdns_record" "ns1" {
  zone_id = hetznerdns_zone.zone.id
  name    = "@"
  value   = "hydrogen.ns.hetzner.com."
  type    = "NS"
  ttl     = var.ttl
}

resource "hetznerdns_record" "ns2" {
  zone_id = hetznerdns_zone.zone.id
  name    = "@"
  value   = "oxygen.ns.hetzner.com."
  type    = "NS"
  ttl     = var.ttl
}

resource "hetznerdns_record" "ns3" {
  zone_id = hetznerdns_zone.zone.id
  name    = "@"
  value   = "helium.ns.hetzner.de."
  type    = "NS"
  ttl     = var.ttl
}

resource "hetznerdns_record" "root_ipv4" {
  count   = 1
  zone_id = hetznerdns_zone.zone.id
  name    = "@"
  value   = var.ipv4
  type    = "A"
  ttl     = var.ttl
}

resource "hetznerdns_record" "root_ipv6" {
  count   = 1
  zone_id = hetznerdns_zone.zone.id
  name    = "@"
  value   = var.ipv6
  type    = "AAAA"
  ttl     = var.ttl
}

output "zone_id" {
  value = hetznerdns_zone.zone.id
}

variable "hetznerdns_token" {}


provider "hetznerdns" {
  apitoken = var.hetznerdns_token
}

locals {
  ttl = 300
}

/* ------------------------------- gueldi.dev ------------------------------- */

locals {
  alpakabook_de_cnames = {
    "001" = { subdomain = "metis" }
    "002" = { subdomain = "adrastea" }
    "003" = { subdomain = "amalthea" }
    "004" = { subdomain = "thebe" }
    "005" = { subdomain = "ganymede" }
    "006" = { subdomain = "callisto" }
    "007" = { subdomain = "themisto" }
    "008" = { subdomain = "leda" }
    "009" = { subdomain = "ersa" }
    "010" = { subdomain = "himalia" }
    "011" = { subdomain = "monitoring" }
  }
}

# module
module "dns_alpakabook_de" {
  source = "./modules/hetzner_dns_zone"
  domain = "alpakabook.de"

  ipv4 = module.host[0].attributes.public_ipv4
  ipv6 = module.host[0].attributes.public_ipv6
}

# cnames
resource "hetznerdns_record" "alpakabook_de_cname" {
  for_each = local.alpakabook_de_cnames

  zone_id = module.dns_alpakabook_de.zone_id
  name    = each.value.subdomain
  value   = "alpakabook.de."
  type    = "CNAME"
  ttl     = local.ttl
}


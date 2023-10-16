
terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.44.1"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">= 2.2.0"
    }
  }
}

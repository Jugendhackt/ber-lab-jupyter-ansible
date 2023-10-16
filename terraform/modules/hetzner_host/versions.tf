terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">= 1.1.1"
    }
  }
}

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.5.0"
    }
  }
}

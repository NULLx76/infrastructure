terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.24.1"
    }
  }
}

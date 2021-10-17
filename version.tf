terraform {
  required_providers {
    proxmox = {
      # Locally installed from git repo for LXC cloning support
      source = "registry.example.com/telmate/proxmox"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.24.1"
    }
  }
}

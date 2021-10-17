terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.8.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://10.42.42.42:8006/api2/json"
  pm_tls_insecure = true
}

# For full info see: https://blog.xirion.net/posts/nixos-proxmox-lxc/
resource "proxmox_lxc" "nixos-template" {
  target_node = "nuc"
  description = "NixOS LXC Template"
  hostname = "nixos-template"
  ostemplate = "local:vztmpl/nixos-unstable-default_156198829_amd64.tar.xz"
  ostype = "unmanaged"
  unprivileged = true

  features {
    nesting = true
  }

  rootfs {
    storage = "local-zfs"
    size = "8G"
  }

  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = "dhcp"
  }
}


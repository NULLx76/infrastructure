provider "proxmox" {
  pm_api_url      = "https://10.42.42.42:8006/api2/json"
  pm_user         = data.vault_generic_secret.proxmox_auth.data["user"]
  pm_password     = data.vault_generic_secret.proxmox_auth.data["pass"]
  pm_tls_insecure = true
}

# For full info see: https://blog.xirion.net/posts/nixos-proxmox-lxc/
resource "proxmox_lxc" "nixos-template" {
  target_node  = "nuc"
  description  = "NixOS LXC Template"
  hostname     = "nixos-template"
  ostemplate   = "local:vztmpl/nixos-unstable-default_156198829_amd64.tar.xz"
  ostype       = "unmanaged"
  unprivileged = true
  vmid         = 101
  template     = true

  memory = 1024

  features {
    nesting = true
  }

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = "22:D7:C1:FF:9D:5F"
  }
}

resource "proxmox_lxc" "nixos-template-2" {
  target_node  = "nuc"
  description  = "NixOS LXC Template"
  hostname     = "nixos-template"
  ostype       = "unmanaged"
  unprivileged = true
  vmid         = 108
  template     = true
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  features {
    nesting = true
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = "FA:71:3F:31:34:41"
  }
}

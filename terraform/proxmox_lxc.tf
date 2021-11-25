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

resource "proxmox_lxc" "vault" {
  target_node  = "nuc"
  description  = "Vault Secrets Management"
  hostname     = "vault"
  unprivileged = false # needed for mlock
  vmid         = 102
  clone        = "101"
  onboot       = true

  memory       = 1024
  
  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.vault.mac
  }
}

resource "proxmox_lxc" "mosquitto" {
  target_node  = "nuc"
  description  = "mosquitto mqtt broker"
  hostname     = "mosquitto"
  vmid         = 104
  clone        = 101
  unprivileged = true
  onboot       = true

  memory = 1024

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.mosquitto.mac
  }
}

resource "proxmox_lxc" "nginx" {
  target_node  = "nuc"
  hostname     = "nginx"
  vmid         = 106
  clone        = 101
  unprivileged = true
  onboot       = true

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.nginx.mac
  }
}

resource "proxmox_lxc" "consul" {
  target_node  = "nuc"
  description  = "consul service mesh"
  hostname     = "consul"
  vmid         = 107
  unprivileged = true
  onboot       = true

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.consul.mac
  }
}

resource "proxmox_lxc" "dns-1" {
  target_node  = "nuc"
  hostname     = "dns"
  vmid         = 109
  unprivileged = true
  onboot       = true
  startup      = "order=1"
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.dns-1.mac
  }
}

resource "proxmox_lxc" "dns-2" {
  target_node  = "nuc"
  hostname     = "dns"
  vmid         = 110
  unprivileged = true
  onboot       = true
  startup      = "order=1"
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.dns-2.mac
  }
}

resource "proxmox_lxc" "minio" {
  target_node  = "nuc"
  hostname     = "minio"
  vmid         = 111
  unprivileged = true
  onboot       = true
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = var.hosts.minio.mac
  }
}

resource "proxmox_lxc" "dhcp" {
  target_node  = "nuc"
  hostname     = "dhcp"
  vmid         = 112
  unprivileged = true
  onboot       = true
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    hwaddr = var.hosts.dhcp.mac
  }
}

resource "proxmox_lxc" "victoriametrics" {
  target_node  = "nuc"
  hostname     = "victoriametrics"
  vmid         = 113
  clone        = 108
  unprivileged = true
  onboot       = true
  cores        = 1

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "25G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    hwaddr = var.hosts.victoriametrics.mac
  }
}

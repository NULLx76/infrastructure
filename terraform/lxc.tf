resource "proxmox_lxc" "vault" {
  target_node  = "nuc"
  description  = "Vault Secrets Management"
  hostname     = "vault"
  unprivileged = false # needed for mlock
  vmid         = 102
  clone        = "101"
  memory       = 1024
  onboot       = true

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "auto"
    hwaddr = "16:2B:87:55:0C:0C"
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
    hwaddr = "C6:F9:8B:3D:9E:37"
  }
}

resource "proxmox_lxc" "nginx" {
  target_node  = "nuc"
  description  = "nginx reverse proxy"
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
    hwaddr = "6A:C2:89:85:CF:A6"
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
    hwaddr = "D6:DE:07:41:73:81"
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
    hwaddr = "D6:DE:07:41:73:81"
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
    hwaddr = "B6:04:0B:CD:0F:9F"
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
    hwaddr = "0A:06:5E:E7:9A:0C"
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
    hwaddr = "3E:2D:E8:AA:E2:81"
  }
}

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
  vmid         = "101"
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
    hwaddr = "22:D7:C1:FF:9D:5F"
  }
}

resource "proxmox_lxc" "vault" {
  target_node  = "nuc"
  description  = "Vault Secrets Management"
  hostname     = "vault"
  unprivileged = false # needed for mlock
  vmid         = "102"
  clone        = "101"

  memory = 1024

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
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

  memory = 1024

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
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

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    hwaddr = "6A:C2:89:85:CF:A6"
  }
}

resource "proxmox_vm_qemu" "k3s-node1" {
  name        = "k3s-node1"
  target_node = "nuc"
  vmid        = 103
  clone       = "bastion"
  tablet      = false

  memory = 8192
  cores  = 4

  agent = 1
  boot  = "order=scsi0;ide2;net0"

  network {
    model   = "virtio"
    macaddr = "2E:F8:55:23:D9:9B"
    bridge  = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "local-zfs"
    size    = "64G"
    ssd     = 1
  }
}

resource "proxmox_lxc" "consul" {
  target_node  = "nuc"
  description  = "consul service mesh"
  hostname     = "consul"
  vmid         = 107
  clone        = 101
  unprivileged = true

  memory = 512

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    hwaddr = "D6:DE:07:41:73:81"
  }
}

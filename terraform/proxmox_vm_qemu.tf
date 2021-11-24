resource "proxmox_vm_qemu" "bastion" {
  name        = "bastion"
  vmid        = 100
  target_node = "nuc"
  onboot      = true
  tablet      = false
  full_clone  = false

  memory = 4096
  cores  = 4

  agent = 1
  boot  = "order=scsi0;ide2;net0"

  disk {
    size    = "64G"
    storage = "local-zfs"
    type    = "scsi"
    ssd     = 1
  }

  network {
    model   = "virtio"
    macaddr = var.hosts.bastion.mac
    bridge  = "vmbr0"
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
    macaddr = var.hosts.k3s-node1.mac
    bridge  = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "local-zfs"
    size    = "64G"
    ssd     = 1
  }
}

resource "proxmox_vm_qemu" "home-assistant" {
  name        = "home-assistant"
  vmid        = 105
  target_node = "nuc"
  onboot      = true
  tablet      = false
  full_clone  = false
  bios        = "ovmf"

  memory = 2048
  cores  = 4

  agent = 1
  boot  = "order=sata0"

  network {
    model   = "virtio"
    macaddr = var.hosts.home-assistant.mac
    bridge  = "vmbr0"
  }
}

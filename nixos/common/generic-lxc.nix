{ ... }: {
  # See also: https://blog.xirion.net/posts/nixos-proxmox-lxc/

  # Supress systemd services that don't work (correctly) on LXC
  systemd.suppressedSystemUnits = [ "dev-mqueue.mount" "sys-kernel-debug.mount" "sys-fs-fuse-connections.mount" ];
}

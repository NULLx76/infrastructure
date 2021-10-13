{ ... }: {
  # See also: https://blog.xirion.net/posts/nixos-proxmox-lxc/

  # Import nixos lxc config
  imports = [
    <nixpkgs/nixos/modules/virtualisation/lxc-container.nix>
  ];

  # Supress systemd services that don't work (correctly) on LXC
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  # Enable SSH daemon support.
  services.openssh.enable = true;
}

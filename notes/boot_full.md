# NixOS /boot full

If `/boot` is full run the following commands:

```
sudo nix-collect-garbage -d
nix-env -p /mnt/nix/var/nix/profiles/system --delete-generations +2
sudo nixos-rebuild boot --flake '.#eevee'
```

This should delete the older generations and free up some space

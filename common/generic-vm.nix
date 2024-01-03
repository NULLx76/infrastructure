{ lib, ... }: {
  networking.useDHCP = lib.mkDefault true;

  # Enable qemu guest agent
  services.qemuGuest.enable = true;
}

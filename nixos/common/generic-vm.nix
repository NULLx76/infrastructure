{ lib, ... }: {
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  # Enable qemu guest agent
  services.qemuGuest.enable = true;
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z
    ./hardware.nix
  ];

  # Bootloader.
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    resumeDevice = "/dev/nvme0n1p2";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.victor = import ./home;
    extraSpecialArgs = { inherit inputs; };
  };

  # Enable Ozone rendering for Chromium and Electron apps.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # environment.sessionVariables.INFRA_INFO = self; # hosts.${config.networking.domain}.${config.networking.hostName};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

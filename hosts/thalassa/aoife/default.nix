# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z
    ./hardware.nix
    ./uni.nix
  ];

  meta = {
    mac = "04:7b:cb:b6:2d:88";
    isLaptop = true;
  };

  users.users.vivian.extraGroups = [ "adbusers" ];



  # Bootloader.
  boot = {
    bootspec.enable = true;
    initrd.kernelModules = [ "amdgpu" ];
    resumeDevice = "/dev/nvme0n1p2";
    loader.systemd-boot.enable = lib.mkForce false;

    kernelPackages = pkgs.linuxPackages_6_6;

    kernel.sysctl = {
      "perf_event_paranoid" = 1;
      "kptr_restrict" = 0;
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 5;
      pkiBundle = "/etc/secureboot";
    };
  };

  home-manager.users.vivian = import ./home;

  # Enable Ozone rendering for Chromium and Electron apps.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.vault-secrets.nixosModules.vault-secrets
    # User account definitions
    ./users
    ./services
  ];

  # Clean /tmp on boot.
  boot.cleanTmpDir = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  # Nix Settings
  nix = {
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "victor" ];
      substituters = [
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-review-bot.cachix.org"
        "https://colmena.cachix.org"
        "https://hyprland.cachix.org"
        "https://0x76-infra.cachix.org"
        "https://webcord.cachix.org"
      ];
      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-review-bot.cachix.org-1:eppgiDjPk7Hkzzz7XlUesk3rcEHqNDozGOrcLc8IqwE="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "0x76-infra.cachix.org-1:dC1qp+VEN3jj5pdK4URlXR9hf3atT+MnpKGu6PZjMc8="
        "webcord.cachix.org-1:l555jqOZGHd2C9+vS8ccdh8FhqnGe8L78QrHNn+EFEs="
      ];
    # Also use zsh for root;
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Limit the systemd journal to 100 MB of disk or the
  # last 7 days of logs, whichever happens first.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  # Enable SSH daemon support.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  vault-secrets = lib.mkIf (config.networking.domain == "olympus") {
    vaultPrefix = "olympus_secrets/nixos";
    vaultAddress = "http://vault.olympus:8200/";
    approlePrefix = "olympus-${config.networking.hostName}";
  };
}

{ config, pkgs, inputs, ... }:

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
  time.timeZone = "Europe/Amsterdam";

  # Nix Settings
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "victor" ];
      substituters = [
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-review-bot.cachix.org"
        "https://colmena.cachix.org"
      ];
      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-review-bot.cachix.org-1:eppgiDjPk7Hkzzz7XlUesk3rcEHqNDozGOrcLc8IqwE="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      ];
    };
    gc = {
      dates = "weekly";
      automatic = true;
      randomizedDelaySec = "45min";
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

  # TODO: Location dependent
  vault-secrets = {
    vaultPrefix = "secrets/nixos";
    vaultAddress = "http://vault.olympus:8200/";
    approlePrefix = "olympus-${config.networking.hostName}";
  };
}

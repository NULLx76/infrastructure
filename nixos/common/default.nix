{ lib, pkgs, inputs, config, ... }: {
  imports =
    [ ./users ./modules inputs.vault-secrets.nixosModules.vault-secrets ];

  vault-secrets =
    let
      inherit (config.networking) domain hostName;
      server = if domain == "olympus" then "vault" else "vault-0";
    in
    lib.mkIf (domain == "olympus" || domain == "hades") {
      vaultPrefix = "${domain}_secrets/nixos";
      vaultAddress = "http://${server}.${domain}:8200/";
      approlePrefix = "${domain}-${hostName}";
    };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ ./hm-modules inputs.nixvim.homeManagerModules.nixvim ];
  };

  virtualisation.oci-containers.backend = lib.mkDefault "podman";

  # Clean /tmp on boot.
  boot.tmp.cleanOnBoot = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  # Systemd OOMd
  # Fedora enables these options by default. See the 10-oomd-* files here:
  # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
  systemd.oomd = {
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # security.polkit.enable = lib.mkDefault true;
  boot.tmp.useTmpfs = lib.mkDefault true;

  # Nix Settings
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "vivian" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://nixpkgs-review-bot.cachix.org"
        "https://colmena.cachix.org"
        # "https://cache.garnix.io"
        "https://cachix.cachix.org"
      ];
      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-review-bot.cachix.org-1:eppgiDjPk7Hkzzz7XlUesk3rcEHqNDozGOrcLc8IqwE="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "3h";
      options = "--delete-older-than 7d";
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

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  # Debloat
  documentation = {
    enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
    man.enable = lib.mkForce false;
    info.enable = lib.mkForce false;
    nixos.enable = lib.mkForce false;
  };
}

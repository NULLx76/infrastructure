{ lib, inputs, pkgs, ... }: {
  imports = [
    ./users
    ./modules
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ ./hm-modules inputs.nixvim.homeManagerModules.nixvim ];
  };

  virtualisation.oci-containers.backend = lib.mkDefault "podman";

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
        "https://cachix.cachix.org"
      ];
      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-review-bot.cachix.org-1:eppgiDjPk7Hkzzz7XlUesk3rcEHqNDozGOrcLc8IqwE="
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

  # Limit the systemd journal to 100 MB of disk or the
  # last 7 days of logs, whichever happens first.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  services.dbus.implementation = "broker";

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

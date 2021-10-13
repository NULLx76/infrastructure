{ pkgs, ... }:

{
  imports = [
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
    autoOptimiseStore = true;
    binaryCaches = [
      "https://cachix.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-review-bot.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-review-bot.cachix.org-1:eppgiDjPk7Hkzzz7XlUesk3rcEHqNDozGOrcLc8IqwE="
    ];
    trustedUsers = [ "root" "victor" ];
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
}

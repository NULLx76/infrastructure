# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, ... }:
let
  # Redefining the package instead of overriding as overriding GoModules seems broken
  # see: https://github.com/NixOS/nixpkgs/issues/86349
  nuclei-latest = pkgs.buildGoModule rec {
    pname = "nuclei";
    version = "2.9.2";

    src = pkgs.fetchFromGitHub {
      owner = "projectdiscovery";
      repo = pname;
      rev = "1f9a065713924b28b203e2108fc76d7a1ec49068";
      hash = "sha256-QiegMoBy0gZMyQl2MRAwR14zXeh8wvVonyETdAzHbj0=";
    };

    vendorHash = "sha256-0JNwoBqLKH1F/0Tr8o35gCSNT/2plIjIQvZRuzAZ5P8=";

    modRoot = "./v2";
    subPackages = [ "cmd/nuclei/" ];

    doCheck = false;
  };
in {
  imports = [ ./hardware-configuration.nix ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ jq wget jre8 ];
  boot.loader = {

    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
  };

  users.extraUsers.laura.extraGroups = [ "wheel" ];
  users.extraUsers.vivian.extraGroups = [ "wheel" ];
  users.groups.mc = { };

  users.extraUsers.julia = {
    isNormalUser = true;
    shell = pkgs.zsh;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTvqk+CJG4VwN8wg3H1ZdbUVj1JuX7RYKH1ewRKfCPv julia@juliadijkstraarch"
          # Below is Evelyn's key
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnZSVdqSybDwVooSZ+SGFM0YNu15sO/jgVqCBGDm33wj0fML5T4oviUrY6yABh+eAgy/NAztgM7+6L8Hlze5DBeMwNAvj9gr9QSzUetW0iqCscZJ8dDbW30O9449gw2JY/XZzcFMZAP5QEQGEgG/6QQ3yRwA3DMCsGhQQ37l/aS+RsKYq3ZSN4f1nFJCrm397QB8r+bhaexufXqwumxe8rlefoUNNVnmu54FA8Pc3jSdsWT4s/3mqF6NiRa53w13SBWyS+zopCy1tTSnRszgAkldpE7Vft/QnmpFavAWHzpfArv/uFXQ3fx5Cj5t70zB6VJEtaBxhdKXeQUFBCn7fmwfjV0Un9b8jLW94uDhDD3059trhMvJvqKebuqyZe74MTZH0IC3IobpSb9fHHvxuRwUQOMkkJmjv1p2y2R6v7s2tA1sZlIEBmRDvZcKo4hPBe6q13OePV3O8KAFzCmPBIfE6kQ/nLc+3k9OjFWFTshdDXUYpSVGjNrv/IanCXbEs="
        ];

    extraGroups = [ "mc" "wheel" ];
  };
}

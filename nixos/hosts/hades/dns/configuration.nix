{ pkgs, ... }: {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ dig dogdns ];

  services.v.dns = {
    enable = true;
    openFirewall = true;
    mode = "server";
  };

  services.unbound.settings.server = {
    local-zone = [
      "xirion.net typetransparent"
      "attic.xirion.net typetransparent"
      "o.xirion.net typetransparent"
      "attic.xirion.net typetransparent"
      "g.xirion.net typetransparent"
      "fedi-media.xirion.net typetransparent"
      "hades.xirion.net typetransparent"
      "requests.xirion.net typetransparent"
      "ha.xirion.net typetransparent"
      "mail.xirion.net typetransparent"
      "plex.xirion.net typetransparent"
      "fedi.xirion.net typetransparent"
      "grist.tud.0x76.dev typetransparent"
      "dex.tud.0x76.dev typetransparent"
    ];

    local-data = [
      ''"xirion.net A 192.168.0.122"''
      ''"attic.xirion.net A 192.168.0.122"''
      ''"hades.xirion.net A 192.168.0.122"''
      ''"o.xirion.net A 192.168.0.122"''
      ''"attic.xirion.net A 192.168.0.122"''
      ''"g.xirion.net A 192.168.0.122"''
      ''"fedi-media.xirion.net A 192.168.0.122"''
      ''"requests.xirion.net A 192.168.0.122"''
      ''"ha.xirion.net A 192.168.0.122"''
      ''"mail.xirion.net A 192.168.0.122"''
      ''"plex.xirion.net A 192.168.0.122"''
      ''"fedi.xirion.net A 192.168.0.122"''
      ''"grist.tud.0x76.dev A 192.168.0.122"''
      ''"dex.tud.0x76.dev A 192.168.0.122"''
    ];
  };
}

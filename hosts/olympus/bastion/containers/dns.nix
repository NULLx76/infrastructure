{ ... }: {
  imports = [ ./common.nix ];
  services.v.dns = {
    enable = true;
    openFirewall = true;
    mode = "server";
  };
}

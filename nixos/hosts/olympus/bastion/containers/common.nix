# common container config
{ lib, ... }: {
  # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  networking.useHostResolvConf = lib.mkForce false;
  services.resolved.enable = true;
}

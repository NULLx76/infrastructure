# common container config
{ lib, home-manager, ... }: {
  imports = [
    # ../../../../common/modules
    home-manager.nixosModules.home-manager # TODO: I don't like this
  ];
  # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  networking.useHostResolvConf = lib.mkForce false;
  services.resolved.enable = true;

  system.stateVersion = lib.mkDefault "24.05";
}

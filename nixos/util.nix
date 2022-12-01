{ nixpkgs, home-manager, hyprland, mailserver, ... }:
let
  inherit (builtins) filter attrValues concatLists;

  # Helper function to resolve what should be imported depending on the type of config (lxc, vm, bare metal)
  resolve_imports =
    let
      # lookup table
      import_cases = {
        "lxc" = [
          "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          ./common/generic-lxc.nix
        ];
        "vm" = [
          ./common/generic-vm.nix
        ];
        "local" = [
          hyprland.nixosModules.default
        ];
      };
    in
    { hostname, realm, profile ? hostname, type ? "lxc", ... }: [
      home-manager.nixosModules.home-manager
      mailserver.nixosModules.mailserver
      ./common
      "${./.}/hosts/${realm}/${profile}/configuration.nix"
    ] ++ import_cases.${type};
in
{
  # Add to whatever realm a host belong to its list of tags
  add_realm_to_tags = realm: map ({ tags ? [ ], ... }@host: host // { tags = [ realm ] ++ tags; inherit realm; });
  # Flatten all hosts to a single list
  flatten_hosts = hosts: concatLists (attrValues hosts);
  # Filter out all hosts which aren't nixos
  filter_nix_hosts = filter ({ nix ? true, ... }: nix);

  # Helper function to build a colmena host definition
  mkColmenaHost = { ip ? null, hostname, tags, realm, type ? "lxc", ... }@host:
    let
      # this makes local apply work a bit nicer
      name = if realm == "thalassa" then hostname else "${hostname}.${realm}";
    in
    {
      "${name}" = {
        imports = resolve_imports host;
        networking = {
          hostName = hostname;
          domain = realm;
        };
        deployment = {
          inherit tags;
          targetHost = ip;
          allowLocalDeployment = type == "local";
          targetUser = null; # Defaults to $USER
        };
      };
    };
}

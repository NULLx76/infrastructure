{ nixpkgs, home-manager, ... }:
let
  inherit (nixpkgs) lib;
  inherit (builtins) filter mapAttrs attrValues concatLists;
  import_cases = {
    "lxc" = [
      "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
      ./nixos/common/generic-lxc.nix
    ];
    "vm" = [
      ./nixos/common/generic-vm.nix
    ];
    "local" = [
      home-manager.nixosModules.home-manager
    ];
  };
  resolve_imports = { hostname, realm, profile ? hostname, type ? "lxc", ... }: [
    ./nixos/common
    "${./.}/nixos/hosts/${realm}/${profile}/configuration.nix"
  ] ++ import_cases.${type};
in
rec {
  add_realm_to_tags = realm: hosts: map ({ tags ? [ ], ... }@host: host // { tags = [ realm ] ++ tags; inherit realm; }) hosts;
  flatten_hosts = hosts: concatLists (attrValues hosts);
  filter_nix_hosts = hosts: filter ({ nix ? true, ... }: nix) hosts;

  mkNixosSystem = specialArgs: { hostname, realm, system ? "x86_64-linux", ... }@host: {
    "${hostname}.${realm}" = lib.nixosSystem {
      inherit system specialArgs;
      modules = resolve_imports host;
    };
  };

  mkColmenaHost = { ip ? null, hostname, tags, realm, type ? "lxc", ... }@host: {
    "${hostname}.${realm}" = {
      imports = resolve_imports host;
      networking = {
        hostName = hostname;
        domain = realm;
      };
      deployment = {
        inherit tags;
        targetHost = ip;
        allowLocalDeployment = (type == "local");
        targetUser = null; # Defaults to $USER
      };
    };
  };

  mkNixosConfigurations = specialArgs: hosts: lib.foldr (el: acc: acc // mkNixosSystem specialArgs el) { } hosts;
}

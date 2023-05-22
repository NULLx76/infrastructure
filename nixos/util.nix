{ nixpkgs, home-manager, mailserver, ... }:
let
  inherit (builtins) filter attrValues concatMap mapAttrs;
  inherit (nixpkgs.lib.attrsets) mapAttrsToList;
  base_imports = [
    home-manager.nixosModules.home-manager
    mailserver.nixosModules.mailserver
  ];
  type_import = let
    import_cases = {
      "lxc" = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./common/generic-lxc.nix
      ];
      "vm" = [ ./common/generic-vm.nix ];
      "local" = [ ./common/desktop ];
    };
  in type: import_cases.${type} ++ base_imports;
  # Helper function to resolve what should be imported depending on the type of config (lxc, vm, bare metal)
  resolve_imports = { hostname, realm, profile ? hostname, type ? "lxc", ... }:
    type_import type
    ++ [ ./common "${./.}/hosts/${realm}/${profile}/configuration.nix" ];

  # Add to whatever realm a host belong to its list of tags
  add_realm_to_tags = mapAttrs (realm:
    mapAttrs (_hostname:
      { type ? "lxc", tags ? [ ], ... }@host:
      host // {
        # Tags are for deployment, so don't add them to local machines
        tags = tags ++ (if type == "local" then [ ] else [ realm ]);
        inherit realm;
      }));

  # Flatten all hosts to a single list
  flatten_hosts = realms:
    concatMap (mapAttrsToList (name: value: value // { hostname = name; }))
    (attrValues realms);

  # Filter out all hosts which aren't nixos
  filter_nix_hosts = filter ({ nix ? true, ... }: nix);

  # outputs

  # Helper function to build a colmena host definition
  mkColmenaHost = { ip ? null, exposes ? null, hostname, tags, realm
    , type ? "lxc", ... }@host:
    let
      # this makes local apply work a bit nicer
      name = if type == "local" then hostname else "${hostname}.${realm}";
    in {
      "${name}" = {
        imports = resolve_imports host;
        networking = {
          hostName = hostname;
          domain = realm;
        };
        meta = {
          inherit exposes;
          ipv4 = ip;
        };
        deployment = {
          inherit tags;
          targetHost = ip;
          allowLocalDeployment = type == "local";
          targetUser = null; # Defaults to $USER
        };
      };
    };
  hosts = add_realm_to_tags (import ./hosts);
  flat_hosts = flatten_hosts hosts;
  nixHosts = filter_nix_hosts flat_hosts;
in { inherit base_imports mkColmenaHost hosts flat_hosts nixHosts; }

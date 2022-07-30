{
  description = "Delft Deployment";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    serokell-nix.url = "github:serokell/serokell.nix";
    serokell-nix.inputs.nixpkgs.follows = "nixpkgs";

    vault-secrets.url = "github:serokell/vault-secrets";
    vault-secrets.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-servers.url = "github:jyooru/nix-minecraft-servers";
    minecraft-servers.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, vault-secrets, serokell-nix, minecraft-servers, colmena, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) filter mapAttrs attrValues concatLists;
      system = "x86_64-linux";
      # import and add location qualifier to all hosts
      hosts = mapAttrs (location: lhosts: map ({ tags ? [ ], ... }@x: x // { tags = [ location ] ++ tags; inherit location; }) lhosts) (import ./nixos/hosts);
      # flatten hosts to single list
      flat_hosts = concatLists (attrValues hosts);
      # Filter all nixos host definitions that are actual nix machines
      nixHosts = filter ({ nix ? true, ... }: nix) flat_hosts;
      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { inherit hosts flat_hosts inputs; };

      # Resolve imports based on a foldername (nixname) and if the host is an LXC container or a VM.
      resolveImports = { hostname, location, profile ? hostname, lxc ? true, ... }: [
        ./nixos/common
        "${./.}/nixos/hosts/${location}/${profile}/configuration.nix"
      ] ++ (if lxc then [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./nixos/common/generic-lxc.nix
      ]
      else [ ./nixos/common/generic-vm.nix ]);

      mkConfig = { hostname, ... }@host: {
        "${hostname}" = lib.nixosSystem {
          inherit system specialArgs;
          modules = resolveImports host;
        };
      };

      mkColmenaHost = { ip, hostname, tags, ... }@host: {
        "${hostname}" = {
          imports = resolveImports host;
          deployment = {
            inherit tags;
            targetHost = ip;
            targetUser = null; # Defaults to $USER
          };
        };
      };

      pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system} [ vault-secrets.overlay ];
    in
    {
      # Make the config and deploy sets
      nixosConfigurations = lib.foldr (el: acc: acc // mkConfig el) { } nixHosts;

      colmena = lib.foldr (el: acc: acc // mkColmenaHost el)
        {
          meta = {
            nixpkgs = import nixpkgs {
              inherit system;
              overlays = [
                (import ./nixos/pkgs)
                minecraft-servers.overlays.default
              ];
            };
            inherit specialArgs;
          };
        }
        nixHosts;

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        # This only support bash so just execute zsh in bash as a workaround :/
        shellHook = "zsh; exit $?";
        buildInputs = with pkgs; [
          fluxcd
          k9s
          kubectl
          kubectx
          terraform
          nixfmt
          nixUnstable
          vault
          (vault-push-approle-envs self)
          (vault-push-approle-approles self)
        ];
      };
    };
}

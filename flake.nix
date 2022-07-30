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
    { self, nixpkgs, vault-secrets, serokell-nix, minecraft-servers, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) filter mapAttrs;
      system = "x86_64-linux";
      hosts = import ./hosts.nix;

      # TODO: consolidate with mkColmenaHost
      # Create a nixosConfiguration based on a foldername (nixname) and if the host is an LXC container or a VM.
      mkConfig = { hostname, profile ? hostname, lxc ? true, ... }: {
        "${profile}" = lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/common
            "${./.}/nixos/hosts/${profile}/configuration.nix"
          ] ++ (if lxc then [
            "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
            ./nixos/common/generic-lxc.nix
          ] else
            [ ./nixos/common/generic-vm.nix ]);
          specialArgs = { inherit hosts inputs; };
        };
      };

      # Import all nixos host definitions that are actual nix machines
      nixHosts = filter ({ nix ? true, ... }: nix) hosts;

      mkColmenaHost = { ip, hostname, profile ? hostname, lxc ? true, ... }: {
        "${hostname}" = {
          imports = [
            vault-secrets.nixosModules.vault-secrets
            ./nixos/common
            "${./.}/nixos/hosts/${profile}/configuration.nix"
          ] ++ (if lxc then [
            "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
            ./nixos/common/generic-lxc.nix
          ] else [ ./nixos/common/generic-vm.nix ]);

          deployment = {
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
              system = "x86_64-linux";
              overlays = [
                (import ./nixos/pkgs)
                vault-secrets.overlay
                minecraft-servers.overlays.default
              ];
            };
            specialArgs = {
              inherit hosts;
            };
          };
        }
        nixHosts;

      apps.${system} = rec {
        vault-push-approles = {
          type = "app";
          program = "${pkgs.vault-push-approles self}/bin/vault-push-approles";
        };
        vault-push-approle-envs = {
          type = "app";
          program =
            "${pkgs.vault-push-approle-envs self}/bin/vault-push-approle-envs";
        };
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        # This only support bash so just execute zsh in bash as a workaround :/
        shellHook = "zsh; exit $?";
        buildInputs = with pkgs; [
          colmena
          fluxcd
          k9s
          kubectl
          kubectx
          terraform
          nixfmt
          nixUnstable
          vault
        ];
      };
    };
}

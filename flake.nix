{
  description = "Delft Deployment";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    serokell-nix.url = "github:serokell/serokell.nix";
    vault-secrets.url = "github:serokell/vault-secrets";
  };

  outputs =
    { self, nixpkgs, deploy-rs, vault-secrets, serokell-nix, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) filter mapAttrs;
      system = "x86_64-linux";
      hosts = import ./hosts.nix;

      # Create a nixosConfiguration based on a foldername (nixname) and if the host is an LXC container or a VM.
      mkConfig = { hostname, profile ? hostname, lxc ? true, ... }: {
        "${profile}" = lib.nixosSystem {
          inherit system;
          modules =
            [ ./nixos/common "${./.}/nixos/hosts/${profile}/configuration.nix" ]
            ++ (if lxc then [
              "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
              ./nixos/common/generic-lxc.nix
            ] else
              [ ./nixos/common/generic-vm.nix ]);
          specialArgs = { inherit hosts inputs; };
        };
      };

      # Same as above, but for the nodes part of deploy.
      mkDeploy = { ip, hostname, profile ? hostname, ... }: {
        "${hostname}" = {
          hostname = ip;
          fastConnection = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos
              self.nixosConfigurations.${profile};
          };
        };
      };

      # Import all nixos host definitions that are actual nix machines
      nixHosts = filter ({ nix ? true, ... }: nix) hosts;

      pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system} [ vault-secrets.overlay ];

      deployChecks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
      checks = { };
    in {
      # Make the config and deploy sets
      nixosConfigurations = lib.foldr (el: acc: acc // mkConfig el) { } nixHosts;
      deploy.nodes = lib.foldr (el: acc: acc // mkDeploy el) { } nixHosts;

      apps.x86_64-linux.vault-push-approles = {
        type = "app";
        program = "${pkgs.vault-push-approles self}/bin/vault-push-approles";
      };
      apps.x86_64-linux.vault-push-approle-envs = {
        type = "app";
        program =
          "${pkgs.vault-push-approle-envs self}/bin/vault-push-approle-envs";
      };

      # Use by running `nix develop`
      devShell.${system} = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        # This only support bash so just execute zsh in bash as a workaround :/
        buildInputs = with pkgs; [
          deploy-rs.packages.${system}.deploy-rs
          fluxcd
          k9s
          kubectl
          kubectx
          terraform
          nixfmt
          nixUnstable
          vault
          (vault-push-approles self { })
          (vault-push-approle-envs self { })
        ];
      };

      checks = lib.recursiveUpdate deployChecks checks;
    };
}

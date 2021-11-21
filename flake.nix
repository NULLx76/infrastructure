{
  description = "Delft Deployment";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    serokell-nix.url = "github:serokell/serokell.nix";
    vault-secrets.url = "github:serokell/vault-secrets";
  };

  outputs =
    { self, nixpkgs, deploy-rs, vault-secrets, serokell-nix, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) filter;
      system = "x86_64-linux";
      merge = a: b: a // b;

      # Create a nixosConfiguration based on a foldername (nixname) and if the host is an LXC container or a VM.
      mkConfig = nixname: lxc:
        lib.nixosSystem {
          inherit system;
          modules =
            [ "${./.}/nixos/hosts/${nixname}/configuration.nix" ./nixos/common ]
            ++ (if lxc then [
              "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
              ./nixos/common/generic-lxc.nix
            ] else
              [ ./nixos/common/generic-vm.nix ]);
          specialArgs.inputs = inputs;
        };

      # Create a deploy-rs config based on profile- and hostname.
      mkDeploy = hostname: profile: {
        inherit hostname;
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.${profile};
        };
      };

      # Convert a host from hosts.nix to something nixosConfigurations understands
      hostToConfig = { hostname, nixname ? hostname, lxc ? true, ... }:
        merge {
          "${nixname}" = mkConfig nixname lxc;
        };

      # Same as above, but for the nodes part of deploy.
      hostToDeploy = { ip, hostname, nixname ? hostname, ... }:
        merge {
          "${nixname}" = mkDeploy ip nixname;
        };

      # Import all nixos host definitions that are actual nix machines
      nixHosts = filter ({ nix ? true, ... }: nix) (import ./nixos/hosts.nix);
    in {
      # Make the config and deploy sets
      nixosConfigurations = lib.foldr hostToConfig { } nixHosts;
      deploy.nodes = lib.foldr hostToDeploy { } nixHosts;

      # Use by running `nix develop`
      devShell.${system} = let
        pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system}
          [ vault-secrets.overlay ];
      in pkgs.mkShell {
        VAULT_ADDR = "http://10.42.42.6:8200/";
        buildInputs = with pkgs; [
          deploy-rs.packages.${system}.deploy-rs
          fluxcd
          k9s
          kubectl
          kubectx
          nixfmt
          nixUnstable
          vault
          (vault-push-approle-envs self)
          (vault-push-approles self)
        ];
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

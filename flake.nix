{
  description = "Delft Deployment";

  # Based on: https://github.com/serokell/pegasus-infra/blob/master/flake.nix

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    serokell-nix.url = "github:serokell/serokell.nix";
    vault-secrets.url = "github:serokell/vault-secrets";
  };

  outputs =
    { self, nixpkgs, deploy-rs, vault-secrets, serokell-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      mkSystem = { host, lxc ? true }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/${host}/configuration.nix ] ++ (if lxc then
            [ "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix" ]
          else
            [ ]);
          specialArgs.inputs = inputs;
        };
      mkDeploy = hostname: profile: {
        hostname = hostname;
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${profile};
        };
      };
    in {
      # VMs
      nixosConfigurations.bastion = mkSystem { host = "bastion"; lxc = false; };
      nixosConfigurations.k3s = mkSystem { host = "k3s"; lxc = false; };

      # LXCs
      nixosConfigurations.vault = mkSystem { host = "vault"; };
      nixosConfigurations.mosquitto = mkSystem { host = "mosquitto"; };
      nixosConfigurations.nginx = mkSystem { host = "nginx"; };
      nixosConfigurations.consul = mkSystem { host = "consul"; };

      # Deploys 
      deploy.nodes.bastion = mkDeploy "10.42.42.4" "bastion";
      deploy.nodes.k3s-node1 = mkDeploy "10.42.42.10" "k3s";
      deploy.nodes.vault = mkDeploy "10.42.42.6" "vault";
      deploy.nodes.mosquitto = mkDeploy "10.42.42.7" "mosquitto";
      deploy.nodes.nginx = mkDeploy "10.42.42.9" "nginx";
      deploy.nodes.consul = mkDeploy "10.42.42.14" "consul";

      # Use by running `nix develop`
      devShell.${system} = let
        pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system}
          [ vault-secrets.overlay ];
      in pkgs.mkShell {
        buildInputs = [
          deploy-rs.packages.${system}.deploy-rs
          pkgs.vault
          (pkgs.vault-push-approle-envs self)
          (pkgs.vault-push-approles self)
          pkgs.nixUnstable
        ];
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

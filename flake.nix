{
  description = "Delft Deployment";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    serokell-nix.url = "github:serokell/serokell.nix";
    vault-secrets.url = "github:serokell/vault-secrets";
  };

  outputs = { self, nixpkgs, deploy-rs, vault-secrets, serokell-nix, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.bastion = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/bastion/configuration.nix ];
      };

      nixosConfigurations.k3s = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/k3s/configuration.nix ];
      };

      nixosConfigurations.vault = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          ./hosts/vault/configuration.nix
        ];
      };

      nixosConfigurations.mosquitto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          ./hosts/mosquitto/configuration.nix
        ];
      };

      nixosConfigurations.nginx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          ./hosts/nginx/configuration.nix
        ];
      };

      nixosConfigurations.consul = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          ./hosts/consul/configuration.nix
        ];
      };

      deploy.nodes.bastion = {
        hostname = "10.42.42.4";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.bastion;
        };
      };

      deploy.nodes.k3s-node1 = {
        hostname = "10.42.42.10";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.k3s;
        };
      };

      deploy.nodes.vault = {
        hostname = "10.42.42.6";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.vault;
        };
      };

      deploy.nodes.mosquitto = {
        hostname = "10.42.42.7";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.mosquitto;
        };
      };

      deploy.nodes.nginx = {
        hostname = "10.42.42.9";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.nginx;
        };
      };

      deploy.nodes.consul = {
        hostname = "10.42.42.14";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.consul;
        };
      };

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

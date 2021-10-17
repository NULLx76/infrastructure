{
  description = "Delft Deployment";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs = { self, nixpkgs, deploy-rs }: {
    nixosConfigurations.bastion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/bastion/configuration.nix ];
    };

    nixosConfigurations.vault = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix" ./hosts/vault/configuration.nix ];
    };

    deploy.nodes.bastion = {
      hostname = "localhost";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bastion;
      };
    };

    deploy.nodes.vault = {
      hostname = "10.42.42.6";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vault;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

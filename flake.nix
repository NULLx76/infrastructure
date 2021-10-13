{
  description = "Delft Deployment";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs = { self, nixpkgs, deploy-rs }: {
    nixosConfigurations.bastion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/bastion/configuration.nix ];
    };

    deploy.nodes.bastion = { 
      hostname = "localhost";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bastion;
      };

    };

  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };

}

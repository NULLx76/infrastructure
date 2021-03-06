{
  description = "Delft Deployment";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    serokell-nix.url = "github:serokell/serokell.nix";
    serokell-nix.inputs.nixpkgs.follows = "nixpkgs";
    serokell-nix.inputs.deploy-rs.follows = "deploy-rs";

    vault-secrets.url = "github:serokell/vault-secrets";
    vault-secrets.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-servers.url = "github:jyooru/nix-minecraft-servers";
    minecraft-servers.inputs.nixpkgs.follows = "nixpkgs";
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

      # Same as above, but for the nodes part of deploy.
      mkDeploy = { ip, hostname, profile ? hostname, ... }: {
        "${hostname}" = {
          hostname = ip;
          fastConnection = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${profile};
          };
        };
      };

      # Generates hosts.auto.tfvars.json for Terraform
      genTFVars =
        let
          hostToVar = z@{ hostname, mac, ... }: {
            "${hostname}" = { inherit mac; };
          };
          hostSet = lib.foldr (el: acc: acc // hostToVar el) { } hosts;
          json = builtins.toJSON { hosts = hostSet; };
        in
        pkgs.writeScriptBin "gen-tf-vars" ''
          echo '${json}' | ${pkgs.jq}/bin/jq > terraform/hosts.auto.tfvars.json;
          echo "Generated Terraform Variables";
        '';

      # Import all nixos host definitions that are actual nix machines
      nixHosts = filter ({ nix ? true, ... }: nix) hosts;

      pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system} [ vault-secrets.overlay ];

    in
    {
      # Make the config and deploy sets
      nixosConfigurations = lib.foldr (el: acc: acc // mkConfig el) { } nixHosts;
      deploy.nodes = lib.foldr (el: acc: acc // mkDeploy el) { } nixHosts;


      apps.${system} = rec {
        default = deploy;
        deploy = {
          type = "app";
          program = "${deploy-rs.packages.${system}.deploy-rs}/bin/deploy";
        };
        vault-push-approles = {
          type = "app";
          program = "${pkgs.vault-push-approles self}/bin/vault-push-approles";
        };
        vault-push-approle-envs = {
          type = "app";
          program =
            "${pkgs.vault-push-approle-envs self}/bin/vault-push-approle-envs";
        };
        tfvars = {
          type = "app";
          program = "${genTFVars}/bin/gen-tf-vars";
        };
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        # This only support bash so just execute zsh in bash as a workaround :/
        shellHook = "zsh; exit $?";
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
          # (vault-push-approles self { })
          # (vault-push-approle-envs self { })
          genTFVars
        ];
      };

      # Filter out non-system checks: https://github.com/NixOS/nixpkgs/issues/175875#issuecomment-1152996862
      checks = lib.filterAttrs
        (a: _: a == system)
        (builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib);
    };
}

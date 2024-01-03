{
  description = "0x76's infrastructure";

  # For minecraft use:
  # * https://github.com/Infinidoge/nix-minecraft

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs_stable.url = "nixpkgs/nixos-23.05";
    nur.url = "github:nix-community/NUR";
    colmena.url = "github:zhaofengli/colmena";
    deploy.url = "github:serokell/deploy-rs";
    vault-secrets.url = "github:serokell/vault-secrets";

    microvm.url = "github:astro/microvm.nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    riff.url = "github:DeterminateSystems/riff";

    webcord.url = "github:fufexan/webcord-flake";

    comma.url = "github:nix-community/comma";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:pta2002/nixvim";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vault-unseal.url = "git+https://git.0x76.dev/v/vault-unseal.git";
    gnome-autounlock-keyring.url =
      "git+https://git.0x76.dev/v/gnome-autounlock-keyring.git";

    attic.url = "github:zhaofengli/attic";

    # Website(s)
    essentials.url = "github:jdonszelmann/essentials";
  };

  outputs = { self, nixpkgs, nixpkgs_stable, vault-secrets, colmena, nur, attic
    , deploy, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./nixos/pkgs) vault-secrets.overlay nur.overlay ];
      };

      pkgs_stable = import nixpkgs_stable {
        inherit system;
        config.allowUnfree = true;
      };

      # Script to apply local colmena deployments
      apply-local = pkgs.writeShellScriptBin "apply-local" ''
        "${
          colmena.packages.${system}.colmena
        }"/bin/colmena apply-local --sudo $@
      '';

      fast-repl = pkgs.writeShellScriptBin "fast-repl" ''
        source /etc/set-environment
        nix repl --file "${./.}/repl.nix" $@
      '';
    in {
      nixosConfigurations."bastion.olympus" = lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs; };
        modules = [ ./common ./common/generic-vm.nix ./hosts/olympus/bastion ];
      };

      deploy = {
        user = "root";

        nodes."bastion.olympus" = {
          hostname = "olympus.0x76.dev";
          fastConnection = true;
          remoteBuild = true;
          profiles = {
            system = {
              path = deploy.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations."bastion.olympus";
            };
          };
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy.lib;

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        packages = with pkgs; [
          attic.packages.${pkgs.system}.attic
          apply-local
          deploy.packages.${system}.deploy-rs
          deadnix
          statix
          # nixfmt
          # nixpkgs-fmt
          nixUnstable
          # nil
          vault
          yamllint
          jq
          # (vault-push-approle-envs self { })
          # (vault-push-approles self { })
          fast-repl
        ];
      };
    };
}

{
  description = "0x76's infrastructure";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:NULLx76/nixpkgs/0x76";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    vault-secrets.url = "github:serokell/vault-secrets";
    vault-secrets.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-servers.url = "github:jyooru/nix-minecraft-servers";
    minecraft-servers.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";

    riff.url = "github:DeterminateSystems/riff";
    riff.inputs.nixpkgs.follows = "nixpkgs";

    webcord.url = "github:fufexan/webcord-flake";

    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vault-secrets, minecraft-servers, colmena
    , home-manager, hyprpaper, hyprland, nixos-generators, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) mapAttrs;

      util = import ./nixos/util.nix inputs;

      system = "x86_64-linux";
      # import and add realm to list of tags
      hosts = mapAttrs util.add_realm_to_tags (import ./nixos/hosts);
      # flatten hosts to single list
      flat_hosts = util.flatten_hosts hosts;
      # Filter out all non-nixos hosts
      nixHosts = util.filter_nix_hosts flat_hosts;

      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { inherit hosts flat_hosts inputs; };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./nixos/pkgs)
          vault-secrets.overlay
          minecraft-servers.overlays.default
          hyprpaper.overlays.default
          hyprland.overlays.default
        ];
      };

      # Script to apply local colmena deployments
      apply-local = pkgs.writeScriptBin "apply-local" ''
        #!${pkgs.stdenv.shell}
        "${
          colmena.packages.${system}.colmena
        }"/bin/colmena apply-local --sudo $@
      '';
    in {
      # Make the nixosConfigurations for compat reasons
      nixosConfigurations =
        (import (inputs.colmena + "/src/nix/hive/eval.nix") {
          rawFlake = self;
          colmenaOptions =
            import (inputs.colmena + "/src/nix/hive/options.nix");
          colmenaModules =
            import (inputs.colmena + "/src/nix/hive/modules.nix");
        }).nodes;

      # Make the colmena configuration
      colmena = lib.foldr (el: acc: acc // util.mkColmenaHost el) {
        meta = {
          inherit specialArgs;
          nixpkgs = pkgs;
        };
      } nixHosts;

      packages.${system} = {
        inherit apply-local;

        default = colmena.packages.${system}.colmena;

        iso = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "iso";
          modules = [ (import ./nixos/iso.nix) ];
        };

        proxmox-lxc = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "proxmox-lxc";
          modules = [ (import ./nixos/proxmox-lxc.nix) ];
        };
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        buildInputs = with pkgs; [
          apply-local
          colmena.packages.${system}.colmena
          cachix
          fluxcd
          k9s
          kubectl
          kubectx
          terraform
          nixfmt
          nixUnstable
          vault
          (vault-push-approle-envs self { })
          (vault-push-approles self { })
          rnix-lsp
        ];
      };
    };
}

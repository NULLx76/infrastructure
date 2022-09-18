{
  description = "0x76's infrastructure";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    serokell-nix.url = "github:serokell/serokell.nix";
    serokell-nix.inputs.nixpkgs.follows = "nixpkgs";

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
  };

  outputs =
    { self
    , nixpkgs
    , vault-secrets
    , serokell-nix
    , minecraft-servers
    , colmena
    , home-manager
    , hyprpaper
    , hyprland
    , ...
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) filter mapAttrs attrValues concatLists;

      util = import ./util.nix inputs;

      system = "x86_64-linux";
      # import and add realm to list of tags
      hosts = mapAttrs util.add_realm_to_tags (import ./nixos/hosts);
      # flatten hosts to single list
      flat_hosts = util.flatten_hosts hosts;
      # Filter out all non-nixos hosts
      nixHosts = util.filter_nix_hosts flat_hosts;

      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { inherit hosts flat_hosts inputs; };
      pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system} [
        (import ./nixos/pkgs)
        vault-secrets.overlay
        minecraft-servers.overlays.default
        hyprpaper.overlays.default
        hyprland.overlays.default
      ];

      # Script to apply local colmena deployments
      apply-local = pkgs.writeScriptBin "apply-local" ''
        #!${pkgs.stdenv.shell}
        "${colmena.packages.${system}.colmena}"/bin/colmena apply-local --sudo $@
      '';
    in
    {
      # Make the nixosConfigurations for compat reasons
      nixosConfigurations = (import (inputs.colmena + "/src/nix/hive/eval.nix") {
        rawFlake = self;
        colmenaOptions = import (inputs.colmena + "/src/nix/hive/options.nix");
        colmenaModules = import (inputs.colmena + "/src/nix/hive/modules.nix");
      }).nodes;


      # Make the coleman configuration
      colmena = lib.foldr (el: acc: acc // util.mkColmenaHost el)
        {
          meta = {
            inherit specialArgs;
            nixpkgs = pkgs;
          };
        }
        nixHosts;

      packages.${system} = {
        default = colmena.packages.${system}.colmena;
        apply-local = apply-local;
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        buildInputs = with pkgs; [
          apply-local
          colmena.packages.${system}.colmena
          fluxcd
          k9s
          kubectl
          kubectx
          terraform
          nixfmt
          nixUnstable
          vault
          # (vault-push-approle-envs self)
          # (vault-push-approle-approles self)
        ];
      };
    };
}

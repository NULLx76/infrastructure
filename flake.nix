{
  description = "Delft Deployment";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

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
  };

  outputs =
    { self, nixpkgs, vault-secrets, serokell-nix, minecraft-servers, colmena, home-manager, hyprpaper, hyprland, riff, ... }@inputs:
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
        "${colmena.packages.x86_64-linux.colmena}"/bin/colmena apply-local --sudo $@
      '';
    in
    {
      # Make the nixosConfigurations, mostly for vault-secrets
      nixosConfigurations = util.mkNixosConfigurations specialArgs nixHosts;

      # Make the coleman configuration
      colmena = lib.foldr (el: acc: acc // util.mkColmenaHost el)
        {
          meta = {
            inherit specialArgs;
            nixpkgs = pkgs;
          };
        }
        nixHosts;

      packages.x86_64-linux.default = colmena.packages.x86_64-linux.colmena;
      packages.x86_64-linux.apply-local = apply-local;

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        buildInputs = with pkgs; [
          apply-local
          colmena.packages.x86_64-linux.colmena
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

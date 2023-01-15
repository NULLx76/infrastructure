{
  description = "0x76's infrastructure";

  # Based on: 
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs_22-11.url = "github:nixos/nixpkgs/872973d7d1a71570dee1e9c1114e13a072bf3ffc";

    nur.url = "github:nix-community/NUR";

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

    riff.url =
      "github:DeterminateSystems/riff/cole/ds-285-use-rustup-based-rustc-and-cargo";
    riff.inputs.nixpkgs.follows = "nixpkgs";

    webcord.url = "github:fufexan/webcord-flake";

    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:pta2002/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs_22-11
    , vault-secrets
    , minecraft-servers
    , colmena
    , home-manager
    , hyprpaper
    , hyprland
    , nixos-generators
    , nixos-hardware
    , nur
    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      util = import ./nixos/util.nix inputs;

      system = "x86_64-linux";
      # import and add realm to list of tags
      hosts = util.add_realm_to_tags (import ./nixos/hosts);
      # flatten hosts to single list
      flat_hosts = util.flatten_hosts hosts;
      # Filter out all non-nixos hosts
      nixHosts = util.filter_nix_hosts flat_hosts;

      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { 
        inherit hosts flat_hosts inputs; 
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./nixos/pkgs)
          vault-secrets.overlay
          minecraft-servers.overlays.default
          hyprpaper.overlays.default
          hyprland.overlays.default
          nur.overlay
        ];
      };

      pkgs_22-11 = import nixpkgs_22-11 {
        inherit system;
        config.allowUnfree = true;
      };

      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { inherit hosts flat_hosts inputs pkgs_22-11; };

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
    in
    {
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
      colmena = lib.foldr (el: acc: acc // util.mkColmenaHost el)
        {
          meta = {
            inherit specialArgs;
            nixpkgs = pkgs;
          };
        }
        nixHosts;

      packages.${system} = {
        inherit apply-local;

        default = colmena.packages.${system}.colmena;

        iso = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "iso";
          modules = [ (import ./nixos/templates/iso.nix) ];
        };

        iso-graphical = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "iso";
          modules = [ (import ./nixos/templates/iso-graphical.nix) ];
        };

        proxmox-lxc = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "proxmox-lxc";
          modules = [ (import ./nixos/templates/proxmox-lxc.nix) ];
        };

        # Currently broken as it assumes `local-lvm` exists
        proxmox-vm = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "proxmox";
          modules = [ (import ./nixos/templates/proxmox-vm.nix) ];
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
          statix
          terraform
          nixfmt
          nixUnstable
          vault
          (vault-push-approle-envs self { })
          (vault-push-approles self { })
          fast-repl
        ];
      };
    };
}

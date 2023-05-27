{
  description = "0x76's infrastructure";

  # Based on:
  # * https://github.com/serokell/pegasus-infra/blob/master/flake.nix
  # * https://git.voidcorp.nl/j00lz/nixos-configs/src/branch/main/flake.nix

  # For minecraft use:
  # * https://github.com/Infinidoge/nix-minecraft

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs_22-11.url = "github:nixos/nixpkgs/nixos-22.11";

    nur.url = "github:nix-community/NUR";

    colmena.url = "github:zhaofengli/colmena";

    vault-secrets.url = "github:serokell/vault-secrets";

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

    nixos-hardware.url = "github:toastal/nixos-hardware/z-series-no-hidpi";

    vault-unseal.url = "git+https://git.0x76.dev/v/vault-unseal.git";
  };

  outputs = { self, nixpkgs, nixpkgs_22-11, vault-secrets, colmena
    , nixos-generators, nur, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      util = import ./nixos/util.nix inputs;
      inherit (util) hosts flat_hosts nixHosts;

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./nixos/pkgs) vault-secrets.overlay nur.overlay ];
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
    in {
      # Make the nixosConfigurations for compat reasons (e.g. vault)
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
          format = "install-iso";
          modules = [ (import ./nixos/templates/iso.nix) ];
        };

        iso-graphical = nixos-generators.nixosGenerate {
          inherit system pkgs;
          format = "install-iso";
          modules = [ (import ./nixos/templates/iso-graphical.nix) ];
        };

        proxmox-lxc = nixos-generators.nixosGenerate {
          inherit pkgs;
          format = "proxmox-lxc";
          modules = util.base_imports
            ++ [ (import ./nixos/templates/proxmox-lxc.nix) ];
        };

        # Broken
        # proxmox-vm = nixos-generators.nixosGenerate {
        #   inherit system pkgs;
        #   format = "proxmox";
        #   modules = util.base_imports
        #     ++ [ (import ./nixos/templates/proxmox-vm.nix) ];
        # };
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        buildInputs = with pkgs; [
          apply-local
          colmena.packages.${system}.colmena
          cachix
          deadnix
          fluxcd
          k9s
          kubectl
          kubectx
          statix
          terraform
          nixfmt
          nixUnstable
          nil
          vault
          yamllint
          jq
          (vault-push-approle-envs self { })
          (vault-push-approles self { })
          fast-repl
          v.weave-gitops
        ];
      };
    };
}

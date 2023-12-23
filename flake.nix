{
  description = "0x76's infrastructure";

  # For minecraft use:
  # * https://github.com/Infinidoge/nix-minecraft

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    nixpkgs_stable.url = "nixpkgs/nixos-23.05";
    nur.url = "github:nix-community/NUR";
    colmena.url = "github:zhaofengli/colmena";
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
    gnome-autounlock-keyring.url = "git+https://git.0x76.dev/v/gnome-autounlock-keyring.git";

    attic.url = "github:zhaofengli/attic";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs_stable
    , vault-secrets
    , colmena
    , nixos-generators
    , nur
    , attic
    , microvm
    , ...
    }@inputs:
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

      pkgs_stable = import nixpkgs_stable {
        inherit system;
        config.allowUnfree = true;
      };

      # Define args each module gets access to (access to hosts is useful for DNS/DHCP)
      specialArgs = { inherit hosts flat_hosts inputs pkgs_stable; };

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

        proxmox-lxc = nixos-generators.nixosGenerate {
          inherit system specialArgs;
          format = "proxmox-lxc";
          modules = util.base_imports
            ++ [ (import ./nixos/templates/proxmox-lxc.nix) ];
        };

        # Broken
        proxmox-vm = nixos-generators.nixosGenerate {
          inherit system specialArgs;
          format = "proxmox";
          modules = util.base_imports
            ++ [ (import ./nixos/templates/proxmox-vm.nix) ];
        };
      };

      # Use by running `nix develop`
      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://vault.olympus:8200/";
        buildInputs = with pkgs; [
          attic.packages.${pkgs.system}.attic
          apply-local
          colmena.packages.${system}.colmena
          cachix
          deadnix
          statix
          nixfmt
          nixpkgs-fmt
          nixUnstable
          nil
          vault
          yamllint
          jq
          (vault-push-approle-envs self { })
          (vault-push-approles self { })
          fast-repl
        ];
      };
    };
}

{
  description = "0x76's infrastructure";

  # For minecraft use:
  # * https://github.com/Infinidoge/nix-minecraft

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    # nixpkgs_stable.url = "nixpkgs/nixos-23.05";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";

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

  outputs = { self, nixpkgs, flake-utils-plus, nur, attic
    , deploy, home-manager, gnome-autounlock-keyring, lanzaboote, ... }@inputs:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      apply-local = pkgs.writeShellScriptBin "apply-local" ''
        deploy ".#$(cat /etc/hostname)" -s
      '';
    in flake-utils-plus.lib.mkFlake {
      # `self` and `inputs` arguments are required
      inherit self inputs;

      # Supported systems, used for packages, apps, devShell and multiple other definitions. Defaults to `flake-utils.lib.defaultSystems`.
      supportedSystems = [ "x86_64-linux" ];

      # Channels config
      channelsConfig = { allowUnfree = true; };
      sharedOverlays = [ (import ./pkgs) nur.overlay ];

      # host defaults
      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          gnome-autounlock-keyring.nixosModules.default
          ./common
        ];

        specialArgs = { inherit self inputs; };
      };

      # hosts
      hosts = {
        # TODO: Figure out why this is reversed, and how/why it sets the FQDN
        "olympus.bastion" = {
          modules = [ ./common/generic-vm.nix ./hosts/olympus/bastion ];
        };

        aoife = {
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./common/desktop
            ./hosts/thalassa/aoife
          ];
        };
      };

      # deploy-rs
      deploy = {
        user = "root";
        nodes = {
          "bastion-olympus" = {
            hostname = "bastion.olympus";
            fastConnection = true;
            remoteBuild = true;
            profiles = {
              system = {
                path = deploy.lib.x86_64-linux.activate.nixos
                  self.nixosConfigurations."olympus.bastion";
              };
            };
          };

          aoife = {
            remoteBuild = true;
            fastConnection = true;
            hostname = "aoife";
            profiles.system.path = deploy.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.aoife;
          };
        };
      };

      # Outputs
      outputsBuilder = channels: {
        devShells.default = channels.nixpkgs.mkShell {
          name = "devShell";
          VAULT_ADDR = "http://vault.olympus:8200/";
          packages = with pkgs; [
            attic.packages.${system}.attic
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
            # fast-repl
            fup-repl
          ];
        };
      };

      # Checks
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy.lib // {
          x86_64-linux.mac = pkgs.stdenvNoCC.mkDerivation {
            name = "mac check";
            src = self;
            dontBuild = true;
            doCheck = true;
            checkPhase = ''
              echo "Hello World"
            '';
            installPhase = "mkdir $out";
          };
        };
    };
}

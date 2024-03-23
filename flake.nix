{
  description = "0x76's infrastructure";

  # For minecraft use:
  # * https://github.com/Infinidoge/nix-minecraft

  inputs = {
    nixpkgs.url = "nixpkgs/master";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";

    nur.url = "github:nix-community/NUR";
    colmena.url = "github:zhaofengli/colmena";
    deploy.url = "github:serokell/deploy-rs";
    vault-secrets.url = "github:serokell/vault-secrets";

    microvm.url = "github:astro/microvm.nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    comma.url = "github:nix-community/comma";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:pta2002/nixvim";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    vault-unseal.url = "git+https://git.0x76.dev/v/vault-unseal.git";
    vault-unseal.inputs.nixpkgs.follows = "nixpkgs";

    gnome-autounlock-keyring.url = "git+https://git.0x76.dev/v/gnome-autounlock-keyring.git";
    gnome-autounlock-keyring.inputs.nixpkgs.follows = "nixpkgs";

    t.url = "github:jdonszelmann/t-rs";
    t.inputs.nixpkgs.follows = "nixpkgs";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";

    # Website(s)
    essentials.url = "github:jdonszelmann/essentials";
    essentials.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils-plus,
      nur,
      attic,
      deploy,
      home-manager,
      gnome-autounlock-keyring,
      lanzaboote,
      t,
      ...
    }@inputs:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      apply-local = pkgs.writeShellScriptBin "apply-local" ''
        nh os switch --ask
      '';
    in
    flake-utils-plus.lib.mkFlake {
      # `self` and `inputs` arguments are required
      inherit self inputs;

      # Supported systems, used for packages, apps, devShell and multiple other definitions. Defaults to `flake-utils.lib.defaultSystems`.
      supportedSystems = [ "x86_64-linux" ];

      # Channels config
      channelsConfig = {
        allowUnfree = true;
      };
      sharedOverlays = [
        (import ./pkgs)
        nur.overlay
      ];

      # host defaults
      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          gnome-autounlock-keyring.nixosModules.default
          ./common
        ];

        specialArgs = {
          inherit self inputs home-manager;
        };
      };

      # hosts
      hosts = {
        # TODO: Figure out why this is reversed, and how/why it sets the FQDN
        "olympus.bastion" = {
          modules = [
            ./common/generic-vm.nix
            ./hosts/olympus/bastion
          ];
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
                path = deploy.lib.x86_64-linux.activate.nixos self.nixosConfigurations."olympus.bastion";
              };
            };
          };

          aoife = {
            remoteBuild = true;
            fastConnection = true;
            hostname = "aoife";
            profiles.system.path = deploy.lib.x86_64-linux.activate.nixos self.nixosConfigurations.aoife;
          };
        };
      };

      # Outputs
      outputsBuilder = channels: {
        devShells.default = channels.nixpkgs.mkShell {
          name = "devShell";
          VAULT_ADDR = "http://vault.olympus:8200/";
          FLAKE = "/home/vivian/src/infrastructure-new";
          packages = with pkgs; [
            attic.packages.${system}.attic
            apply-local
            deploy.packages.${system}.deploy-rs
            deadnix
            statix
            nixUnstable
            vault
            yamllint
            jq
            fup-repl
            nh
          ];
        };
      };

      # Checks
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy.lib // {
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

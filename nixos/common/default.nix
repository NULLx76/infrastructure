{ inputs, lib, config, ... }: {
  # This file deals with everything requiring `inputs`, the rest being delagated to `common.nix`
  # this is because we can't import inputs from all contexts as that can lead to infinite recursion.
  imports = [
    ./common.nix
    inputs.vault-secrets.nixosModules.vault-secrets
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  nix.registry.nixpkgs.flake =  inputs.nixpkgs;

  vault-secrets = let
    inherit (config.networking) domain hostName;
    server = if domain == "olympus" then "vault" else "vault-0";
  in lib.mkIf (domain == "olympus" || domain == "hades") {
    vaultPrefix = "${domain}_secrets/nixos";
    vaultAddress = "http://${server}.${domain}:8200/";
    approlePrefix = "${domain}-${hostName}";
  };
}

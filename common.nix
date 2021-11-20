{ config, inputs, ... }:
{
    imports = [
        inputs.vault-secrets.nixosModules.vault-secrets
    ];

    vault-secrets = {
        vaultPrefix = "nixos/${config.networking.hostName}";
        vaultAddress = "http://10.42.42.6:8200/";
        approlePrefix = "olympus-${config.networking.hostName}";
    };
}

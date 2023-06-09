{ vscode-utils }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;
in buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "platformio-ide";
    publisher = "platformio";
    version = "3.1.1";
    sha256 = "sha256-g9yTG3DjVUS2w9eHGAai5LoIfEGus+FPhqDnCi4e90Q=";
    # sha256 = lib.fakeSha256;
  };
}

{ vscode-utils, lib }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;
in buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "platformio-ide";
    publisher = "platformio";
    version = "3.1.1";
    sha256 = "sha256-fwEct7Tj8bfTOLRozSZJGWoLzWRSvYz/KxcnfpO8Usg=";
    # sha256 = lib.fakeSha256;
  };
}

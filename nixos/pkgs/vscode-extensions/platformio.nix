{ vscode-utils, lib }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;
in buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "platformio-ide";
    publisher = "platformio";
    version = "2.5.4";
    sha256 = "sha256-/vBdZ6Mu1KlF+glqp5CNt9WeK1ECqfaivCnK8TisChg";
  };
}

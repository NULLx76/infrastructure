{ vscode-utils, lib }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;
in buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "platformio-ide";
    publisher = "platformio";
    version = "2.5.4";
    sha256 = "sha256-KbXlegQSLjMCVotR1mU/CDiaQMKLLSX+nnbRJgdFTz8=";
  };
}

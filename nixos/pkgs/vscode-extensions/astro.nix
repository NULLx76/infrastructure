{ vscode-utils, lib }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;
in buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "astro-vscode";
    publisher = "astro-build";
    version = "0.5.2022102001";
    sha256 = lib.fakeSha256;
  };
}

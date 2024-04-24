{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.v.rust;
in
{
  options.programs.v.rust.enable = mkEnableOption "rust";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        rustup
        cargo-binutils
        cargo-nextest
        cargo-msrv
        cargo-dist
        cargo-cross
      ];

      file.".cargo/config.toml".text = ''
        [registries.crates-io]
        protocol = "sparse"

        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        [profile.rust-analyzer]
        inherits = "dev"
      '';

        # [target.'cfg(not(target_arch = "mips"))']
        # linker = "${pkgs.clang}/bin/clang"
        # rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"]



      sessionPath = [ "$HOME/.cargo/bin" ];
    };
  };
}

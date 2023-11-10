{ pkgs, lib, config, ... }:
with lib;
let cfg = config.programs.v.rust;
in {
  options.programs.v.rust = { enable = mkEnableOption "rust"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ rustup ];

    home.file = {
      ".cargo/config.toml".text = ''
        [registries.crates-io]
        protocol = "sparse"

        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      '';
    };

    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}

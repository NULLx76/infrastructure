{ pkgs, lib, config, ... }:
with lib;
let cfg = config.programs.v.rust;
in {
  options.programs.v.rust = { enable = mkEnableOption "rust"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ rustup cargo-nextest cargo-msrv  ];

      file = {
        ".cargo/config.toml".text = ''
          [registries.crates-io]
          protocol = "sparse"

          [build]
          rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        '';
      };

      sessionPath = [ "$HOME/.cargo/bin" ];
    };
  };
}

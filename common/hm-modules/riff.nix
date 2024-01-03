{ config, pkgs, lib, inputs, ... }:
with lib;
let cfg = config.programs.riff;
in {
  options.programs.riff = {
    enable = mkEnableOption "riff";
    direnv = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable direnv support
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ inputs.riff.packages.${pkgs.system}.riff ];

    xdg.configFile."direnv/lib/riff.sh" = mkIf cfg.direnv {
      executable = true;
      text = ''
        use_riff() {
          watch_file Cargo.toml watch_file Cargo.lock
          eval "$(riff --offline print-dev-env)"
        }
      '';
    };
  };
}

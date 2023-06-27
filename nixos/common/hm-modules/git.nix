{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs.v.git;
in {
  options.programs.v.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Victor";
      userEmail = "victor@xirion.net";
      lfs.enable = true;
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "main";
        # Git merge driver that always grabs upstream changes
        # Useful for e.g. lock files
        merge.ours = {
          name = "Overwrite Upstream Changes";
          driver = "cp -f '%A' '%B'";
        };
      };

      difftastic.enable = true;
    };

    home.file.".config/git/attributes".text = ''
      flake.lock merge=ours
    '';
  };
}

{ config, pkgs, lib, ... }:
with lib;
let cfg = config.themes.v.catppuccin;
in {
  options.themes.v.catppuccin = { enable = mkEnableOption "catppuccin"; };
  config = let
    theme = "Catppuccin-Frappe-Pink-Dark";
    cursorTheme = config.home.pointerCursor.name;
  in mkIf cfg.enable {
    home.pointerCursor = {
      name = "Bibata_Ghost";
      size = 24;
      package = pkgs.bibata-cursors-translucent;
    };

    gtk = {
      enable = true;
      theme = {
        name = theme;
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          variant = "frappe";
          size = "standard";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme.override { color = "violet"; };
      };
      cursorTheme = {
        name = cursorTheme;
        inherit (config.home.pointerCursor) package size;
      };
    };

    programs.vscode = {
      userSettings."workbench.colorTheme" = "Catppuccin Frappé";
      extensions = [ pkgs.vscode-extensions.catppuccin.catppuccin-vsc ];
    };
  };
}


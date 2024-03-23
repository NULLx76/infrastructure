{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.themes.v.catppuccin;
in
{
  options.themes.v.catppuccin = {
    enable = mkEnableOption "catppuccin";
  };
  config = mkIf cfg.enable {
    home.pointerCursor = {
      name = "Bibata_Ghost";
      size = 24;
      package = pkgs.bibata-cursors-translucent;
    };

    programs.kitty = {
      theme = "Catppuccin-Frappe";
      font.name = "DejaVuSansMono Nerd Font";
    };

    # home.sessionVariables.GTK_USE_PORTAL = "1";

    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-Frappe-Standard-Pink-Dark";
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
        inherit (config.home.pointerCursor) name package size;
      };
    };

    xdg.configFile = {
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    };

    qt = {
      enable = true;
      platformTheme = "qtct";
      style = {
        name = "Catppuccin-Frappe-Pink";
        package = pkgs.catppuccin-kde.override {
          flavour = [ "frappe" ];
          accents = [ "pink" ];
        };
      };
    };

    programs.vscode = {
      userSettings."workbench.colorTheme" = "Catppuccin Frappé";
      extensions = [ pkgs.vscode-extensions.catppuccin.catppuccin-vsc ];
    };
  };
}

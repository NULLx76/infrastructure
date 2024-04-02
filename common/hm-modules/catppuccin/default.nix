{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.themes.v.catppuccin;
  mako = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "mako";
    rev = "9dd088aa5f4529a3dd4d9760415e340664cb86df";
    sha256 = "sha256-nUzWkQVsIH4rrCFSP87mXAka6P+Td2ifNbTuP7NM/SQ=";
  };
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

    qt = {
      enable = true;
      platformTheme = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Catppuccin-Frappe-Pink
      '';
    };

    home.packages = with pkgs; [
      (catppuccin-kvantum.override {
        accent = "Pink";
        variant = "Frappe";
      })
    ];

    programs.mako.extraConfig = builtins.readFile "${mako}/src/frappe";

    programs.vscode = {
      userSettings."workbench.colorTheme" = "Catppuccin Frappé";
      extensions = [ pkgs.vscode-extensions.catppuccin.catppuccin-vsc ];
    };
  };
}

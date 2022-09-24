{ lib, pkgs, config, ... }:
let
  inherit (builtins) mapAttrs;

  theme = "Catppuccin-Pink-Dark";
  cursorTheme = config.home.pointerCursor.name;
  colour = rec {
    rosewater = "f2d5cf";
    flamingo = "eebebe";
    pink = "f4b8e4";
    mauve = "ca9ee6";
    red = "e78284";
    maroon = "ea999c";
    peach = "ef9f76";
    yellow = "e5c890";
    green = "a6d189";
    teal = "81c8be";
    sky = "99d1db";
    sapphire = "85c1dc";
    blue = "8caaee";
    lavender = "babbf1";
    text = "c6d0f5";
    subtext0 = "a5adce";
    subtext1 = "b5bfe2";
    overlay2 = "949cbb";
    overlay0 = "737994";
    overlay1 = "838ba7";
    surface0 = "414559";
    surface1 = "51576d";
    surface2 = "626880";
    base = "303446";
    mantle = "292c3c";
    crust = "232634";

    hex = mapAttrs (name: value: "#${value}") colour;
  };
in
{
  home.file.".xsettingsd".text = ''
    Net/ThemeName "${theme}"
    Gtk/CursorThemeName "${cursorTheme}"
  '';

  home.pointerCursor = {
    name = "Catppuccin-Frappe-Pink-Cursors";
    size = 32;
    package = pkgs.catppuccin.cursors;
  };

  gtk = {
    enable = true;
    theme = {
      name = theme;
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    cursorTheme = {
      name = cursorTheme;
      package = config.home.pointerCursor.package;
      size = config.home.pointerCursor.size;
    };
  };

  # Note, pink and blue are switched
  programs.foot.settings.colors = {
    alpha = 0.8;

    foreground = colour.text; # Text
    background = colour.base; # Base
    regular0 = colour.surface1; # Surface 1
    regular1 = colour.red; # red
    regular2 = colour.green; # green
    regular3 = colour.yellow; # yellow
    regular4 = colour.pink; # pink
    regular5 = colour.blue; # blue
    regular6 = colour.teal; # teal
    regular7 = colour.subtext1; # Subtext 1
    bright0 = colour.surface2; # Surface 2
    bright1 = colour.red; # red
    bright2 = colour.green; # green
    bright3 = colour.yellow; # yellow
    bright4 = colour.pink; # pink
    bright5 = colour.blue; # blue
    bright6 = colour.teal; # teal
    bright7 = colour.subtext0; # Subtext 0
  };

  programs.mako = {
    backgroundColor = colour.hex.mantle;
    borderColor = colour.hex.pink;
    textColor = colour.hex.text;
    borderRadius = 5;
  };

  home.file.".config/eww/eww.scss".text = lib.mkBefore ''
    $rosewater: ${colour.hex.rosewater};
    $flamingo: ${colour.hex.flamingo};
    $pink: ${colour.hex.pink};
    $mauve: ${colour.hex.mauve};
    $red: ${colour.hex.red};
    $maroon: ${colour.hex.maroon};
    $peach: ${colour.hex.peach};
    $yellow: ${colour.hex.yellow};
    $green: ${colour.hex.green};
    $teal: ${colour.hex.teal};
    $sky: ${colour.hex.sky};
    $sapphire: ${colour.hex.sapphire};
    $blue: ${colour.hex.blue};
    $lavender: ${colour.hex.lavender};
    $text: ${colour.hex.text};
    $subtext0: ${colour.hex.subtext0};
    $subtext1: ${colour.hex.subtext1};
    $overlay0: ${colour.hex.overlay0};
    $overlay1: ${colour.hex.overlay1};
    $overlay2: ${colour.hex.overlay2};
    $surface0: ${colour.hex.surface0};
    $surface1: ${colour.hex.surface1};
    $surface2: ${colour.hex.surface2};
    $base: ${colour.hex.base};
    $mantle: ${colour.hex.mantle};
    $crust: ${colour.hex.crust};
  '';
}

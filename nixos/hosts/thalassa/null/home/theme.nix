{ ... }:
let
  # Catpuccin Frappe Pink
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
    subtext1 = "b5bfe2";
    subtext0 = "a5adce";
    overlay2 = "949cbb";
    overlay1 = "838ba7";
    overlay0 = "737994";
    surface2 = "626880";
    surface1 = "51576d";
    surface0 = "414559";
    base = "303446";
    mantle = "292c3c";
    crust = "232634";

    hex = builtins.mapAttrs (name: value: "#${value}") colour;
  };
in
{
  # Note, pink and blue are switched
  programs.foot.settings.colors = {
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
}

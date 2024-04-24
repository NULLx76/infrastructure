{ pkgs, config, ...}:
let
  starshipNerdFont = pkgs.runCommand "starship-nerd-font.toml" { STARSHIP_CACHE = "/tmp"; } ''
    ${config.programs.starship.package}/bin/starship preset nerd-font-symbols > $out
  '';
in{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;

    settings = {
      nix_shell.heuristic = true;
    } // builtins.fromTOML (builtins.readFile starshipNerdFont);
  };
}

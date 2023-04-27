{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs.v.vscode;
in {
  options.programs.v.vscode = { enable = mkEnableOption "vscode"; };
  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      userSettings = {
        "ltex.language" = "en-GB";
        "latex-workshop.linting.chktex.enabled" = true;
        "latex-workshop.latex.clean.subfolder.enabled" = true;
        "latex-workshop.latex.outDir" = "%TMPDIR%/%RELATIVE_DOC%";
        "editor.fontFamily" =
          "'DejaVuSansMono Nerd Font', 'monospace', monospace";
        "keyboard.dispatch" = "keyCode";
        "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "nix.enableLanguageServer" = true; # Enable LSP.
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "[nix]" = { "editor.defaultFormatter" = "brettm12345.nixfmt-vscode"; };
        "rust-analyzer.checkOnSave.command" = "clippy";
        "debug.allowBreakpointsEverywhere" = true;
        # Don't index unecessary things
        "files.exclude" = {
          "**/.vscode" = true;
          "**/.git" = true;
          "**/.svn" = true;
          "**/.hg" = true;
          "**/.deps" = true;
          "**/CVS" = true;
          "**/.DS_Store" = true;
          "/bin" = true;
          "/boot" = true;
          "/cdrom" = true;
          "/dev" = true;
          "/proc" = true;
          "/etc" = true;
          "/nix" = true;
        };
      };
      extensions = with pkgs.vscode-extensions;
        with pkgs.v.vscode-extensions; [
          brettm12345.nixfmt-vscode
          codezombiech.gitignore
          editorconfig.editorconfig
          foxundermoon.shell-format
          james-yu.latex-workshop
          jnoortheen.nix-ide
          matklad.rust-analyzer
          mkhl.direnv
          ms-vscode-remote.remote-ssh
          ms-vscode.cpptools
          platformio.platformio-ide
          redhat.vscode-yaml
          tamasfe.even-better-toml
          valentjn.vscode-ltex
          vscodevim.vim
          vadimcn.vscode-lldb
          xaver.clang-format
          sumneko.lua
        ];
    };

  };
}


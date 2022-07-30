# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
let
  fix-vscode = pkgs.writeScriptBin "fix-vscode" ''
    #!${pkgs.stdenv.shell}
    # Check if vscode-server dir exists
    if [[ -d "$HOME/.vscode-server/bin" ]]; then
      # For every bin folder within
      for versiondir in "$HOME"/.vscode-server/bin/*; do
        # Remove bundled node (dynamic links are borked for nix)
        rm "$versiondir/node"
        # symlink node form the nixpkg
        ln -s "${pkgs.nodejs-16_x}/bin/node" "$versiondir/node"
      done
    fi
  '';
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "bastion";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  virtualisation.podman = {
    enable = true;
  };

  # Additional packages
  environment.systemPackages = with pkgs; [
    binutils
    colmena
    fix-vscode
    fluxcd
    k9s
    kubectl
    kubectx
    nix-prefetch-git
    nixpkgs-fmt
    nixpkgs-review
    ripgrep
    rnix-lsp
    rsync
    tmux
    vault
    vim
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };
}

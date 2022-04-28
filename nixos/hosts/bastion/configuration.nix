# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
let
  fix-vscode = pkgs.writeScriptBin "fix-vscode" ''
    #!${pkgs.stdenv.shell}
    if [[ -d "$HOME/.vscode-server/bin" ]]; then
      for versiondir in "$HOME"/.vscode-server/bin/*; do
        rm "$versiondir/node"
        ln -s "${pkgs.nodejs-14_x}/bin/node" "$versiondir/node"
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

  # Additional packages
  environment.systemPackages = with pkgs; [
    binutils
    fix-vscode
    fluxcd
    k9s
    kubectl
    kubectx
    nixfmt
    nix-prefetch-git
    ripgrep
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

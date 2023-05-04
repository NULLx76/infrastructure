{ pkgs, lib, ... }:
{
  networking.interfaces.eth0.useDHCP = true;

  # mosh ssh
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    cachix
    direnv
    git-crypt
    nix-update
    nodejs-14_x
    pinentry-curses
    ripgrep
    rsync
    tmux
    vault
  ];

  environment.noXlibs = lib.mkForce false;

  system.stateVersion = "22.11";

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };
}

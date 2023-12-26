{ pkgs, lib, ... }: {
  networking.interfaces.eth0.useDHCP = true;

  # mosh ssh
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    rustup
    vault
  ];

  environment.noXlibs = lib.mkForce false;

  system.stateVersion = "22.11";

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };
}

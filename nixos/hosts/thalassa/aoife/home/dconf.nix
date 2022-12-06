# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us+altgr-intl" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "caps:swapescape" ];
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = false;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>bracketleft" ];
      toggle-tiled-right = [ "<Super>bracketright" ];
    };

    "org/gnome/shell/keybindings" = { toggle-overview = [ "<Super>d" ]; };

    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = false;
      num-workspaces = 6;
      focus-mode = "sloppy";
    };

    "org/gnome/desktop/wm/keybindings" = {
      raise-or-lower = [ "<Super>s" ];
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Super>Tab" ];
      move-to-workspace-1 = [ "<Shift><Super>exclam" ];
      move-to-workspace-2 = [ "<Shift><Super>at" ];
      move-to-workspace-3 = [ "<Shift><Super>numbersign" ];
      move-to-workspace-4 = [ "<Shift><Super>dollar" ];
      move-to-workspace-5 = [ "<Shift><Super>percent" ];
      move-to-workspace-6 = [ "<Shift><Super>asciicircum" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-maximized = [ "<Super>m" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>Return";
        command = "kgx";
        name = "Open Terminal";
      };

    "org/gnome/tweaks" = { show-extensions-notice = false; };
  };
}

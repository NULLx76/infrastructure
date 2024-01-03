{ lib, ... }:

with lib.hm.gvariant;
let
  inherit (builtins) attrNames map;
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  generate_custom_keybindings = binds:
    {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = map (name:
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/")
          (attrNames binds);
      };
    } // mapAttrs' (name:
      nameValuePair
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}")
    binds;
in {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/plain" = "org.gnome.TextEditor.desktop";
    "application/pdf" = "org.gnome.Evince.desktop";

    # Firefox
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";

    # Images
    "image/bmp" = "org.gnome.eog.desktop";
    "image/gif" = "org.gnome.eog.desktop";
    "image/jpg" = "org.gnome.eog.desktop";
    "image/pjpeg" = "org.gnome.eog.desktop";
    "image/png" = "org.gnome.eog.desktop";
    "image/tiff" = "org.gnome.eog.desktop";
    "image/webp" = "org.gnome.eog.desktop";
    "image/x-bmp" = "org.gnome.eog.desktop";
    "image/x-gray" = "org.gnome.eog.desktop";
    "image/x-icb" = "org.gnome.eog.desktop";
    "image/x-ico" = "org.gnome.eog.desktop";
    "image/x-png" = "org.gnome.eog.desktop";
    "image/x-portable-anymap" = "org.gnome.eog.desktop";
    "image/x-portable-bitmap" = "org.gnome.eog.desktop";
    "image/x-portable-graymap" = "org.gnome.eog.desktop";
    "image/x-portable-pixmap" = "org.gnome.eog.desktop";
    "image/x-xbitmap" = "org.gnome.eog.desktop";
    "image/x-xpixmap" = "org.gnome.eog.desktop";
    "image/x-pcx" = "org.gnome.eog.desktop";
    "image/svg+xml" = "org.gnome.eog.desktop";
    "image/svg+xml-compressed" = "org.gnome.eog.desktop";
    "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
    "image/x-icns" = "org.gnome.eog.desktop";
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us+altgr-intl" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
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
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-6 = [ "<Shift><Super>6" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      toggle-fullscreen = [ "<Super><Shift>M" ];
      toggle-maximized = [ "<Super>m" ];
      close = [ "<Super>Q" ];
    };

    "org/gnome/tweaks" = { show-extensions-notice = false; };

    "org/gnome/boxes" = { first-run = false; };
  } // generate_custom_keybindings {
    "terminal" = {
      binding = "<Super>Return";
      command = "kgx";
      name = "Open Terminal";
    };
    "firefox" = {
      binding = "<Super>f";
      command = "firefox";
      name = "Open Firefox";
    };
  };
}

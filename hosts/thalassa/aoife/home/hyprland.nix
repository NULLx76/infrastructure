{ pkgs, ... }:
{
  programs = {
    wofi = {
      enable = true;
    };

    eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = ./eww;
    };

    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "wireplumber" "power-profiles-daemon" "network" "battery" ];
        };
      };
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    settings = {
      monitor = ",preferred,auto,auto";
      input = {
        kb_options = "caps:escape";
        touchpad.natural_scroll = true;
      };
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };
      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      animations = {
        enabled = "yes";

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      dwindle = {
        preserve_split = "yes";
        pseudotile = "yes";
      };
      gestures.workspace_swipe = true;
    };
    extraConfig = ''
      $terminal = kitty
      $fileManager = dolphin
      $menu = wofi --show drun
      misc {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 2 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_splash_rendering = true
      }

      # Window Rules
      windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.
      windowrulev2 = workspace 1 silent, class:^(Element)$
      windowrulev2 = workspace 1 silent, class:^(discord)$
      windowrulev2 = workspace 2 silent, class:^(firefox)$
      windowrulev2 = float,class:^(firefox)$,title:^(Picture-in-Picture)$

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, RETURN, exec, $terminal
      bind = $mainMod, Q, killactive,
      bind = $mainMod SHIFT, escape, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, D, exec, $menu
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle

      # Fullscreen
      bind=SUPER,m,fullscreen

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Example special workspace (scratchpad)
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };
}

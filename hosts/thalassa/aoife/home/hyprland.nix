{ pkgs, config, ... }:
{

  systemd.user.services.mako = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";

      ExecCondition = ''
        ${pkgs.bash}/bin/bash -c '[ -n "$WAYLAND_DISPLAY" ]'
      '';

      ExecStart = ''
        ${pkgs.mako}/bin/mako
      '';

      ExecReload = ''
        ${pkgs.mako}/bin/makoctl reload
      '';

      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  programs = {
    wofi = {
      enable = true;
    };

    eww = {
      enable = true;
      configDir = ./eww;
    };

    mako.enable = true;

    waybar = {
      enable = true;
      style = ./waybar.css;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "wireplumber"
            "power-profiles-daemon"
            "network"
            "battery"
          ];

          wireplumber = {
            format = "󰕾 {volume}%";
            format-muted = "󰖁";
          };

          network = {
            format-wifi = "󰖩 {essid} ({signalStrength}%)";
            format-ethernet = "󰈀 {ifname}: {ipaddr}/{cidr}";
            format-disconnected = "󰌙 ";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          power-profiles-daemon = {
            format = "{icon}";
            format-icons = {
              performance = "󰓅";
              balanced = "󰾅";
              power-saver = "󰾆";
            };
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };

            format = "󱐋 {capacity}%";
            format-discharging = "{icon}  {capacity}%";

            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
        };
      };
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };
  };

  wayland.windowManager.hyprland =
    let
      toggle_mirror = pkgs.writeScriptBin "toggle_mirror.sh" ''
        #!/usr/bin/env bash
        if [ $(hyprctl monitors all -j | ${pkgs.jq}/bin/jq '.[1].activeWorkspace.id') = '-1' ]; then
        	hyprctl keyword monitor ",preferred,auto,1"
        else
        	hyprctl keyword monitor ",preferred,auto,1,mirror,eDP-1"
        fi
      '';
    in
    {
      enable = true;
      systemd.enable = true;

      settings =
        let
          inherit (builtins) genList concatLists toString;
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          menu = "${config.programs.wofi.package}/bin/wofi --show run,drun";
          terminal = "${config.programs.kitty.package}/bin/kitty";
          fileManager = "${pkgs.gnome.nautilus}/bin/nautilus";
        in
        {
          "$mod" = "SUPER";
          exec-once = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          ];
          monitor = [
            "eDP-1, 3840x2400@60,0x0,2"
            ",highres,auto,1"
          ];
          input = {
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

          misc = {
            force_default_wallpaper = 1;
            disable_splash_rendering = true;
          };

          windowrulev2 = [
            "suppressevent maximize, class:.* # You'll probably like this."
            "workspace 1 silent, class:^(Element)$"
            "workspace 1 silent, class:^(discord)$"
            "workspace 2 silent, class:^(firefox)$"
            "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
          ];

          # l -> works when screen is locked
          # e -> repeats when held
          bindel = [
            ",XF86AudioRaiseVolume,exec,${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume,exec,${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86MonBrightnessUp,exec,${brightnessctl} -q s +5%"
            ",XF86MonBrightnessDown,exec,${brightnessctl} -q s 5%-"
          ];

          bindl = [ ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];

          bind =
            [
              "$mod, RETURN, exec, ${terminal}"
              "$mod, Q, killactive,"
              "$mod SHIFT, escape, exit,"
              "$mod, E, exec, ${fileManager}"
              "$mod, V, togglefloating,"
              "$mod, D, exec, ${menu}"
              "$mod, P, pseudo, # dwindle"
              "$mod, J, togglesplit, # dwindle"
              "SUPER,m,fullscreen"

              # Move focus with arrow keys
              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
              "$mod, down, movefocus, d"

              # Scratch workspace
              "$mod, S, togglespecialworkspace, magic"
              "$mod SHIFT, S, movetoworkspace, special:magic"

              # PrintScreen
              ",Print,exec, grimblast copysave area /home/vivian/cloud/Pictures/Screenshots/$(date --iso=seconds).png"
            ]
            ++ (
              # workspaces
              # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
              concatLists (
                genList (
                  x:
                  let
                    ws =
                      let
                        c = (x + 1) / 10;
                      in
                      toString (x + 1 - (c * 10));
                  in
                  [
                    "$mod, ${ws}, workspace, ${toString (x + 1)}"
                    "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
                  ]
                ) 10
              )

            );

          # Bind mouse
          bindm = [
            # Move/resize windows with mod + LMB/RMB and dragging
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
    };
}

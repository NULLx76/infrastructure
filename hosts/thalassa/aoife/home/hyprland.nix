{
  pkgs,
  config,
  inputs,
  ...
}:
let
  terminal = "${config.programs.kitty.package}/bin/kitty -1";
in
{

  home.packages = with pkgs; [
    v.hyprland-workspaces
  ];

  systemd.user.services.mako = {
    Install = {
      WantedBy = [ "hyprland-session.target" ];
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

  xdg.configFile."hypr/hyprpaper.conf".text =
    let
      wallpaper = "/home/vivian/cloud/Pictures/Wallpapers-Laptop/wallpaper-nix-pink.png";
    in
    ''

    '';

  programs = {
    wofi = {
      enable = true;
    };

    # eww = {
      # enable = true;
      # configDir = ./eww;
    # };

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
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle";
          };

          network =
            let
              nmtui = pkgs.writeScriptBin "nmtui.sh" ''
                #!${pkgs.stdenv.shell}
                unset COLORTERM
                TERM=xterm-old ${pkgs.networkmanager}/bin/nmtui
              '';
            in
            {
              format-wifi = "󰖩 {essid} ({signalStrength}%)";
              format-ethernet = "󰈀 {ifname}: {ipaddr}/{cidr}";
              format-disconnected = "󰌙 ";
              tooltip-format = "{ifname}: {ipaddr}";
              on-click = "touch ~/a && ${terminal} --execute ${nmtui}/bin/nmtui.sh";
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
        #!${pkgs.stdenv.shell}
        if [ $(hyprctl monitors all -j | ${pkgs.jq}/bin/jq '.[1].activeWorkspace.id') = '-1' ]; then
        	hyprctl keyword monitor ",preferred,auto,1"
        else
        	hyprctl keyword monitor ",preferred,auto,1,mirror,eDP-1"
        fi
      '';
      startup = pkgs.writeScriptBin "startup.sh" ''
        #!${pkgs.stdenv.shell}
        firefox &
        discord &

        # start keyring, then unlock it, then start Element
        gnome-keyring-daemon -r -d && ${
          inputs.gnome-autounlock-keyring.packages.${pkgs.system}.default
        }/bin/gnome-autounlock-keyring unlock && element-desktop &
      '';
      hyprpaper-conf =
        let
          wallpaper = ../../../../assets/wallpaper-nix-pink.png;
        in
        pkgs.writeText "hyprpaper.conf" ''
          preload = ${wallpaper}
          wallpaper = eDP-1,${wallpaper}

          splash = false
          ipc = off
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
          fileManager = "${pkgs.gnome.nautilus}/bin/nautilus";
        in
        {
          "$mod" = "SUPER";
          exec-once = [
            "${pkgs.hyprpaper}/bin/hyprpaper -c ${hyprpaper-conf}"
            "${startup}/bin/startup.sh"
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
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = "rgba(8caaeeee) rgba(a6d189ee) 45deg";
            "col.inactive_border" = "rgba(303446aa)";
            layout = "dwindle";
            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false;
          };
          group = {
            "col.border_active" = "rgba(babbf1ee) rgba(f4b8e4ee) 45deg";
            "col.border_inactive" = "rgba(232634aa)";

            groupbar = {
              font_size = 16;
              "col.active" = "rgba(babbf1aa)";
              "col.inactive" = "rgba(414559aa)";
              text_color = "rgba(81c8beee)";
            };
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
            force_default_wallpaper = 2;
            disable_splash_rendering = true;
            disable_hyprland_logo = true;
            disable_autoreload = true;
          };

          windowrulev2 = [
            "suppressevent maximize, class:.* # You'll probably like this."
            "workspace 1 silent, class:^(Element)$"
            "workspace 1 silent, class:^(discord)$"
            "group, class:^(Element|discord)$,workspace:1"
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
              "$mod,m,fullscreen"

              # Move focus with arrow keys
              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
              "$mod, down, movefocus, d"

              # Scratch workspace
              "$mod, S, togglespecialworkspace, magic"
              "$mod SHIFT, S, movetoworkspace, special:magic"
              # Groups aka Tabs
              "$mod,g,togglegroup"
              "$mod,tab,changegroupactive"

              # PrintScreen
              ",Print,exec,${pkgs.grimblast}/bin/grimblast copysave area /home/vivian/cloud/Pictures/Screenshots/$(date --iso=seconds).png"
              # Toggle Mirror for external displays on/off
              ",XF86Display,exec,${toggle_mirror}/bin/toggle_mirror.sh"
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

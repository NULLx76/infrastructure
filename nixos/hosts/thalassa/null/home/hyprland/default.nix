{ pkgs, inputs, ... }: {
  home.file.".config/hypr/hyprpaper.conf".text = ''
    ipc = off
    preload = ~/cloud/Pictures/Wallpapers-Laptop/wallpaper-nix-pink.png
    wallpaper = eDP-1,~/cloud/Pictures/Wallpapers-Laptop/wallpaper-nix-pink.png
  '';

  home.file.".xsettingsd".text = ''
    Gtk/CursorThemeName "Catppuccin-Frappe-Pink-Cursors"
    Net/ThemeName "Catppuccin-Pink-Dark"
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      exec-once=${pkgs.hyprpaper}/bin/hyprpaper
      exec-once=hyprctl setcursor Catppuccin-Frappe-Pink-Cursors 32
      exec-once=${pkgs.xsettingsd}/bin/xsettingsd &
      exec-once=foot --server &
      exec-once=eww daemon
      exec-once=eww open bar
      
      monitor=eDP-1,1920x1080@60,0x0,1
      monitor=eDP-1,addreserved,0,0,48,0
      monitor=,preferred,auto,1

      general {
        layout = dwindle
        col.active_border = 0xfff4b8e4
      }

      input {
        kb_options=caps:escape
        touchpad {
          natural_scroll= true
        }
      }

      gestures {
        workspace_swipe = true
      }

      misc {
        no_vfr = false
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      dwindle {
        pseudotile=true
      }

      bind=SUPER,RETURN,exec,footclient
      bind=SUPER,f,exec,firefox-devedition
      bind=SUPER,d,exec,wofi --show run,drun

      bind=,Print,exec,grim -g "$(slurp)" - | wl-copy -t image/png
      bind=SUPER,W,killactive,
      bind=SUPERSHIFT,Q,exit,
      bind=SUPER,S,togglefloating,
      bind=SUPER,P,pseudo,

      bind=SUPER,left,movefocus,l
      bind=SUPER,right,movefocus,r
      bind=SUPER,up,movefocus,u
      bind=SUPER,down,movefocus,d

      bind=SUPER,1,workspace,1
      bind=SUPER,2,workspace,2
      bind=SUPER,3,workspace,3
      bind=SUPER,4,workspace,4
      bind=SUPER,5,workspace,5
      bind=SUPER,6,workspace,6
      bind=SUPER,7,workspace,7
      bind=SUPER,8,workspace,8
      bind=SUPER,9,workspace,9
      bind=SUPER,0,workspace,10

      bind=ALT,1,movetoworkspace,1
      bind=ALT,2,movetoworkspace,2
      bind=ALT,3,movetoworkspace,3
      bind=ALT,4,movetoworkspace,4
      bind=ALT,5,movetoworkspace,5
      bind=ALT,6,movetoworkspace,6
      bind=ALT,7,movetoworkspace,7
      bind=ALT,8,movetoworkspace,8
      bind=ALT,9,movetoworkspace,9
      bind=ALT,0,movetoworkspace,10

      bind=SUPER,mouse_down,workspace,e+1
      bind=SUPER,mouse_up,workspace,e-1

      bind=SUPER,g,togglegroup
      bind=SUPER,tab,changegroupactive

      bind=,XF86MonBrightnessUp,exec,brightnessctl -q s +5%
      bind=,XF86MonBrightnessDown,exec,brightnessctl -q s 5%-
      bind=,XF86MonRaiseVolume,exec,pamixer -i 5
      bind=,XF86MonLowerVolume,exec,pamixer -d 5
      bind=,XF86AudioMute,exec,pamixer -t
    '';
  };
}

{ pkgs, ... }: {
  imports = [
    ./eww
  ];

  home.packages = with pkgs; [
    wofi # Wayland rofi
    grim # Screenshot tool
    wf-recorder # Screenrecorder
    wl-clipboard # Clipboard manager
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      exec-once=eww daemon
      exec-once=eww open bar
      
      monitor=eDP-1,1920x1080@60,0x0,1
      monitor=eDP-1,addreserved,0,0,48,0

      general {
        layout = dwindle
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
      }

      dwindle {
        pseudotile=true
      }

      bind=SUPER,RETURN,exec,alacritty
      bind=SUPER,f,exec,firefox-devedition
      bind=SUPER,d,exec,rofi -show run

      bind=,Print,exec,grim -g "$(slurp)" - | wl-copy -t image/png
      bind=SUPER,W,killactive,
      bind=SUPER,M,exit,
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

      # Firefox notifications
      windowrule=float,title:^(\s*)$
      windowrule=nofocus,title:^(\s*)$
      windowrule=move 1569 0,title:^(\s*)$
      windowrule=opacity 0.8,title:^(\s*)$
      windowrule=rounding 3,title:^(\s*)$
      windowrule=animation popin,title:^(\s*)$

      bind=,XF86MonBrightnessUp,exec,brightnessctl set +5%
      bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%-
      bind=,XF86MonRaiseVolume,exec,pamixer -i 5
      bind=,XF86MonLowerVolume,exec,pamixer -d 5
      bind=,XF86AudioMute,exec,pamixer -t

      animation=workspaces,1,8,default,slidevert
    '';
  };
}

{ config, pkgs, inputs, ... }:

let
  wallpaperSet = pkgs.writeShellApplication {
    name = "wallpaper-set";
    runtimeInputs = with pkgs; [
      gnugrep
      matugen
      procps
      swaybg
    ];
    text = ''
      set -euo pipefail

      wallpaper="''${1:?Usage: wallpaper-set IMAGE}"
      if [ ! -f "$wallpaper" ]; then
        printf 'wallpaper-set: image not found: %s\n' "$wallpaper" >&2
        exit 1
      fi

      mkdir -p "$HOME/.cache/matugen" "$HOME/.config/quickshell/generated"
      matugen image --quiet "$wallpaper"

      pkill -x swaybg 2>/dev/null || true
      swaybg -i "$wallpaper" -m fill &

      systemctl --user reload app-com.mitchellh.ghostty.service 2>/dev/null || true
    '';
  };
in
{
  home.packages = [ wallpaperSet ];

  imports = [
    inputs.mango.hmModules.mango
  ];

  # config.conf is HM-managed; replace the pre-HM hand-written file
  xdg.configFile."mango/config.conf".force = true;

  wayland.windowManager.mango = {
    enable = true;

    # Runs once per mango start (via exec-once). The mango home-manager
    # module prepends the dbus environment import and the
    # mango-session.target start to this script.
    autostart_sh = ''
      # Add autostart commands here, e.g.:
      #   waybar &
      #   dunst &
      wallpaper-set /home/saman/wallpapers/schoolrumble1.jpeg
      quickshell &
    '';

    settings = {
      # --- Window effects ---
      blur = 1;
      blur_layer = 1;
      blur_optimized = 1;
      blur_params = {
        brightness = 0.95;
        contrast = 0.95;
        noise = 0.01;
        num_passes = 2;
        radius = 8;
        saturation = 1.15;
      };
      border_radius = 5;
      focused_opacity = 1.0;
      layer_shadows = 1;
      no_radius_when_single = 0;
      shadow_only_floating = 0;
      shadows = 1;
      shadows_blur = 24;
      shadows_position_x = 0;
      shadows_position_y = 0;
      shadows_size = 8;
      shadowscolor = "0x000000ff";
      unfocused_opacity = 1.0;

      # --- Animations ---
      animation_curve_close = "0.08,0.92,0,1";
      animation_curve_focus = "0.46,1.0,0.29,1";
      animation_curve_move = "0.46,1.0,0.29,1";
      animation_curve_opafadein = "0.46,1.0,0.29,1";
      animation_curve_opafadeout = "0.5,0.5,0.5,0.5";
      animation_curve_open = "0.46,1.0,0.29,1";
      animation_curve_tag = "0.46,1.0,0.29,1";
      # Tactile + snappy: opening is perceptible but quick, closing is faster,
      # moves stay responsive, and tag changes remain readable without delay.
      animation_duration_close = 300;
      animation_duration_focus = 0;
      animation_duration_move = 180;
      animation_duration_open = 400;
      animation_duration_tag = 220;
      animation_fade_in = 1;
      animation_fade_out = 1;
      animation_type_close = "slide";
      animation_type_open = "slide";
      animations = 1;
      fadein_begin_opacity = 0.5;
      fadeout_begin_opacity = 0.8;
      layer_animations = 1;
      tag_animation_direction = 1;
      zoom_end_ratio = 0.8;
      zoom_initial_ratio = 0.4;

      # --- Scroller ---
      edge_scroller_focus_allow_speed = 0.0;
      edge_scroller_pointer_focus = 1;
      scroller_default_proportion = 0.8;
      scroller_default_proportion_single = 1.0;
      scroller_focus_center = 0;
      scroller_prefer_center = 0;
      scroller_proportion_preset = "0.5,0.8,1.0";
      scroller_structs = 20;

      # --- Master-Stack ---
      default_mfact = 0.55;
      default_nmaster = 1;
      new_is_master = 1;
      smartgaps = 0;
      tag_num = 3;

      # --- Dwindle ---
      dwindle_drop_simple_split = 1;
      dwindle_hsplit = 1;
      dwindle_manual_split = 0;
      dwindle_preserve_split = 0;
      dwindle_smart_split = 0;
      dwindle_vsplit = 1;

      # --- Overview ---
      enable_hotarea = 0;
      hotarea_size = 10;
      ov_tab_mode = 1;
      ov_tab_mode_launch_next = 0;
      overviewgappi = 5;
      overviewgappo = 30;

      # --- Misc ---
      axis_bind_apply_timeout = 100;
      cursor_size = 24;
      drag_tile_small = 1;
      drag_tile_to_tile = 1;
      enable_floating_snap = 0;
      focus_cross_monitor = 0;
      focus_cross_tag = 0;
      focus_on_activate = 1;
      idleinhibit_ignore_visible = 0;
      no_border_when_single = 0;
      sloppyfocus = 1;
      snap_distance = 30;
      warpcursor = 1;

      # --- Keyboard ---
      numlockon = 0;
      repeat_delay = 600;
      repeat_rate = 25;
      xkb_rules_layout = "us";

      # --- Trackpad ---
      disable_trackpad = 0;
      drag_lock = 1;
      swipe_min_threshold = 1;
      tap_and_drag = 1;
      tap_to_click = 1;
      trackpad_natural_scrolling = 0;

      # --- Mouse ---
      mouse_natural_scrolling = 0;

      # --- Appearance ---
      bordercolor = "0x444444ff";
      borderpx = 2;
      dropcolor = "0x8FBA7C55";
      focuscolor = "0xc9b890ff";
      gappih = 5;
      gappiv = 5;
      gappoh = 5;
      gappov = 5;
      globalcolor = "0xb153a7ff";
      maximizescreencolor = "0x89aa61ff";
      overlaycolor = "0x14a57cff";
      rootcolor = "0x201b14ff";
      scratchpad_height_ratio = 0.9;
      scratchpad_width_ratio = 0.8;
      scratchpadcolor = "0x516c93ff";
      splitcolor = "0xEB441EFF";
      urgentcolor = "0xad401fff";

      # --- Layout per tag (1-3 scroller; rest default to tile) ---
      tagrule = [
        "id:1,layout_name:scroller"
        "id:2,layout_name:scroller"
        "id:3,layout_name:scroller"
      ];

      # --- Monitors (1440p 165Hz main left, 1080p right) ---
      monitorrule = [
        "name:^DP-3$,width:2560,height:1440,refresh:165,x:0,y:0,scale:1"
        "name:^HDMI-A-1$,width:1920,height:1080,x:2560,y:0,scale:1"
      ];

      # --- Key bindings ---
      bind = [
        "SUPER,r,reload_config"
        "Alt,u,spawn,qs ipc call launcher toggle"
        "SUPER,Return,spawn,ghostty"
        "SUPER+SHIFT,S,spawn_shell,grim -g \"$(slurp)\" - | wl-copy"
        "SUPER,c,killclient"
        "SUPER,Tab,focusstack,next"
        "ALT,Left,focusdir,left"
        "ALT,Right,focusdir,right"
        "ALT,Up,focusdir,up"
        "ALT,Down,focusdir,down"
        "SUPER+SHIFT,Up,exchange_client,up"
        "SUPER+SHIFT,Down,exchange_client,down"
        "SUPER+SHIFT,Left,exchange_client,left"
        "SUPER+SHIFT,Right,exchange_client,right"
        "SUPER,g,toggleglobal,"
        "ALT,Tab,togglejump,"
        "ALT,backslash,togglefloating,"
        "ALT,a,togglemaximizescreen,"
        "ALT,f,togglefullscreen,"
        "ALT+SHIFT,f,togglefakefullscreen,"
        "SUPER,i,minimized,"
        "SUPER,o,toggleoverlay,"
        "SUPER+SHIFT,I,restore_minimized"
        "ALT,z,toggle_scratchpad"
        "ALT,e,set_proportion,1.0"
        "ALT,x,switch_proportion_preset,"
        "alt+super+ctrl,Left,scroller_stack,left"
        "alt+super+ctrl,Right,scroller_stack,right"
        "alt+super+ctrl,Up,scroller_stack,up"
        "alt+super+ctrl,Down,scroller_stack,down"
        "alt+shift,Return,dwindle_toggle_split_direction"
        "SUPER,n,switch_layout"
        "SUPER,Left,viewtoleft,0"
        "SUPER,Right,viewtoright,0"
        "CTRL+SUPER,Left,tagtoleft,0"
        "CTRL+SUPER,Right,tagtoright,0"
        "Ctrl,1,view,1,0"
        "Ctrl,2,view,2,0"
        "Ctrl,3,view,3,0"
        "Alt,1,tag,1,0"
        "Alt,2,tag,2,0"
        "Alt,3,tag,3,0"
        "alt+shift,Left,focusmon,left"
        "alt+shift,Right,focusmon,right"
        "SUPER+Alt,Left,tagmon,left"
        "SUPER+Alt,Right,tagmon,right"
        "ALT+SHIFT,X,incgaps,1"
        "ALT+SHIFT,Z,incgaps,-1"
        "ALT+SHIFT,R,togglegaps"
        "CTRL+SHIFT,Left,movewin,-50,+0"
        "CTRL+SHIFT,Right,movewin,+50,+0"
        "CTRL+ALT,Up,resizewin,+0,-50"
        "CTRL+ALT,Down,resizewin,+0,+50"
        "CTRL+ALT,Left,resizewin,-50,+0"
        "CTRL+ALT,Right,resizewin,+50,+0"
      ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];

      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
      ];

      layerrule = [
        "animation_type_open:zoom,layer_name:rofi"
        "animation_type_close:zoom,layer_name:rofi"
        # slurp's interactive selection overlay (layer name "selection", verified
        # via `mmsg get last_open_surface`): disable layer animation/blur/shadow
        # so the desktop stays visible while dragging a screenshot region instead
        # of blacking out.
        "layer_name:^selection$,noanim:1,noblur:1,noshadow:1"
        # The quickshell panel (translucent glass) keeps the compositor's
        # background blur + layer shadow. blur_layer=1 / layer_shadows=1 are
        # already global; this rule pins them ON for the panel namespace so a
        # future global toggle can't silently strip the glass. Verify the live
        # layer name with: mmsg get last_open_surface
        "layer_name:^late2000s-panel$,noblur:0,noshadow:0"
      ];

    };
  };
}

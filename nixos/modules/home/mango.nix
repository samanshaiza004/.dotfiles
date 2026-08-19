{ config, pkgs, inputs, ... }:

{
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
      animation_duration_close = 800;
      animation_duration_focus = 0;
      animation_duration_move = 500;
      animation_duration_open = 400;
      animation_duration_tag = 350;
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
      tag_num = 9;

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
      gappoh = 10;
      gappov = 10;
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

      # --- Key bindings (stock mango defaults) ---
      bind = [
        "SUPER,r,reload_config"
        "Alt,space,spawn,fuzzel"
        "SUPER,Return,spawn,ghostty"
        "ALT,c,killclient"
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
        "CTRL,Left,viewtoleft_have_client,0"
        "SUPER,Right,viewtoright,0"
        "CTRL,Right,viewtoright_have_client,0"
        "CTRL+SUPER,Left,tagtoleft,0"
        "CTRL+SUPER,Right,tagtoright,0"
        "Ctrl,1,view,1,0"
        "Ctrl,2,view,2,0"
        "Ctrl,3,view,3,0"
        "Ctrl,4,view,4,0"
        "Ctrl,5,view,5,0"
        "Ctrl,6,view,6,0"
        "Ctrl,7,view,7,0"
        "Ctrl,8,view,8,0"
        "Ctrl,9,view,9,0"
        "Alt,1,tag,1,0"
        "Alt,2,tag,2,0"
        "Alt,3,tag,3,0"
        "Alt,4,tag,4,0"
        "Alt,5,tag,5,0"
        "Alt,6,tag,6,0"
        "Alt,7,tag,7,0"
        "Alt,8,tag,8,0"
        "Alt,9,tag,9,0"
        "alt+shift,Left,focusmon,left"
        "alt+shift,Right,focusmon,right"
        "SUPER+Alt,Left,tagmon,left"
        "SUPER+Alt,Right,tagmon,right"
        "ALT+SHIFT,X,incgaps,1"
        "ALT+SHIFT,Z,incgaps,-1"
        "ALT+SHIFT,R,togglegaps"
        "CTRL+SHIFT,Up,movewin,+0,-50"
        "CTRL+SHIFT,Down,movewin,+0,+50"
        "CTRL+SHIFT,Left,movewin,-50,+0"
        "CTRL+SHIFT,Right,movewin,+50,+0"
        "CTRL+ALT,Up,resizewin,+0,-50"
        "CTRL+ALT,Down,resizewin,+0,+50"
        "CTRL+ALT,Left,resizewin,-50,+0"
        "CTRL+ALT,Right,resizewin,+50,+0"
      ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "NONE,btn_middle,togglemaximizescreen,0"
        "SUPER,btn_right,moveresize,curresize"
      ];

      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
      ];

      layerrule = [
        "animation_type_open:zoom,layer_name:rofi"
        "animation_type_close:zoom,layer_name:rofi"
      ];

    };
  };
}

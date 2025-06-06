{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # This is pretty much the same as /etc/sway/config.d/nixos.conf [1] but also restarts  
    # some user services [2] to make sure they have the correct environment variables [3]
    # [1] - https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/applications/window-managers/sway/wrapper.nix#L20
    # [2] - https://wiki.archlinux.org/title/systemd/User#Environment_variables
    # [3] - https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
    #(pkgs.writeScriptBin "sway-configure-dbus" ''
    #  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    #  systemctl --user restart pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
    #''
    #)

    swaybg
    swaylock
    # waybar
    wofi # menu
    wf-recorder
    wl-clipboard
    grim # screenshot
    jq # to process json of current monitor
    slurp # select region for screenshot
    mako # notification daemon
    libnotify # required to use notify-send
    imv
    networkmanagerapplet # needs to be installed to have the systrey icon of nm-applet
    xorg.xrandr # to make games work on correct display
    glfw-wayland # to make native games work
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;

    # NOTE: This is a "indirect" Systemd integration
    # usefull to make xdg.portal... work
    # https://github.com/swaywm/sway/issues/5160#issuecomment-641173221
    # https://nixos.wiki/wiki/Sway#Systemd_integration
    systemd.enable = false;
    wrapperFeatures.gtk = true;
    xwayland = true;
    config = {

      input = {
        "type:keyboard" = {
          xkb_layout = "br";
        };
        "9580:109:HUION_Huion_Tablet_H1162" = {
          map_to_output = "DP-1";
        };
        "9580:109:HUION_Huion_Tablet_H1162_Pad" = {
          map_to_output = "DP-1";
        };
        "9580:109:HUION_Huion_Tablet_H1162_Pen" = {
          map_to_output = "DP-1";
        };
        "9580:109:HUION_Huion_Tablet_H1162_Dial" = {
          map_to_output = "DP-1";
        };
      };

      modifier = "Mod4"; #Mod4 = Super
      terminal = "kitty";
      keybindings = lib.mkOptionDefault {
        "Mod4+Shift+Tab" = "focus left";
        "Mod4+Tab" = "focus right";
        # "Mod4+Prior" = "mode sims";
      };
      startup = [
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${pkgs.swaybg}/bin/swaybg -i ~/.background-image -m fill"; }
        { command = "swaymsg 'output HDMI-A-1 position 0 0'"; always = true; }
        { command = "swaymsg 'output DP-1 position 1920 0'"; always = true; }
        { command = "swaymsg 'output * adaptive_sync on'"; always = true; }

        { command = "dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE I3SOCK SWAYSOCK DISPLAY WAYLAND_DISPLAY XCURSOR_THEME XCURSOR_SIZE GTK_THEME QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE"; }
        { command = "systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE I3SOCK SWAYSOCK DISPLAY WAYLAND_DISPLAY XCURSOR_THEME XCURSOR_SIZE GTK_THEME QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE"; }
        { command = "systemctl --user reset-failed"; }
      ];
      #
      #      modes = {
      #        sims = {
      #          button4 = "cmus";
      #          Next = "mode default";
      #        };
      #      };
    };
  };

  home.stateVersion = "24.05";
}

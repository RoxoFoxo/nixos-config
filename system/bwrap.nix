{ config, pkgs, lib, ... }:

let
  no_wayland_support_fix = [
    # Fix games breaking on wayland
    "--unsetenv XDG_SESSION_TYPE"
    "--unsetenv CLUTTER_BACKEND"
    "--unsetenv QT_QPA_PLATFORM"
    "--unsetenv SDL_VIDEODRIVER"
    "--unsetenv SDL_AUDIODRIVER"
    "--unsetenv NIXOS_OZONE_WL"
  ];
  steam_common = {
    dev = true; # required for vulkan
    #tmp = true;
    xdg = true; # if prefs.steam.vr_integration then true else "ro";
    rwBinds =
      [
        "$HOME/.config/MangoHud/MangoHud.conf"
        "$HOME/mnt/manjaro/home/roxo_foxo/.local/share/Steam/"
      ];
    extraConfig = [
      # Proton-GE
      "--setenv STEAM_EXTRA_COMPAT_TOOLS_PATHS ${
                  lib.makeSearchPathOutput "steamcompattool" "" [
                  pkgs.proton-ge-bin
                ]
              }"
    ];
  };
in
{
  hardware.steam-hardware.enable = true;
  nixjail.bwrap = {
    defaultHomeDirRoot = "$HOME/bwrap/";
    profiles =
      [
        # prismlauncher
        {
          packages = f: p: with p; { prismlauncher = prismlauncher; };
          dri = true;
          rwBinds = [ "$HOME/Downloads" ];
        }

        # discord
        {
          packages = f: p: with p; {
            discord = p.discord-canary.override { nss = p.nss_latest; };
          };
          dev = true;
          rwBinds = [ "$HOME" ];
          autoBindHome = false;
          defaultBinds = false;
        }

        # vesktop
        {
          packages = f: p: with p; {
            vesktop = p.vesktop;
          };
          dev = true;
          rwBinds = [ "$HOME" ];
          autoBindHome = false;
          defaultBinds = false;
        }

        # lutris
        {
          packages = f: p: with p; {
            lutris = lutris.override {
              extraPkgs = pkgs: [ pkgs.openssl pkgs.wineWowPackages.waylandFull ];
              # Fixes: dxvk::DxvkError
              extraLibraries = pkgs:
                let
                  gfx = config.hardware.graphics;
                in
                [
                  pkgs.libjson # FIX: samba json errors
                  gfx.package
                  gfx.package32
                ] ++ gfx.extraPackages ++ gfx.extraPackages32;
            };
          };
          dri = true; # required for vulkan
          #xdg = true;
          #ldCache = true;
          rwBinds = [ ];
          extraConfig = no_wayland_support_fix;
        }

        # Steam
        ({
          install = true;
          post_exec = ''-console -nochatui -nofriendsui "$@"''; # -silent
          packages = f: p: with p; {
            steam = steam.override ({ extraLibraries ? pkgs': [ ], ... }: {
              #extraPkgs = pkgs: with pkgs; [ ];
              extraLibraries = pkgs':
                (extraLibraries pkgs') ++
                  [
                    pkgs'.elfutils
                    pkgs'.gperftools
                  ] ++
                  # Fixes: dxvk::DxvkError
                  (with config.hardware.graphics; if pkgs'.hostPlatform.is64bit
                  then [ package ] ++ extraPackages
                  else [ package32 ] ++ extraPackages32);
            });
          };
        } // steam_common)
        ({
          install = true;
          packages = f: p: with p; {
            gamescope = gamescope;
            #r2modman = (r2modman.overrideAttrs (old: {
            #  src = p.fetchFromGitHub {
            #    owner = "ebkr";
            #    repo = "r2modmanPlus";
            #    rev = "fdc15fa393beae5c827cbac79cce232bd07f71e7";
            #    sha256 = "sha256-exD9gHT1+LzP1x7PJFgdXEIhXH67mkSvLlEZM0jwctI=";
            #  };
            #}));
            #protontricks = protontricks;
          };
        } // steam_common)

        # heroic launcher
        # {
        #   dri = true; # required for vulkan
        #   xdg = false; # if prefs.steam.vr_integration then true else "ro";
        #   dbusProxy = {
        #     enable = true;
        #     user = {
        #       talks = [
        #         "org.freedesktop.Notifications"
        #         "org.kde.StatusNotifierWatcher"
        #       ];
        #     };
        #   };
        #   packages = f: p: with p; {
        #     heroic = heroic;
        #   };
        #   rwBinds = [
        #     "$HOME/games/steam_custom_games"
        #   ];
        #   extraConfig = steam_common.extraConfig;
        # }

        {
          packages = f: p: with p; { heroic = heroic; };
          install = true;
          shareNamespace.net = false;
          dri = true;
          xdg = false;
          dbusProxy.enable = true;
          autoBindHome = false;
          # rwBinds = [{ from = "$HOME/bwrap/heroic-the-sims"; to = "$HOME/"; }];
          rwBinds = [{ from = "$HOME/bwrap/heroic-the-sims"; to = "$HOME/"; } "/tmp/.X11-unix/X0"];
          extraConfig = [
            # Fix games breaking on wayland
            "--unsetenv WAYLAND_DISPLAY"
            "--unsetenv XDG_SESSION_TYPE"
            "--unsetenv CLUTTER_BACKEND"
            "--unsetenv QT_QPA_PLATFORM"
            "--unsetenv SDL_VIDEODRIVER"
            "--unsetenv SDL_AUDIODRIVER"
            "--unsetenv NIXOS_OZONE_WL"
          ];
        }

      ];
  };
}

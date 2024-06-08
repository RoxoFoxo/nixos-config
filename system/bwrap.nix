{ config, pkgs, lib , ... }:

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
    net = true;
    #tmp = true;
    xdg = true; # if prefs.steam.vr_integration then true else "ro";
    rwBinds =
      [
        "$HOME/.config/MangoHud/MangoHud.conf"
        "$HOME/mnt/manjaro/home/roxo_foxo/.local/share/Steam/"
      ];
    extraConfig = no_wayland_support_fix ++ [
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
        {
          packages = f: p: with p; { prismlauncher = prismlauncher; };
          net = true;
          dri = true;
          rwBinds = [ "$HOME/Downloads" ];
        }
        {
          packages = f: p: with p; {
            discord = p.discord.override { nss = p.nss_latest; };
            vesktop = p.vesktop;
          };
          net = true;
          dev = true;
          rwBinds = [ "$HOME" ];
          autoBindHome = false;
        }
        {
          packages = f: p: with p; {
            lutris = lutris.override {
              extraPkgs = pkgs: [ pkgs.openssl pkgs.wineWowPackages.waylandFull ];
              # Fixes: dxvk::DxvkError
              extraLibraries = pkgs:
                let
                  gl = config.hardware.opengl;
                in
                [
                  pkgs.libjson # FIX: samba json errors
                  gl.package
                  gl.package32
                ] ++ gl.extraPackages ++ gl.extraPackages32;
            };
          };
          dri = true; # required for vulkan
          net = true;
          #xdg = true;
          #ldCache = true;
          rwBinds = [ ];
          extraConfig = no_wayland_support_fix;
        }

        # Steam
        ({
          install = true;
          args = ''-console -nochatui -nofriendsui "$@"''; # -silent
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
                  (with config.hardware.opengl; if pkgs'.hostPlatform.is64bit
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
      ];
  };
}

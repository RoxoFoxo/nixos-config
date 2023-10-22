{ config, ... }:

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
in
{
  nixjail.bwrap.profiles =
    [
      {
        packages = f: p: with p; { prismlauncher = prismlauncher; };
        net = true;
        dri = true;
        rwBinds = [ "$HOME/Downloads" ];
      }
      {
        packages = f: p: with p; { discord = p.discord.override { nss = p.nss_latest; }; };
        net = true;
        dri = true;
        rwBinds = [ "$HOME" ];
        autoBindHome = false;
      }
      {
        packages = f: p: with p; {
          lutris = lutris.override {
            extraPkgs = pkgs: [ pkgs.openssl ];
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
    ];
}

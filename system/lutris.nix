{ config, lib, pkgs, pkgs_unstable, ... }:

let
  bwrap = import ./bwrap_shenanigans.nix { inherit lib pkgs; };
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
  environment.systemPackages = with pkgs_unstable; [
    glxinfo
    (bwrap.bwrapIt {
      name = "lutris";
      package = (lutris.override {
        extraPkgs = pkgs: [ pkgs.openssl pkgs.libnghttp2 ];
        # Fixes: dxvk::DxvkError
        extraLibraries = pkgs:
          let
            gl = config.hardware.opengl;
          in
          [
            pkgs.libjson # FIX: samba json errors
            pkgs.libnghttp2
            gl.package
            gl.package32
          ] ++ gl.extraPackages ++ gl.extraPackages32;
      });
      dev = true; # required for vulkan
      # tmp = true;
      net = true;
      xdg = true;
      # ld_cache = true;
      binds = [
        {
          from = "~/bwrap/lutris";
          to = "~/";
        }
        "~/.Xauthority"
      ];
      custom_config = no_wayland_support_fix;
    })
  ];
}

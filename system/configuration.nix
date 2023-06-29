# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, pkgs_unstable, ... }:

let
  bwrap = import ./bwrap_shenanigans.nix { inherit lib pkgs; };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./neovim/neovim.nix
      ./lutris.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  programs.nm-applet.enable = true;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.utf8";
    LC_IDENTIFICATION = "pt_BR.utf8";
    LC_MEASUREMENT = "pt_BR.utf8";
    LC_MONETARY = "pt_BR.utf8";
    LC_NAME = "pt_BR.utf8";
    LC_NUMERIC = "pt_BR.utf8";
    LC_PAPER = "pt_BR.utf8";
    LC_TELEPHONE = "pt_BR.utf8";
    # LC_TIME = "pt_BR.utf8";
  };

  # Configure keymap in X11
  # services.xserver = {
  #   layout = "br";
  #   xkbVariant = "";
  # };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.roxo = {
    isNormalUser = true;
    description = "roxo";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  # Enable automatic login for the user.
  # services.getty.autologinUser = "roxo";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty
    firefox
    (bwrap.bwrapIt {
      name = "discord";
      # Needs to be the same version of 
      # nix path-info $(which firefox) -r | grep nss-
      package = pkgs_unstable.discord-canary;
      exec = "bin/discordcanary";
      net = true;
      dri = true;
      tmp = true;
      binds = [
        "~/"
      ];
      custom_config = [
        # FIXES: "interface 'wl_output' has no event 4"
        # Needs discord to realease with a new electron version
        "--unsetenv NIXOS_OZONE_WL"
      ];
    })
    pkgs_unstable.tdesktop
    cinnamon.nemo
    pkgs_unstable.cinnamon.nemo-fileroller
    gnome.nautilus
    gnome.adwaita-icon-theme
    mpv
    keepassxc
    glxinfo # glxgears
    vulkan-tools # vulkaninfo
    clinfo
    rocm-smi
    rocm-runtime
    rocm-device-libs
    rocminfo
    pavucontrol
    scrot
    git
    gnupg
    docker
    clementine
    dbeaver
    insomnia

    #neovim
    pkgs_unstable.elixir
    pkgs_unstable.elixir_ls
    tree-sitter
    gcc
    ripgrep
    nodePackages.svelte-language-server
    nodePackages.vscode-langservers-extracted
    nixpkgs-fmt
    nil

    rnix-lsp
    yt-dlp
    winetricks
    protontricks
    #xorg.xkill
    chromium
    xclip
    silver-searcher
    gnumake
    vscode
    pkgs_unstable.krita
    openvpn
    zathura
    zip
    unzip
    minecraft
    audacity
    gamemode
    killall
    yarn
    mangohud
    schedtool
    #xorg.xf86videoamdgpu
    #(srb2kart.overrideAttrs (old: {
    #  src = fetchFromGitHub {
    #    owner = "STJr";
    #    repo = "Kart-Public";
    #    rev = "v1.6";
    #    sha256 = "sha256-5sIHdeenWZjczyYM2q+F8Y1SyLqL+y77yxYDUM3dVA0=";
    #  };
    #}))
    #obs-studio
    # UNCOMMENT THIS WHEN U ARE READY TO TEST IT
    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    })
    prismlauncher
    # tetrio-desktop
    nodejs_20
  ];

  fonts.fonts = with pkgs ;[
    nerdfonts
    corefonts
  ];

  # Kernel (default: LTS)
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  #boot.kernelPackages = pkgs.linuxPackages_zen;

  # default applications
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      # needs GTK_USE_PORTAL=1 per app
      xdg-desktop-portal-gtk # GNOME
      #xdg-desktop-portal-kde # KDE
    ];
  };
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "x-scheme-handler/https" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "application/x-extension-html" = [
      "firefox.desktop"
      "librewolf.desktop"
      "chromium-browser.desktop"
    ];
    "application/pdf" = "firefox.desktop";
    "application/json" = "nvim.desktop";
    "text/*" = "nvim-qt.desktop";
    "audio/*" = "mpv.desktop";
    "video/*" = "mpv.desktop";
    "image/*" = [
      "imv.desktop"
      "firefox.desktop"
      "org.kde.krita.desktop"
    ];
    "inode/directory" = "nemo.desktop";
    "text/directory" = "nemo.desktop";
  };

  # RealtimeKit
  security.rtkit.enable = true;

  # Environment variables
  environment.variables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
    GTK_THEME = "Adwaita:dark";
    AMD_VULKAN_ICD = "RADV";
  };

  # Pipewire
  services = {
    # https://nixos.wiki/wiki/PipeWire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # i3 Window Manager
  #services.xserver = {
  #  enable = true;

  #  desktopManager = {
  #    xterm.enable = false;
  #    wallpaper.mode = "fill";
  #  };

  #  displayManager = {
  #    defaultSession = "none+i3";
  #  };

  #  windowManager.i3 = {
  #    enable = true;
  #    extraPackages = with pkgs; [
  #      dmenu
  #      i3status
  #      i3lock
  #      i3blocks
  #    ];
  #  };
  #};

  # Git
  programs.git.enable = true;
  programs.git.config = {
    init = {
      defaultBranch = "main";
      pull.rebase = true;
      push.default = "current";
    };
    user = {
      email = "gab.apfprado@gmail.com";
      name = "Gabriel Prado";
      signingKey = "9201198CEFB29550";
    };
    commit = {
      gpgSign = true;
    };
    core = {
      editor = "nvim";
    };
  };

  # GPG-agent SSH shenanigans
  services.openssh = {
    enable = true;
    openFirewall = lib.mkForce false;
    startWhenNeeded = true;
    passwordAuthentication = lib.mkForce false;
    permitRootLogin = lib.mkForce "no";
  };
  programs.gnupg.agent = {
    enable = true;
    # cache SSH keys added by the ssh-add
    enableSSHSupport = true;
    # set up a Unix domain socket forwarding from a remote system
    # enables to use gpg on the remote system without exposing the private keys to the remote system
    enableExtraSocket = false;
    # allows web browsers to access the gpg-agent daemon
    enableBrowserSocket = false;
    # NOTE: "gnome3" flavor only works with Xorg
    # To reload config: gpg-connect-agent reloadagent /bye
    pinentryFlavor = "gtk2"; # use "tty" for console only
  };

  # Docker
  virtualisation.docker.rootless.enable = true;

  # Dark Mode
  qt = {
    enable = true;
    style = "adwaita-dark"; # set QT_STYLE_OVERRIDE
    platformTheme = "gnome"; # set QT_QPA_PLATFORMTHEME
  };

  # OpenGL
  hardware.opengl = {
    enable = true;
    # - both dri support required for STEAM
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs;[ vaapiVdpau libvdpau-va-gl ];
  };

  # AMD
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Steam
  programs.steam.enable = true;
  programs.steam.package = pkgs_unstable.steam.override {
    # runtimeOnly = true;
    extraPkgs = pkgs: [ pkgs.gvfs ];
    extraLibraries = pkgs:
      [ pkgs.elfutils ] ++
      # Fixes: dxvk::DxvkError
      (with config.hardware.opengl; if pkgs.hostPlatform.is64bit
      then [ package ] ++ extraPackages
      else [ package32 ] ++ extraPackages32);
  };

  # Nautilus
  services.gnome.sushi.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;

  # zsh
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.theme = "gianu";
    ohMyZsh.plugins = [ "git" ];
  };
  users.defaultUserShell = pkgs.zsh;

  # gamemode
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10; # sets renice to -10
        softrealtime = "auto"; # needs SCHED_ISO ("auto" will set with >= 4 cpus)
        inhibit_screensaver = 0;
      };
    };
  };

  # Media keys
  # sound.mediaKeys.enable = true;

  # dunno nix stuff
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nix_2_7
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

# command to active unstable packages
# nix-channel --add https://channels.nixos.org/nixos-unstable nixos

{ config, pkgs, libs, ... }:
 
let
  # secondmonitor_script = pkgs.writeShellScriptBin "second_monitor_niri_sh" "
  #   bash /usr/local/bin/second_monitor_niri.sh 
  # ";
  ciscoPacketTracer = pkgs.ciscoPacketTracer8.overrideAttrs (oldAttrs: {
    src = /home/emilio/packettracer/CiscoPacketTracer822_amd64_signed.deb;
  });
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false; 

  # Bootloader.
  boot.kernelModules = [ "nvidia_uvm" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.cleanTmpDir = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  hardware.graphics = {
    enable = true;
  };
  hardware.opengl.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver.videoDrivers = ["nvidia"];

  networking.hostName = "user1012007"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # virtualisation.docker.enable = true;
  users.users.emilio = {
    isNormalUser = true;
    description = "emilio";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
     "libxml2-2.13.8"
  ];
  nix.settings.experimental-features = [ "nix-command" ];

# Steam configurations
  programs.steam.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
     (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.psutil
     ]))
     git
     niri
     fastfetch
     firefox
     xfce.thunar
     xfce.thunar-volman
     pipewire
     xwayland-satellite
     htop
     foot
     clang
     wl-clipboard
     gvfs
     qalculate-gtk
     libreoffice
     localsend
     appimage-run
     steam
     waybar
     mpv
     openjdk
     gnome-themes-extra
     pkg-config
     fontconfig
     kickoff
     swayosd
     nomacs
     swaylock
     gcc
     linux-wifi-hotspot
     bluez
     lazygit
     grim
     imagemagick
     amdvlk
     libGLU
     curl
     nethogs
     yazi
     gapless
     gammastep
     pwvucontrol
     waypaper
     swww
     eww
     jq
     jaq

     # IDE's
#    android-tools
     neovim
     obsidian
     zed-editor
#    godot_4

     # vim plugins
     vimPlugins.lazygit-nvim
     vimPlugins.plenary-nvim
     vimPlugins.vim-visual-multi
     vimPlugins.neoformat

     # Language servers
     sqlite
     sqlite-web
     nodejs_24
     php
     php84Packages.composer
     # kotlin
     # flutter
     # rustc
     # cargo
     ciscoPacketTracer 
     python3
     clang-tools
     lua-language-server

     # dependencies for nvchad
     unzip
     wl-mirror
     rsync
     _7zz
     gnupg
     pinentry-tty

     # Flatpak programs scripts
       (writeShellScriptBin "bedrock" ''
        #!/bin/bash
        flatpak run --env=__NV_PRIME_RENDER_OFFLOAD=1 --env=__GLX_VENDOR_LIBRARY_NAME=nvidia io.mrarm.mcpelauncher
      '') 

       (writeShellScriptBin "jellyfin" ''
        #!/bin/bash
        flatpak run --env=__NV_PRIME_RENDER_OFFLOAD=1 --env=__GLX_VENDOR_LIBRARY_NAME=nvidia com.github.iwalton3.jellyfin-media-player
      '') 

     # wf-recorder # to record screen # wf-recorder --audio=alsa_output.usb-Razer_Razer_Kraken_V3_X_00000000-00.pro-output-0.monitor --c=H.264 --file=recording.mp4
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    liberation_ttf
    dejavu_fonts
    font-awesome
    nerd-fonts.caskaydia-mono
  ];

  environment.etc."polkit-1/rules.d/10-nixos.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          subject.isInGroup("wheel")) {
          return polkit.Result.YES;
      }
    });
  '';

  security.pam.services.swaylock = {};
  # services.printing.enable = true;
  #services.printing.drivers = [ pkgs.epson-escpr2 ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };


  xdg.portal.config.common.default = "*";
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];
  };

  services.gvfs.enable = true;
  services.flatpak.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 128;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 256;
    };
  };
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.headset-roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };

  networking.firewall = {
    enable = true;

    # No open ports to the internet by default
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    
    # Allow addresses to conect into specific ports
    # allowedTCPConnections = [
    #   {
    #     port = 22;
    #     sourceAddress = "192.168.1.100";
    #   }
    # ];

    # Allow Avahi/mDNS only on local Wi-Fi
    interfaces."wlp4s0".allowedUDPPorts = [ 5353 45259 34445 ];
    interfaces."wlp4s0".allowedTCPPorts = [  ];

    allowPing = false;
    logRefusedConnections = true;
  };

  system.stateVersion = "24.05"; 
}

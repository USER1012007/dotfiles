# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, libs, ... }:

let
  # secondmonitor_script = pkgs.writeShellScriptBin "second_monitor_niri_sh" "
  #   bash /usr/local/bin/second_monitor_niri.sh 
  # ";
  # tooglewallpaper_script = pkgs.writeShellScriptBin "toogleWallpaper_sh" "
  #   bash /usr/local/bin/toogleWallpaper.sh 
  # ";
  # wallpaper_script = pkgs.writeShellScriptBin "wallpaper_sh" "
  #   bash /usr/local/bin/wallpaper.sh 
  # ";
  # startn_script = pkgs.writeShellScriptBin "startn" "
  #   bash /usr/local/bin/startn.sh  
  # ";
  # quit_niri_script = pkgs.writeShellScriptBin "quit_niri_sh" "
  #   bash /usr/local/bin/quit_niri.sh   
  # ";
 #aagl = import (builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz");
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
     #aagl.module
    ];

  # Bootloader.
  #boot.kernelParams = [ "i915.force_probe=a7a0" ];
  boot.kernelModules = [ "nvidia_uvm" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  hardware.graphics = {
    enable = true;
  };

  #hardware.graphics.enable32Bit = true;
  #hardware.pulseaudio.support32Bit = true;

  hardware.nvidia = {
    modesetting.enable = true;
   #powerManagment.enable = false;
   #powerManagment.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # Load nvidia driver fpr Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  networking.hostName = "User1012007"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.emilio = {
    isNormalUser = true;
    description = "emilio";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.psutil
     ]))
     git
     niri
     vim
     neovim
     fastfetch
     firefox
     xfce.thunar
     xfce.thunar-volman
     pipewire
     pavucontrol
     swaybg
     xwayland-satellite
     htop
     python3
     foot
     clang
     rustc
     cargo
     wl-clipboard
     gvfs
     qalculate-gtk
     libreoffice
     localsend
     appimage-run
     steam
     sway
     waybar
     mpv
     openjdk
     gnome-themes-extra
     pkg-config
     fontconfig
     kickoff
     efibootmgr
     godot_4
     sqlite
     sqlite-web
     php
     apacheHttpd
     swayosd
     arduino-ide
     gparted
     nomacs
     waylock
     gcc
     nodejs_22
     appimage-run
     linux-wifi-hotspot
     localsend
     transmission_4-gtk
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];
  services.httpd = {
    enable = true;
    adminAddr = "rojasbadilloe@gmail.com";  # Reemplaza con tu correo para notificaciones de Apache
    # listenAddresses = [ "127.0.0.1" ];    # Escuchar solo en localhost
    enablePHP = true;
    extraModules = [ "php" ];            # Habilita el módulo PHP
    # documentRoot = "/var/www/html/";            # Directorio de documentos
  };
  services.httpd.virtualHosts."localhost" = {
    documentRoot = "/var/www/html";
    enableUserDir = true; 
    serverAliases = [ "localhost" ]; 
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    liberation_ttf
    dejavu_fonts
    font-awesome
    nerdfonts
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    58396
    631
    53317
  ];
  networking.firewall.allowedUDPPorts = [
    631
    53317
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
  system.stateVersion = "24.05"; # Did you read the comment?
  
 #PS1='\[\e[0m\][\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\] \W]\$ '
  # Definir PROMPT_COMMAND en NixOS
  #programs.bash.promptInit = ''
  # '[ -n "$PS1" ] && PS1="\[\e[0m\][\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\] \W]\$ "; '
  #'';
}
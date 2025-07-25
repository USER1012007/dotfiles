# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  hardware.bluetooth.enable = true; # enables support for bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot
  # Bootloader.
  boot.kernelModules = [ "nvidia_uvm" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.grub = {
  #   # enable = true;
  #   useOSProber = true;
  #   device = "nodev";
  # };

  # boot.loader.gummiboot = {
  #   enable = true;
  #   timeout = 3;
  # };
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  hardware.graphics = {
    enable = true;
  };

  hardware.opengl.enable = true;
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

  networking.hostName = "user1012007"; # Define your hostname.
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

  # virtualisation.docker.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.emilio = {
    isNormalUser = true;
    description = "emilio";
    extraGroups = [ "networkmanager" "wheel" "audio"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
     "libxml2-2.13.8"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
# Steam configurations
  programs.steam.enable = true;

  programs.xwayland.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget

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

     # IDE's
#    android-tools
     neovim
#    godot_4

     # vim plugins
     vimPlugins.lazygit-nvim
     vimPlugins.plenary-nvim
     vimPlugins.vim-visual-multi
     vimPlugins.neoformat

     # Language servers
     # sqlite
     # sqlite-web
     # nodejs_22
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

       (writeShellScriptBin "packettracer" ''
        #!/bin/bash
        ciscoPacketTracer
      '') 
     # wf-recorder # to record screen # wf-recorder --audio=alsa_output.usb-Razer_Razer_Kraken_V3_X_00000000-00.pro-output-0.monitor --c=H.264 --file=recording.mp4
  ];

  # services.vnstat = {
  #   enable = true; # Habilita el servicio vnstat
  # };

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

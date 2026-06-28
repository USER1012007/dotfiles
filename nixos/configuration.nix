# nix-channel --add https://channels.nixos.org/nixos-unstable nixos
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
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
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "nowatchdog"
    "preempt=full"
  ];

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:117:0:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  networking.hostName = "user1012007"; 
  networking.networkmanager.enable = true;

  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # services.ollama = {
  #   enable = false;
  #   package = pkgs.ollama-cuda;
  #   environmentVariables = {
  #     OLLAMA_NUM_PARALLEL = "4";
  #     OLLAMA_KEEP_ALIVE = "-1";
  #   };
  # };
  programs.nix-ld.enable = true;

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      setopt PROMPT_SUBST
      PROMPT='%F{cyan}[%n@%m][%1~]{$(git branch --show-current 2>/dev/null)}%# %f'
    '';
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      grep = "grep --color=auto";
      off = "systemctl poweroff";
      reboot = "systemctl reboot";
      myip = "ip a | grep '/24' | awk '{print $2}' | sed 's/\\/24//'";
      cli = "cli-visualizer";
      tiempo = "curl wttr.in/corregidora";
      time = "curl wttr.in/corregidora";
      snvim = "sudo -E nvim";
      check = "ping www.google.com";
      quit = "exit";
      back = "cd $buffer";
      hotspot = "sudo create_ap wlp4s0 enp3s0 sipo sipo1234";
    };
    interactiveShellInit = ''
      export GPG_TTY="$(tty)"

      # Edición de línea estilo Vim
      bindkey -v
      KEYTIMEOUT=10
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line

      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word
      bindkey '^H' backward-kill-word

      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      export NVM_DIR="$HOME/.nvm"
      if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
      fi
      if [[ -s "$NVM_DIR/bash_completion" ]]; then
        autoload -U +X bashcompinit && bashcompinit
        source "$NVM_DIR/bash_completion"
      fi
    '';
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    DISPLAY = ":0";
    GTK_USE_PORTAL = "1";
    GDK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    # DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

  environment.extraInit = ''
    export PATH="$HOME/.cargo/bin:$PATH"
  '';

  # users.users.nixosvmtest = {
  #   isNormalUser = true;
  #   initialPassword = "testpassword"; # Use this to log in
  #   extraGroups = [ "wheel" ]; # Allows sudo access
  # };
  #
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      experimental = true;
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu;
      swtpm.enable = true;
    };
  };

  users.users.emilio = {
    isNormalUser = true;
    description = "emilio";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "input" "libvirtd" "kvm"];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.permittedInsecurePackages = [
  #    "libxml2-2.13.8"
  # ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Steam configurations
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  # services.zerotierone.enable = true;
  # services.terraria.enable = true;
  # services.terraria.openFirewall = true;

  programs.xwayland.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = false;

    packages = with pkgs; [
      fira-code
      fira-code-symbols
      noto-fonts         
      liberation_ttf     
      dejavu_fonts
      font-awesome
      nerd-fonts.caskaydia-mono
    ];
  };

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

  services.dbus.enable = true;
  xdg.portal.wlr.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
    config = {
      common.default = [ "gtk" ];
      niri = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        default = [ "gtk" ];
      };
    };
  };

  programs.dconf.enable = true;

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
    allowedTCPPorts = [ 7777 ];
    allowedUDPPorts = [ 7777 9993 ];

    # Allow addresses to conect into specific ports
    # allowedTCPConnections = [
    #   {
    #     port = 22;
    #     sourceAddress = "192.168.1.100";
    #   }
    # ];

    # Allow Avahi/mDNS only on local Wi-Fi
    interfaces."wlp4s0".allowedUDPPorts = [ 5353 45259 34445 53317 7777 ];
    interfaces."wlp4s0".allowedTCPPorts = [  ];

    allowPing = false;
    logRefusedConnections = true;
  };

  system.stateVersion = "24.05";
}

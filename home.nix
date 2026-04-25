{ pkgs, config, ... }:
{
  imports = [
    ./gtk-qt.nix
    ./yazi.nix
    ./nvim.nix
    ./foot.nix
  ];
  home.stateVersion = "25.05";
  home.username = "emilio";
  home.homeDirectory = "/home/emilio";

  # Programs
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.foot.enable = true;
  programs.mpv.enable = true;
  programs.yazi.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  services.swayosd.enable = true;
  gtk.enable = true;

  # Configs
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-application-prefer-dark-theme = 1;
    };
  };


  programs.mpv.config = {
    hwdec = "vaapi";
    hwdec-codecs = "all";
    gpu-api = "opengl";
  };

  xdg.configFile."Thunar/uca.xml".source = ./configs/thunar.uca.xml;
  xdg.configFile."niri/config.kdl".source = ./configs/niri/config.kdl;
  xdg.configFile."waybar/config".source = ./configs/waybar/config;
  xdg.configFile."waybar/style.css".source = ./configs/waybar/style.css;

  programs.bash = {
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      off = "systemctl poweroff";
      # reboot = "systemctl reboot";
      myip = "ip a | grep '/24' | awk '{print $2}' | sed 's/\\/24//'";
      cli = "cli-visualizer";
      time = "curl wttr.in/corregidora";
      snvim = "sudo -E nvim";
      check = "ping www.google.com";
      quit = "exit";
      back = "cd $buffer";
      hotspot = "sudo create_ap wlp4s0 enp3s0 sipo sipo1234";
    };

    # Variables de entorno
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      PATH = "${builtins.getEnv "HOME"}/.cargo/bin:$PATH";
      GPG_TTY = "$(tty)";
      DISPLAY = ":0";
      GTK_USE_PORTAL = "1";
      GDK_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      # DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock";
    };

    # Config extra que no es alias ni env var
    bashrcExtra = ''
      # Prompt con nombre de branch git
      PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
      PS1='\[\e[38;5;51m\][\u@\h][\W]{''${PS1_CMD1}}\$ \[\e[0m\]'
      eval "$(direnv hook bash)"
    '';
  };

}

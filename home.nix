{ ... }:
{
  imports = [
    ./home/gtk-qt.nix
    ./home/yazi.nix
    ./home/nvim.nix
    ./home/foot.nix
    ./home/mako.nix
    ./home/zsh.nix
  ];
  home.stateVersion = "25.05";
  home.username = "emilio";
  home.homeDirectory = "/home/emilio";

  # Programs
  programs.home-manager.enable = true;
  programs.foot.enable = true;
  programs.mpv.enable = true;
  programs.yazi.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  services.swayosd.enable = true;
  gtk.enable = true;

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MOZ_ENABLE_WAYLAND = "1";
    DISPLAY = ":0";
    GTK_USE_PORTAL = "1";
    GDK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    # DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

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


  xdg.configFile."niri/config.kdl".source = ./configs/niri/config.kdl;
  xdg.configFile."nvim".source = ./configs/nvim;
  xdg.configFile."waybar".source = ./configs/waybar;
}

{ pkgs, ... }:

let
  # ciscoPacketTracer = pkgs.ciscoPacketTracer8.overrideAttrs (oldAttrs: {
  #   src = /home/emilio/packettracer/CiscoPacketTracer822_amd64_signed.deb;
  # });
in
{
  environment.systemPackages = with pkgs; [
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
     libGLU
     curl
     nethogs
     yazi
     gammastep
     pwvucontrol
     waypaper
     swww
     jq
     jaq
     ffmpeg
     cmus
     kdePackages.okular
     direnv
     ouch
     xdg-utils
     xdg-desktop-portal
     xdg-desktop-portal-wlr

     # IDE's
#    android-tools
     neovim
     zed-editor
     godot_4
     gdtoolkit_4

     # vim plugins
     vimPlugins.lazygit-nvim
     vimPlugins.plenary-nvim
     vimPlugins.vim-visual-multi
     vimPlugins.neoformat

     # Language servers
     sqlite
     sqlite-web
     nodejs

     # kotlin
     # flutter
     # rustc
     # cargo
     # ciscoPacketTracer 
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

}

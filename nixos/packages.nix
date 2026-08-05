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
    # thunar
    # thunar-volman
    pipewire
    xwayland-satellite
    btop
    foot
    clang
    wl-clipboard
    wlr-randr
    gvfs
    qalculate-gtk
    libreoffice-fresh
    localsend
    waybar
    mpv
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
    grim
    imagemagick
    libGLU
    curl
    nethogs
    yazi
    gammastep
    waypaper
    awww
    jq
    jaq
    ffmpeg
    cmus
    direnv
    ouch
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    eza
    fzf

    neovim

    # Language servers
    # kotlin
    # flutter
    # rustc
    # cargo
    # ciscoPacketTracer
    python3
    openjdk

    logseq
    gh

    conda

    gemini-cli
    opencode

    # tuis
    wiremix
    bluetui
    lazygit
    lazyssh
    lazydocker

    # waybar
    wf-recorder
    libnotify
    gsimplecal

    libvirt
    virt-manager
    virt-viewer

    exiftool
    mako
    eden
    wl-mirror

    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum

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

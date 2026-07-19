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
    htop
    foot
    clang
    wl-clipboard
    wlr-randr
    gvfs
    qalculate-gtk
    # libreoffice
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
    # linux-wifi-hotspot
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
    kdePackages.okular
    direnv
    ouch
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    eza
    fzf

    # IDE's
    # android-tools
    neovim
    # godot_4
    # gdtoolkit_4

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

    # agents
    gemini-cli
    # codex
    opencode

    # tuis
    wiremix
    bluetui
    lazygit
    lazyssh
    # lazyworktree

    # waybar
    wl-screenrec
    libnotify
    gsimplecal

    # vms
    libvirt
    virt-manager
    virt-viewer

    # notifications
    mako

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

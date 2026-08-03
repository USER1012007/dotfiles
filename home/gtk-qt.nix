{ lib, pkgs, ... }:

let
  catppuccinAccent = "lavender";
  catppuccinFlavor = "Mocha";

  # catppuccinKvantum = pkgs.catppuccin-kvantum.override {
  #   accent = "${lib.toLower catppuccinAccent}";
  #   variant = "${lib.toLower catppuccinFlavor}";
  # };

  # catppuccinKvantum = pkgs.catppuccin-kvantum.override {
  #   accent = "${lib.toLower catppuccinAccent}";
  #   variant = "${lib.toLower catppuccinFlavor}";
  # };
in

{

  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "${lib.toLower catppuccinFlavor}";
        accent = "${lib.toLower catppuccinAccent}";
      };
    };

    gtk3 = {

      bookmarks = [
        "file:///home/emilio/ai_storage/"
        "file:///home/emilio/Books/"
        "file:///home/emilio/Desktop/"
        "file:///home/emilio/Documents/"
        "file:///home/emilio/Downloads/"
        "file:///home/emilio/Games/"
        "file:///home/emilio/Languages/"
        "file:///home/emilio/Music/"
        "file:///home/emilio/Pictures/"
        "file:///home/emilio/usb/"
        "file:///home/emilio/work/"
      ];
      extraConfig.gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {

      gtk-icon-theme-name = "Adwaita";
      gtk-theme-name = "Adwaita-dark";
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "macOS";
    };
    gtk4.theme = null;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # style.name = "";
  };
}

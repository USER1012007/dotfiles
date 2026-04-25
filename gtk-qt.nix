{lib, pkgs, ...}: 

let
  catppuccinAccent = "lavender";
  catppuccinFlavor = "Mocha";

  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    accent = "${lib.toLower catppuccinAccent}";
    variant = "${lib.toLower catppuccinFlavor}";
  };

  qtThemeName = "catppuccin-${lib.toLower catppuccinFlavor}-${lib.toLower catppuccinAccent}";
in

{

  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-${lib.toLower catppuccinFlavor}-${lib.toLower catppuccinAccent}-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = ["${lib.toLower catppuccinAccent}"];
        size = "standard";
        variant = "${lib.toLower catppuccinFlavor}";
      };
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
        "file:///home/emilio/Books/"
        "file:///home/emilio/Desktop/"
        "file:///home/emilio/Documents/"
        "file:///home/emilio/Downloads/"
        "file:///home/emilio/Languages/"
        "file:///home/emilio/Learning/"
        "file:///home/emilio/Music/"
        "file:///home/emilio/Pictures/"
        "file:///home/emilio/usb/"
        "file:///home/emilio/Work/"
        "file:///home/emilio/Pictures/.wallpapers/"
      ];
      extraConfig.gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-icon-theme-name = "Adwaita";
      gtk-theme-name = "Adwaita-dark";
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "macOS";
    };
  };


  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
}

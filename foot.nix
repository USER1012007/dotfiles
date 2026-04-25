{...}:{

  programs.foot.settings = {
    main = {
      font = "CaskaydiaMonoNerdFont:size=14";
      dpi-aware = false;
    };
    colors-dark = {
      alpha = 0.7;
      background = "000000";
      foreground = "FFFFFF";
      ## Normal/regular colors (color palette 0-7)
      regular0 = "000000"; # black
      regular1 = "cd0000"; # red
      regular2 = "00cd00"; # green
      regular3 = "cdcd00"; # yellow
      regular4 = "87ceeb"; # blue
      regular5 = "cd00cd"; # magenta
      regular6 = "00cdcd"; # cyan
      regular7 = "e5e5e5"; # white

      ## Bright colors (color palette 8-15)
      bright0 = "7f7f7f"; # bright black
      bright1 = "ff0000"; # bright red
      bright2 = "00ff00"; # bright green
      bright3 = "ffff00"; # bright yellow
      bright4 = "add8e6"; # bright blue
      bright5 = "ff00ff"; # bright magenta
      bright6 = "00ffff"; # bright cyan
      bright7 = "ffffff"; # bright white
    };
  };
}

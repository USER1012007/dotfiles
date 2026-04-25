{pkgs, ...}:
let
  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
    hash = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s=";
  };
  yazi-lazygit = builtins.fetchGit {
    url = "https://github.com/Lil-Dank/lazygit.yazi.git";
    rev = "0e56060192d1ccd307664bf93b3d0beb1efe528e";
  };
in
{

  programs.yazi = {
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      ouch = pkgs.yaziPlugins.ouch;
    };
    flavors = {
      catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Open mount plugin";
        }
        {
          on = "<S-j>";
          run = "arrow 5";
          desc = "Move cursor down 5 positions";
        }
        {
          on = "<S-k>";
          run = "arrow -5";
          desc = "Move cursor up 5 positions";
        }
        {
          on = [ "<C-n>" ];
          run = "shell 'ripdrag \"$@\" -dx 2>/dev/null &' --confirm";
        }
        {
          on = "C";
          run = "plugin ouch";
          desc = "Compress with ouch";
        }
        {
          on   = [ "g" "i" ];
          run  = "plugin lazygit";
          desc = "run lazygit";
        }
        {
          on   = [ "e" ];
          run  = "shell --orphan --confirm foot";
          desc = "run foot terminal";
        }
        {
          on   = [ "u" ];
          run  = "shell --orphan --confirm 'foot yazi'";
          desc = "run yazi";
        }
        {
          on = [ "<C-w>" ];
          run = "close";
          desc = "Close the current tab";
        }
      ];
    };
    settings = {
      opener = {
        play = [
          {
            run = "mpv \"$@\"";
            orphan = true;
            for = "unix";
          }
        ];
        edit = [
          {
            run = "nvim \"$@\"";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "xdg-open \"$@\"";
            desc = "Open";
          }
        ];
        extract = [
          {
            run = "unzip \"$@\"";
            desc = "Extract here with unzip";
            for = "unix";
          }
        ];
      };
      open = {
        prepend_rules = [
          {
            name = "*.zip";
            use = "extract";
          }
        ];
      };
      plugin = {
        prepend_previewers = [
          {
            mime = "application/*zip";
            run = "ouch";
          }
          {
            mime = "application/x-tar";
            run = "ouch";
          }
          {
            mime = "application/x-bzip2";
            run = "ouch";
          }
          {
            mime = "application/x-7z-compressed";
            run = "ouch";
          }
          {
            mime = "application/x-rar";
            run = "ouch";
          }
          {
            mime = "application/x-xz";
            run = "ouch";
          }
          {
            mime = "application/xz";
            run = "ouch";
          }
        ];
      };
    };
    theme = {
      flavor = {
        # dark = "catppuccin-mocha";
      };
    };
  };

  xdg.configFile."yazi/plugins/lazygit.yazi".source = yazi-lazygit;
}

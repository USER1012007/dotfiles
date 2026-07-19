{ pkgs, ... }: {

  programs.neovim = {

    enable = true;

    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      # nvchad plugins
      ripgrep
      nil
      lua-language-server
      xclip

      clang-tools
      pyright
      # rust-analyzer
      rustfmt
      nixfmt
      lua-language-server
      lombok
      # jdt-language-server
      nodejs
      yarn
      tree-sitter

      # vim plugins
      vimPlugins.lazygit-nvim
      vimPlugins.plenary-nvim
      vimPlugins.vim-visual-multi
      vimPlugins.markdown-preview-nvim
      # vimPlugins.nvim-jdtls

      # golang
      # gopls
      # gotools
      # delve
      # go

      # dependencies for nvchad
      unzip
      wl-mirror
      rsync
      _7zz
      gnupg
      pinentry-tty

      # Vue + TypeScript LSP
      vtsls
      vue-language-server
      prettierd
      prettier
      eslint_d
    ];

  };
}

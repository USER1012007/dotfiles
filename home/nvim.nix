{pkgs, ...}: {

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
       # rust-analyzer
       lua-language-server
       lombok
       # jdt-language-server
       nodejs
       tree-sitter

       # vim plugins
       vimPlugins.lazygit-nvim
       vimPlugins.plenary-nvim
       vimPlugins.vim-visual-multi
       vimPlugins.neoformat
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
    ];

  };
}

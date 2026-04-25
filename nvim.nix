{pkgs, ...}: {

  programs.neovim = {
    enable = true;
    plugins = [];
    extraPackages = with pkgs; [
       # nvchad plugins
       ripgrep
       nil     
       lua-language-server
       xclip   

       clang-tools
       rust-analyzer
       lua-language-server
       lombok
       jdt-language-server
       nodejs
       tree-sitter

       # vim plugins
       vimPlugins.lazygit-nvim
       vimPlugins.plenary-nvim
       vimPlugins.vim-visual-multi
       vimPlugins.neoformat
       vimPlugins.nvim-jdtls
       gopls
       gotools 
       delve
       go
    ];

    extraPython3Packages = python3Packages: with python3Packages; [
      pynvim
    ];
  };
}

{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    completionInit = ''
      # Asegura que el motor se inicialice correctamente en el orden correcto
      autoload -Uz compinit && compinit

      # DIFERENCIA VISUAL: Convierte la lista en un menú interactivo
      zstyle ':completion:*' menu select

      # DIFERENCIA DE CASOS: Ignora mayúsculas/minúsculas al autocompletar
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
    '';
  };
}

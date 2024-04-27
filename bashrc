# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias off='loginctl poweroff'
alias reboot='loginctl reboot'
alias myip="ip a | grep '/24' | awk '{print \$2}' | sed 's/\/24//'"
alias cli='cli-visualizer'
alias tiempo='curl wttr.in/corregidora'
alias snvim='sudo -E nvim'
alias check='ping www.google.com'
alias quit='exit'
alias back='cd $buffer'

PS1='[\u@\h \W]\$ '
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'; PS1='\[\e[38;5;51m\][\u@\h][\W]{${PS1_CMD1}}\$ \[\e[0m\]'

export MOZ_ENABLE_WAYLAND=1
export PATH=/home/emilio/.cargo/bin:$PATH


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias off='sudo off'
alias myip="ip a | grep '/24' | awk '{print \$2}'"
alias cli='cli-visualizer'
alias tiempo='curl wttr.in/corregidora'
alias snvim='sudo -E nvim'
alias check='ping www.google.com'
alias quit='exit'
alias back='cd $buffer'

PS1='[\u@\h \W]\$ '
PS1='\[\e[38;5;51m\][\u@\h][\W]\$ \[\e[0m\]'

export LIBVA_DRIVER_NAME=i965
export G_MESSAGES_DEBUG="all /usr/lib/fprintd -t"

export XCURSOR_SIZE=12

export XSECURELOCK_SHOW_DATETIME=1
export XSECURELOCK_DATETIME_FORMAT="%b %d %Y  %I:%M%p"
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share
export PATH=$PATH:/var/lib/flatpak/exports/bin
export PATH=/usr/bin:$PATH
export REPO_OS_OVERRIDE="linux"
export PATH="/home/emilio/.turso:$PATH"
export ANDROID_HOME=$HOME/Android/
export PATH=$ANDROID_HOME/cmdline-tools:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH

export ANDROID_HOME_SDK=$HOME/Android/
export PATH=$ANDROID_HOME_SDK:$PATH

export FLUTTER=$ANDROID_HOME/flutter
export PATH=$FLUTTER/bin:$PATH

export MOZ_ENABLE_WAYLAND=1
buffer=$(pwd)

export PATH=/home/emilio/.cargo/bin:$PATH



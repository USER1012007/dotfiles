#!/bin/bash
#
# ░█▀▀░█░█░█▀█░█░█░█░░░█▀█░█▀▀░█░█
# ░▀▀█░█▄█░█▀█░░█░░█░░░█░█░█░░░█▀▄
# ░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀▀▀░▀░▀
#
# create a lock screen image from the current desktop background for swaylock
# to use.
#
# ----------------------------------------------------------------------------

tgt_dir=$HOME/Pictures
tgt_file=${tgt_dir}/screenlockimage.png

mkdir -p ${tgt_dir}

if [ $(command -v grim mogrify | wc -l) -eq 2 ]; then 
    grim -o DP-2 ${tgt_file}|| grim -o eDP-1 ${tgt_file}
    mogrify -blur 0x5 ${tgt_file} 
    swaylock -i ${tgt_file}
else
    swaylock
fi
rm ${tgt_file}

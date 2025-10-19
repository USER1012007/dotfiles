#!/bin/bash

slstatus &

xset r rate 300 50 &

numlockx on &

notify-send "Welcome back $USER"

xwallpaper --zoom ~/Pictures/background9.jpg

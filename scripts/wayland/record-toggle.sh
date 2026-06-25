#!/usr/bin/env bash

PIDFILE="/tmp/wl-screenrec.pid"
SAVEDIR="$HOME/Pictures/screen_records"

mkdir -p "$SAVEDIR"

if [ -f "$PIDFILE" ]; then
    kill -SIGINT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Grabación detenida" "Guardada en $SAVEDIR"
else
    FILENAME="$SAVEDIR/$(date '+%Y-%m-%d_%H-%M-%S').mp4"
    wl-screenrec --audio -f "$FILENAME" &
    echo $! > "$PIDFILE"
    notify-send "Grabando pantalla" "$FILENAME"
fi

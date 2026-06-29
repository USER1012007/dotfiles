#!/usr/bin/env bash

PIDFILE="/tmp/wl-screenrec.pid"
SAVEDIR="$HOME/Pictures/screen_records"

refresh_waybar() {
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

mkdir -p "$SAVEDIR"

if [ -f "$PIDFILE" ]; then
    kill -SIGINT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Grabación detenida" "Guardada en $SAVEDIR"
    refresh_waybar
else
    FILENAME="$SAVEDIR/$(date '+%Y-%m-%d_%H-%M-%S').mp4"
    wl-screenrec --audio -f "$FILENAME" &
    echo $! > "$PIDFILE"
    refresh_waybar
fi

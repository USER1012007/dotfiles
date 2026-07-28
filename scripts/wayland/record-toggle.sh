#!/usr/bin/env bash

SAVEDIR="$HOME/Pictures/screen_records"
mkdir -p "$SAVEDIR"

if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Grabación detenida" "Guardada en $SAVEDIR"

else
    AUDIO_SINK=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk -F'"' '/node.name/ {print $2}')

    FILENAME="$SAVEDIR/$(date '+%Y-%m-%d_%H-%M-%S').mp4"

    if [ -n "$AUDIO_SINK" ]; then
        wf-recorder --audio="${AUDIO_SINK}.monitor" -f "$FILENAME" &
    else
        wf-recorder --audio -f "$FILENAME" &
    fi
fi

pkill -RTMIN+8 waybar 2>/dev/null || true

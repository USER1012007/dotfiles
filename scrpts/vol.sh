#!/bin/bash

amixer_output="$(amixer get Master | grep Left: | sed 's/[][]//g' | awk '{print $5, $6}')"
VOL="$(echo "$amixer_output" | awk '{print $1}' | tr -d '%')"
VOLONOFF="$(echo "$amixer_output" | awk '{print $2}')"

VOLICON=""
MUTEICON=" "
 
if [ "$VOLONOFF" == "on" ]; then
    if [[ "$VOL" =~ ^[0-9]+$ ]]; then
        if [ "$VOL" -ge 100 ]; then
            VOL="100"
        fi
        echo "$VOLICON $VOL%"
    fi
else
	echo "$MUTEICON"
fi


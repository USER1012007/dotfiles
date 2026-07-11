#!/usr/bin/env bash
# get the metadata from the .json
# jq -r '.items[] | (.track? // .item?) as $track | select($track != null and $track.type == "track") | "\($track.name)|\($track.artists | map(.name) | join(", "))|\($track.album.name)|\($track.album.images[0].url)"' playlist.json

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

DIR="$1"

if [[ ! -d "$DIR" ]]; then
    echo "'$DIR' no es un directorio válido."
    exit 1
fi

for file in "$DIR"/*.txt; do
    [[ -f "$file" ]] || continue  
    
    awk -F'|' 'NF >= 2 {print $1 "," $2}' "$file" | while IFS= read -r query; do
        [[ -z "$query" ]] && continue  
        
        URL=$(yt-dlp "ytsearch1:$query" --get-id)

        echo "https://www.youtube.com/watch?v=$URL"
    done
done

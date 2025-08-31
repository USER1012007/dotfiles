#!/usr/bin/env bash

if [[ $# -lt 2 ]]; then
    echo "Uso: $0 -n <nombre_subcarpeta> <archivo_urls>"
    exit 1
fi


while getopts "n:" opt; do
  case $opt in
    n) NAME="$OPTARG" ;;
    *) echo "Uso: $0 -n <nombre_subcarpeta> <archivo_urls>" ; exit 1 ;;
  esac
done

shift $((OPTIND-1))

URL_FILE="$1"
DEST_DIR="/home/emilio/Music/spotify_playlists/music/wav/$NAME"

if [[ ! -f "$URL_FILE" ]]; then
    echo "❌ El archivo '$URL_FILE' no existe."
    exit 1
fi

mkdir -p "$DEST_DIR"

while IFS= read -r url; do
    [[ -z "$url" ]] && continue 
    echo "🎵 Descargando: $url"
    yt-dlp -P "$DEST_DIR" -f 'ba' --no-playlist -x --audio-format wav "$url"
done < "$URL_FILE"

echo "✅ Descargas completadas en: $DEST_DIR"


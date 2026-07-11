#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Uso: $0 -n <nombre_subcarpeta> <archivo_urls>"
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

while getopts "n:" opt; do
  case $opt in
    n) NAME="$OPTARG" ;;
    *) usage ; exit 1 ;;
  esac
done

shift $((OPTIND-1))

if [[ -z "${NAME:-}" || $# -lt 1 ]]; then
    usage
    exit 1
fi

URL_FILE="$1"
BASE_DIR="${SP_BASE_DIR:-$HOME/Music/spotify_playlists}"
DEST_DIR="$BASE_DIR/music/wav/$NAME"

if [[ ! -f "$URL_FILE" ]]; then
    echo "El archivo '$URL_FILE' no existe."
    exit 1
fi

mkdir -p "$DEST_DIR"

INDEX=1
while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    echo "Descargando: $url"
    NUM=$(printf "%02d" "$INDEX")
    yt-dlp \
      --extractor-args "youtube:player-client=android" \
      --add-header "User-Agent: com.google.android.youtube/19.15.37 (Linux; U; Android 13)" \
      -P "$DEST_DIR" \
      -o "$NUM - %(title)s.%(ext)s" \
      -f "bestaudio/best" \
      --no-playlist \
      -x --audio-format wav \
      "$url" || echo "Error al descargar: $url"
    ((INDEX+=1))
    sleep $((RANDOM % 3 + 2))
done < "$URL_FILE"

#!/usr/bin/env bash
# Convierte WAV a Opus 320 kbps VBR, agrega metadata y ReplayGain
# Requiere: opusTools, r128gain, curl

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "Uso: $0 <archivo_metadatos.txt> <carpeta_wav> <destino_opus>"
    exit 1
fi

METADATA_FILE="$1"
SRC_DIR="$2"
DEST_DIR="$3"
NOT_FOUND_FILE="missing_wavs.txt"
> "$NOT_FOUND_FILE"  

mkdir -p "$DEST_DIR"

INDEX=1

while IFS='|' read -r title artist album cover_url; do
    [[ -z "$title" ]] && continue

WAV_FILE=$(find "$SRC_DIR" -type f -iname "*.wav" \
    | grep -i "$(echo "$title" | sed 's/[-(].*//')" || true \
    | head -n1)
    if [[ -z "$WAV_FILE" ]]; then
        echo "⚠️ No se encontró archivo .wav para: $title" 
        echo "$title|$artist|$album|$cover_url" >> "$NOT_FOUND_FILE"
        ((INDEX++))
        continue
    fi

    TMP_COVER="/tmp/cover_${INDEX}.jpg"
    if [[ -n "$cover_url" ]]; then
        curl -sL "$cover_url" -o "$TMP_COVER"
    fi

    NUM=$(printf "%02d" "$INDEX")
    BASE_NAME="$NUM - $artist - $title.opus"
    OUT_FILE="$DEST_DIR/$BASE_NAME"

    echo "🎵 Procesando: $WAV_FILE → $OUT_FILE"

    if [[ -f "$TMP_COVER" ]]; then
        opusenc --title "$title" --artist "$artist" --album "$album" --picture "$TMP_COVER" --bitrate 320 --vbr "$WAV_FILE" "$OUT_FILE"
    else
        opusenc --title "$title" --artist "$artist" --album "$album" --bitrate 320 --vbr "$WAV_FILE" "$OUT_FILE"
    fi

    r128gain -r "$OUT_FILE"

    if [[ $? -eq 0 ]]; then
        echo "✅ Listo: $OUT_FILE"
    else
        echo "❌ Error al procesar: $WAV_FILE"
    fi

    ((INDEX++))
done < "$METADATA_FILE"

echo "✅ Todos los archivos procesados con metadata, 320 kbps y ReplayGain."

#!/usr/bin/env bash
# Convierte WAV a Opus 320 kbps VBR, elimina silencios, agrega metadata y ReplayGain
# Requiere: ffmpeg, opusenc, rsgain, curl

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

while IFS='|' read -r title artist album cover_url <&3; do
    [[ -z "${title:-}" ]] && continue

    CLEAN_TITLE=$(echo "$title" | iconv -c -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
    SEARCH_TITLE=$(echo "$CLEAN_TITLE" | sed -E 's/[^a-z0-9]+/.*/g')

    echo "Buscando WAV para título: '$title' → patrón: '$SEARCH_TITLE'"

    WAV_FILE=$(find "$SRC_DIR" -type f -iname "*.wav" | while read -r f; do
        CLEAN_NAME=$(basename "$f" | iconv -c -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
        if [[ "$CLEAN_NAME" =~ $SEARCH_TITLE ]]; then
            echo "$f"
            break
        fi
    done)

    if [[ -z "${WAV_FILE:-}" ]]; then
        echo "⚠️ No se encontró archivo .wav para: $title"
        echo "$title|$artist|$album|$cover_url" >> "$NOT_FOUND_FILE"
        continue
    fi

    BASE_NAME="$artist - $title.opus"
    OUT_FILE="$DEST_DIR/$BASE_NAME"

    TMP_COVER=$(mktemp /tmp/cover_XXXX.jpg)
    if [[ -n "${cover_url:-}" ]]; then
        curl -sL "$cover_url" -o "$TMP_COVER" || true
    fi

    echo "Procesando: $WAV_FILE → $OUT_FILE"

    {
        TMP_WAV=$(mktemp /tmp/XXXX.wav)

        ffmpeg -v quiet -y -i "$WAV_FILE" \
        -af "silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,areverse,\
        silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,areverse" \
        -c:a pcm_s16le -ar 44100 -ac 2 "$TMP_WAV"

        if [[ -f "$TMP_COVER" && -s "$TMP_COVER" ]]; then
            opusenc --title "$title" --artist "$artist" --album "$album" \
                    --picture "$TMP_COVER" --bitrate 320 --vbr "$TMP_WAV" "$OUT_FILE"
        else
            opusenc --title "$title" --artist "$artist" --album "$album" \
                    --bitrate 320 --vbr "$TMP_WAV" "$OUT_FILE"
        fi

        rm -f "$TMP_WAV" "$TMP_COVER"

        # Aplicar ReplayGain
        if rsgain custom -s 'i' -l '-18' -o 't' "$OUT_FILE"; then
            echo "✅ ReplayGain aplicado: $OUT_FILE"
        else
            echo "⚠️ Error al aplicar ReplayGain en $OUT_FILE"
        fi

        echo "✅ Listo: $OUT_FILE"

    } || {
        echo "❌ Falló el procesamiento de: $title"
        rm -f "$TMP_WAV" "$TMP_COVER" || true
        continue
    }

    ((INDEX++))
done 3< "$METADATA_FILE"

echo "🏁 Todos los archivos procesados con metadata, carátula y ReplayGain."
echo "📄 Canciones no encontradas guardadas en: $NOT_FOUND_FILE"

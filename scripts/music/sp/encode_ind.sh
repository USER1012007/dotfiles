#!/usr/bin/env bash
# Convierte un WAV individual a Opus 320 kbps VBR con metadata
# Uso: encode_ind.sh <metadata.txt> <archivo.wav> <destino_dir>
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Uso: $0 <metadata.txt> <archivo.wav> <destino_dir>"
  exit 1
fi

METADATA_FILE="$1"
WAV_FILE="$2"
DEST_DIR="$3"

if [[ ! -f "$WAV_FILE" ]]; then
  echo "[✘] Archivo WAV no existe: $WAV_FILE"
  exit 1
fi

if [[ ! -f "$METADATA_FILE" ]]; then
  echo "[✘] Archivo de metadata no existe: $METADATA_FILE"
  exit 1
fi

mkdir -p "$DEST_DIR"

# Leer la primera (y única) línea del metadata
IFS='|' read -r title artist album cover_url < "$METADATA_FILE"

if [[ -z "${title:-}" ]]; then
  echo "[✘] Metadata vacío o inválido"
  exit 1
fi

echo "Procesando: $title - $artist"

OUT_FILE="$DEST_DIR/$artist - $title.opus"

TMP_WAV=$(mktemp /tmp/wav_XXXX.wav)
TMP_COVER=$(mktemp /tmp/cover_XXXX.jpg)

# Descargar cover
if [[ -n "${cover_url:-}" ]]; then
    echo "  → Descargando cover..."
    curl -sL "$cover_url" -o "$TMP_COVER" 2>/dev/null || rm -f "$TMP_COVER"
fi

# Procesar audio
echo "  → Procesando audio con ffmpeg..."
if ffmpeg -v warning -y -i "$WAV_FILE" \
    -af "silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,areverse,silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,areverse" \
    -c:a pcm_s16le -ar 44100 -ac 2 "$TMP_WAV"; then
    
    if [[ -s "$TMP_WAV" ]]; then
        echo "  → Codificando a Opus..."
        if [[ -f "$TMP_COVER" && -s "$TMP_COVER" ]]; then
            opusenc --title "$title" --artist "$artist" --album "$album" \
                    --picture "$TMP_COVER" --bitrate 320 --vbr "$TMP_WAV" "$OUT_FILE"
        else
            opusenc --title "$title" --artist "$artist" --album "$album" \
                    --bitrate 320 --vbr "$TMP_WAV" "$OUT_FILE"
        fi
        
        echo "  → Aplicando ReplayGain..."
        if rsgain custom -s 'i' -l '-18' -o 't' "$OUT_FILE" &>/dev/null; then
            echo "  [✓] ReplayGain aplicado"
        fi
        
        echo "[✓] Completado: $OUT_FILE"
    else
        echo "[✘] Archivo temporal vacío"
        rm -f "$TMP_WAV" "$TMP_COVER"
        exit 1
    fi
else
    echo "[✘] Error en ffmpeg"
    rm -f "$TMP_WAV" "$TMP_COVER"
    exit 1
fi

rm -f "$TMP_WAV" "$TMP_COVER"

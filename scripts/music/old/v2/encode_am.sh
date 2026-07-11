#!/usr/bin/env bash
# Convierte WAV a Opus 320 kbps VBR, elimina silencios, agrega metadata y ReplayGain
# Requiere: ffmpeg, opusenc, rsgain, curl

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Uso: $0 <archivo_metadatos.txt> <carpeta_wav> <destino_opus> [numero_inicial (0:0-100) (1:100-200) ...]"
    exit 1
fi

sanitize_filename() {
    local value="$1"
    value=$(printf '%s' "$value" | tr '/\\:*?"<>|' '_' | tr -s ' ')
    value=${value#"${value%%[![:space:]]*}"}
    value=${value%"${value##*[![:space:]]}"}
    printf '%s' "${value:-unknown}"
}

normalize_text() {
    printf '%s' "$1" \
        | iconv -c -t ascii//TRANSLIT \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/ /g; s/^ +//; s/ +$//; s/ +/ /g'
}

find_wav_for_track() {
    local title="$1"
    local artist="$2"
    local fallback_index="$3"
    local title_norm artist_norm file file_norm token match

    title_norm=$(normalize_text "$title")
    artist_norm=$(normalize_text "$artist")

    for file in "${WAV_FILES[@]}"; do
        file_norm=$(normalize_text "$(basename "$file")")
        match=1

        for token in $title_norm; do
            if [[ "$file_norm" != *"$token"* ]]; then
                match=0
                break
            fi
        done

        if [[ "$match" -eq 1 ]]; then
            printf '%s\n' "$file"
            return 0
        fi
    done

    for file in "${WAV_FILES[@]}"; do
        file_norm=$(normalize_text "$(basename "$file")")
        match=0

        for token in $title_norm $artist_norm; do
            if [[ ${#token} -ge 4 && "$file_norm" == *"$token"* ]]; then
                ((match+=1))
            fi
        done

        if [[ "$match" -ge 2 ]]; then
            printf '%s\n' "$file"
            return 0
        fi
    done

    if [[ -n "${WAV_FILES[$fallback_index]:-}" ]]; then
        printf '%s\n' "${WAV_FILES[$fallback_index]}"
        return 0
    fi

    return 1
}

BASE_DIR="${SP_BASE_DIR:-$HOME/Music/spotify_playlists}"
META_BASE="$BASE_DIR/data"
WAV_BASE="$BASE_DIR/music/wav"
OPUS_BASE="$BASE_DIR/music/opus"

METADATA_FILE="$META_BASE/$1"
SRC_DIR="$WAV_BASE/$2"
DEST_DIR="$OPUS_BASE/$3"
NUM_INIT=${4:-0}

if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Archivo de metadata no existe: $METADATA_FILE"
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Carpeta WAV no existe: $SRC_DIR"
    exit 1
fi

mkdir -p "$DEST_DIR"

mapfile -t WAV_FILES < <(find "$SRC_DIR" -type f -iname "*.wav" | sort -V)
if [[ "${#WAV_FILES[@]}" -eq 0 ]]; then
    echo "No hay archivos WAV en: $SRC_DIR"
    exit 1
fi

INDEX=$((NUM_INIT * 100 + 1))
TRACK_POS=0

while IFS='|' read -r title artist album cover_url <&3; do
    [[ -z "${title:-}" ]] && continue

    WAV_FILE=$(find_wav_for_track "$title" "$artist" "$TRACK_POS" || true)

    if [[ -z "$WAV_FILE" ]]; then
        echo "No encontré WAV para: $title"
        ((TRACK_POS+=1))
        continue
    fi

    NUM=$(printf "%02d" "$INDEX")
    SAFE_ARTIST=$(sanitize_filename "$artist")
    SAFE_TITLE=$(sanitize_filename "$title")
    BASE_NAME="$NUM - $SAFE_ARTIST - $SAFE_TITLE.opus"
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

        if rsgain custom -s 'i' -l '-18' -o 't' "$OUT_FILE"; then
            echo "ReplayGain aplicado: $OUT_FILE"
        fi

    } || {
        echo "Falló el procesamiento de: $title"
        rm -f "${TMP_WAV:-}" "$TMP_COVER" || true
        continue
    }

    ((INDEX+=1))
    ((TRACK_POS+=1))
done 3< "$METADATA_FILE"

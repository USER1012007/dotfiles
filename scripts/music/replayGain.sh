#!/usr/bin/env bash

set -euo pipefail

DIR="${1:-.}"

find "$DIR" -type f -name "*.opus" | while read -r file; do
    echo "➕ Añadiendo ReplayGain a: $file"
    opusgain --track "$file"
done

echo "✅ Proceso completado."

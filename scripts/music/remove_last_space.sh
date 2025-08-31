#!/bin/bash

archivo="$1"

if [ ! -d "$archivo" ]; then
    echo "Error: Folder '$archivo' not found."
    exit 1
fi

for file in "$archivo"/*; do
    if [ -f "$file" ]; then
        nombre_sin_extension=$(basename "$file" | cut -d'.' -f1)
        
        # Verifica si el nombre tiene espacio al final
        if [[ "$nombre_sin_extension" =~ " " ]]; then
            # Extrae el codec y realiza la operación de renombrado
            codec=$(echo "$nombre_sin_extension" | rev | cut -d' ' -f1 | rev)
            nuevo_nombre="${nombre_sin_extension% $codec}$codec"
            nuevo_nombre_completo=$(dirname "$file")/"$nuevo_nombre.$(echo "$file" | rev | cut -d'.' -f1 | rev)"
            
            # Renombra el archivo
            mv "$file" "$nuevo_nombre_completo"
            
            echo "File renamed to: $nuevo_nombre_completo"
        fi
    fi
done


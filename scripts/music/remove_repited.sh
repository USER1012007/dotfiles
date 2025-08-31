#!/bin/bash

if [ -z "$1" ]; then
    echo "Por favor, proporciona la ruta del directorio como argumento."
    exit 1
fi

directorio="$1"

archivos_duplicados=$(find "$directorio" -type f -exec md5sum {} + | sort | uniq -w32 -d | cut -d ' ' -f 3-)

IFS=$'\n'  
for archivo in $archivos_duplicados; do
    echo "Eliminando archivo duplicado: $archivo"
    rm "$archivo"
done
unset IFS  

echo "Proceso completado."


#!/bin/bash

# Verifica si se proporciona la ruta del directorio como argumento
if [ -z "$1" ]; then
    echo "Por favor, proporciona la ruta del directorio como argumento."
    exit 1
fi

# Directorio que contiene los archivos
directorio="$1"

# Obtener la lista de archivos duplicados
archivos_duplicados=$(find "$directorio" -type f -exec md5sum {} + | sort | uniq -w32 -d | cut -d ' ' -f 3-)

# Eliminar los archivos duplicados
IFS=$'\n'  # Configurar el separador de campos como salto de línea
for archivo in $archivos_duplicados; do
    echo "Eliminando archivo duplicado: $archivo"
    rm "$archivo"
done
unset IFS  # Restablecer el separador de campos

echo "Proceso completado."


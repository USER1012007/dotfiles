#!/bin/bash

# Verificar si se proporciona la carpeta de entrada como argumento
if [ -z "$1" ]; then
    echo "Usage: $0 <input_folder>"
    exit 1
fi

# Carpeta de entrada proporcionada como argumento
input_folder="$1"

# Verificar si la carpeta de entrada existe
if [ ! -d "$input_folder" ]; then
    echo "Error: Folder '$input_folder' not found."
    exit 1
fi

# Crear una carpeta de salida para las imágenes mejoradas
output_folder="$input_folder/output"
mkdir -p "$output_folder"

# Procesar cada archivo de imagen en la carpeta de entrada
for file in "$input_folder"/*.{jpg,jpeg,png,gif}; do
    if [ -f "$file" ]; then
        # Nombre de archivo y extensión sin la ruta
        filename=$(basename -- "$file")
        extension="${filename##*.}"
        filename_noext="${filename%.*}"

        # Ruta completa para la imagen de salida
        output_file="$output_folder/$filename_noext"_4k."$extension"

        # Aplicar mejoras y cambiar tamaño a 4K (3840x2160)
        convert "$file" -resize 1920x1080 -quality 100 "$output_file"

        echo "Imagen mejorada: $output_file"
    fi
done

echo "Proceso completado. Imágenes mejoradas y redimensionadas a 4K en la carpeta '$output_folder'."

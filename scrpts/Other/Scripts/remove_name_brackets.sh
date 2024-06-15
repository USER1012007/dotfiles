#!/bin/bash

# Carpeta de entrada proporcionada como argumento
input_folder="$1"
# Verificar si la carpeta de entrada existe
if [ ! -d "$input_folder" ]; then
     echo "Error: Folder '$input_folder' not found."
     exit 1
fi

cd "$input_folder"

for file in *'['*']'*; do
  if [ -f "$file" ]; then
	 nuevo_nombre=$(echo "$file" | sed 's/\[.*\]//')
  	 mv "$file" "$nuevo_nombre"
	 echo "Name changed: "$file" => "$nuevo_nombre""
  fi
done



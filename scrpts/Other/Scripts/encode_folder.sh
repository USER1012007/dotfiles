#!/bin/bash

# Carpeta de entrada proporcionada como argumento
input_folder="$1"

 # Verificar si la carpeta de entrada existe
 if [ ! -d "$input_folder" ]; then
     echo "Error: Folder '$input_folder' not found."
     exit 1
 fi


 # Procesar cada archivo de imagen en la carpeta de entrada
 for file in "$input_folder"/*.{mp3,wma,wav,flac}; do
    if [ -f "$file" ]; then
         # Nombre de archivo y extensión sin la ruta
         filename=$(basename -- "$file")
         extension="${filename##*.}"
         filename_noext="${filename%.*}"
  	
	 output_file1="${file%.*}.opus"

	 ffmpeg -i "$file" -map a:0 -c:a libopus -b:a 128k "$output_file1" #-map a:1 -c:a libopus -b:a 160k "$output_file2"

     fi
 done


         read -p "Do you want to remove old files? [Y/n]: " ans

         if [[ "$ans" == "y" || "$ans" == "Y" ]]; then

		for file in "$input_folder"/*.{mp3,wma,wav,flac}; do
		    if [[ -f "$file" ]]; then
		    	rm "$file"
			filename=$(basename -- "$file")
		    	echo -e "\e[32m=>\e[0m \e[33m"$filename"\e[0m has been deleted"
		    fi
		done
         fi
	  


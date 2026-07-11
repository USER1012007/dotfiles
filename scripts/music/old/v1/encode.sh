#!/bin/bash

input_file="$1"

# Define the output file names for the two audio tracks
output_file1="${input_file%.*}.opus"
output_file2="${input_file%.*}.opus"

# Use FFmpeg to extract the first two audio tracks and save them as Opus files
ffmpeg -i "$input_file" -map a:0 -c:a libopus -b:a 128k "$output_file1" #-map a:1 -c:a libopus -b:a 160k "$output_file2"

if [[ -e "$output_file1" ]]; then

	read -p "Do you want to remove $input_file? [Y/n]: " ans

	if [[ "$ans" == "y" || "$ans" == "Y" ]]; then

 		rm "$input_file"
 
	fi
fi

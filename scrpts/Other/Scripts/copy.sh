#!/bin/bash

source_folder="/home/emilio/Music/Other/Download"
destination_folder="/home/emilio/Music/Other/Download"

for file in "$source_folder"/*; do
    only_name="$(basename "$file")"
    file_without_extension="${only_name%.*}"  # Extract filename without extension
    kid3-cli -c "select \"$file\"" -c "copy 2" -c "select \"$destination_folder/$file_without_extension.opus\"" -c "paste 2" -c "save"
done

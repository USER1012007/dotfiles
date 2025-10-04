
# imagemagic

if [ -z "$1" ]; then
    echo "Usage: $0 <input_folder>"
    exit 1
fi


input_folder="$1"


if [ ! -d "$input_folder" ]; then
    echo "Error: Folder '$input_folder' not found."
    exit 1
fi


output_folder="$input_folder/output"
mkdir -p "$output_folder"


for file in "$input_folder"/*.{jpg,jpeg,png,gif}; do
    if [ -f "$file" ]; then
        
        filename=$(basename -- "$file")
        extension="${filename
        filename_noext="${filename%.*}"

        
        output_file="$output_folder/$filename_noext"_4k."$extension"

        
        convert "$file" -resize 1920x1080 -quality 100 "$output_file"

        echo "Imagen mejorada: $output_file"
    fi
done

echo "Proceso completado. Imágenes mejoradas y redimensionadas a 4K en la carpeta '$output_folder'."

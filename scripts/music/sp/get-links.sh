# get the metadata from the .json
# jq -r '.items[] | "\(.track.name)|\(.track.artists[0].name)|\(.track.album.name)|\(.track.album.images[0].url)"' lofi.json

if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

DIR="$1"
URL=""

if [ ! -d "$DIR" ]; then
    echo "'$DIR' no es un directorio válido."
    exit 1
fi

for file in "$DIR"/*.txt; do
    [[ -f "$file" ]] || continue  
    
    grep -oP '^[^|]+\|[^|]+' "$file" | sed 's/|/,/' | while IFS= read -r query; do
        [[ -z "$query" ]] && continue  
        
        URL=$(yt-dlp "ytsearch1:$query" --get-id 2>/dev/null)

        if [[ -n "$URL" ]]; then
            echo "https://www.youtube.com/watch?v=$URL"
        else
            echo "No se encontró resultado para: $query"
            echo $query > missing.txt
        fi
    done
done

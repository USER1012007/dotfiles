#!/bin/sh


user_input=$(zenity --entry --title="Text Input" --text="Enter text:")

if [ $? -eq 0 ]; then
	mkdir -p $HOME/Pictures/Screenshots/
	DESTINATION="$HOME/Pictures/Screenshots/"
	
	sleep 0.2s
	
	case $1 in
	
	    -s)
	        scrot --select "$DESTINATION$user_input.png"
	        ;;
	
	    -w)
	        scrot --focused --border "$DESTINATION$user_input.png"
	        ;;
	
	    *)
	        scrot "$DESTINATION$user_input.png"
	        ;;
	
	esac &&
	    {
	        SSNAME="$(ls -t $DESTINATION |head -n1)";
	        xclip -in -selection clipboard -target image/png "$DESTINATION$SSNAME"
	    } &&
	        notify-send "
	$(ls -t $HOME/Pictures/Screenshots/ |head -n1)
	Screenshot saved and copied to clipboard. " &&
	        echo "$(ls -t $HOME/Pictures/Screenshots/ |head -n1)
	Screenshot saved and copied to clipboard."
else
    echo "User canceled input."
fi

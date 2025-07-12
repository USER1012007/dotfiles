#!/bin/sh

if [ $? -eq 0 ]; then
	mkdir -p $HOME/Pictures/Screenshots/
	DESTINATION="$HOME/Pictures/Screenshots/"

	case $1 in

	-s)
		scrot --select "$DESTINATION/temp.png"
		;;

	-w)
		scrot --focused --border "$DESTINATION/temp.png"
		;;

	*)
		scrot "$DESTINATION/temp.png"
		;;

	esac &&
		{
			SSNAME="$(ls -t $DESTINATION | head -n1)"
			xclip -in -selection clipboard -target image/png "$DESTINATION/temp.png"
		} &&
		notify-send "
	Screenshot saved and copied to clipboard. "
	rm $DESTINATION/temp.png
else
	echo "User canceled input."
fi

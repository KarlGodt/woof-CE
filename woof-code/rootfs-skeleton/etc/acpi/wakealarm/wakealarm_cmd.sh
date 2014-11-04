#!/bin/ash

FILE=/root/TUBE/FlashC0mPIo.flv  #Jonny Cash Hurt

if test -f "$FILE"; then
 amixer set Master,0 100
 amixer set Mono,0 100
 amixer set PCM,0 100

 /usr/bin/mplayer -loop 0 "$FILE"
fi

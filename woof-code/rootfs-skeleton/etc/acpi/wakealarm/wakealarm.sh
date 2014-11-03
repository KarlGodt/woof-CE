#!/bin/ash


if test -f /root/TUBE/FlashC0mPIo.flv; then
 amixer set Master,0 100
 amixer set Mono,0 100
 amixer set PCM,0 100

 /usr/bin/mplayer -loop 0 /root/TUBE/FlashC0mPIo.flv
fi

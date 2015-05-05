#!/bin/bash

EXT=`echo "$@" |rev|cut -f1 -d'.'|rev`

case $EXT in
#here petget special
lapet|xzpet|lopet|b2pet)
exec /usr/local/petget/petget "$@"
;;

#here comes the additional handlers
sqfs|squashfs|mnx|rfs3)
filemnt "$@"
;;
*~)
file "$@" | grep -i 'text' && defaulttexteditor "$@"
;;
bz2|xz|lzma|lzo)
pupzip "$@"
;;
#here comes the additional handlers end
mht)
defaulthtmlviewer "$@"
;;
*)
xmessage -bg red "'$0' needs to be adjusted
to handle '$EXT'

You can alternatively right click
'$@'
and 'Set run action' in the sub-menu
of the filebrowser."
;;
esac

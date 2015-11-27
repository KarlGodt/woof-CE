#!/bin/ash

. /etc/rc.d/f4puppy5

#EXT=`echo "$@" |rev|cut -f1 -d'.'|rev`
 EXT="${@##*.}"
_debug "EXT=$EXT"

case $EXT in
#here petget special
b2pet|lapet|lopet|xzpet)
exec /usr/local/petget/petget "$@"
;;

#here comes the additional handlers
btr|btrfs|jfs|mnx|ofs|rfs|rfs3|rfs4|sqfs|squashfs|xfs)
filemnt "$@"
;;
*~)
file "$@" | grep $Q -i 'text' && defaulttexteditor "$@"
;;
bz2|lz|lzm|lzma|lzo|xz|Z)
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

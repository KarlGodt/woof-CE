#!/bin/bash

usage(){
	echo "
	$0 filename

	converts file.lss to filename.xpm

	copies new xpm to /boot/grub directory
	creates new entry in /boot/grub/menu.lst

	___message calling this usage function___
	$1
	"
	exit $2
}

# see /usr/include/asm/signal.h
[ ! "$1" ] && usage "Needs at lest one argument" 138
[ "`echo $1 | grep '^\-'`" ] && usage "No -[-]options implemented yet" 139
[ "$2" ] && usage "Only one argument allowed" 140

file="$1"
[ ! -e "$file" ] && usage "$file does not exist" 141
[ ! -f "$file" ] && usage "$file is not a regular file" 142
if [ ! "` grep 'LSS16 image data' "$file"`" ];then
usage "$file seems not to be a lss16 mime type" 143;fi

tempdir=/tmp/lss2xpm
mkdir -p $tempdir
cp "$file" "$tempdir"
fileb=`basename "$file"`

[ ! -e "$tempdir/$fileb" ] && usage "Cant work in $tempdir/ somehow" 144

lss16toppm <"$tempdir/$fileb" >"$tempdir/$fileb".ppm
[ "$?" != '0' ] && usage "Something went wrong comverting to .ppm" $?

[ ! -e "$tempdir/$fileb.ppm" ] && usage "Could not create $tempdir/$fileb.ppm" 146
if [ ! "` grep 'Netpbm PPM' "$tempdir/$fileb.ppm"`" ];then
usage "$file seems not to be a ppm mime type" 147;fi

ppmtoxpm  "$tempdir/$fileb.ppm" > "$tempdir/$fileb".xpm
[ "$?" != '0' ] && usage "Something went wrong comverting to .xpm" $?

[ ! -e "$tempdir/$fileb.xpm" ] && usage "Could not create $tempdir/$fileb.xpm" 148
if [ ! "` grep 'X pixmap image' "$tempdir/$fileb.xpm"`" ];then
usage "$file seems not to be a xpm mime type" 149;fi

if [ -d /boot/grub ];then
cp "$tempdir/$fileb.xpm" /boot/grub
if [ -f /boot/grub/menu.lst ];then
  if [ "`grep '^splashimage' /boot/grub/menu.lst`" ];then
  sed -i "s#^splashimage.*#splashimage $tempdir/$fileb.xpm#" /boot/grub/menu.lst
  fi
sed -i "10i\splashimage $tempdir/$fileb.xpm" /boot/grub/menu.lst
sed -i "10i\#entry created by $0" /boot/grub/menu.lst
sed -i "10i\     " /boot/grub/menu.lst
sed -i '/^$/d' /boot/grub/menu.lst
defaulttexteditor /boot/grub/menu.lst &
fi;fi
exit "$?"


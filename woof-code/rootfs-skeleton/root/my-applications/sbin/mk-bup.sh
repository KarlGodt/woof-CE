#!/bin/bash

usage (){
	echo "
	$0 FILE_TO_BACKUP

	Checks for the latest modification time
	and creates a {FILE_TO_BACKUP}-{MOD_TIME}
	"
	exit $1
}

#bash-3.00# stat -c %y grub.log
#2012-01-26 23:14:49.000000000 -0100

[ "$1" = '--help' ] && usage 0
[ "$1" = '-h' ] && usage 0
[ "$1" ] || usage 1

NAME="$1"
[ -e "$NAME" ] || { echo "'$NAME' does not exist ";usage 1; }
MOD_TIME=`stat -c %y "$NAME" | awk '{print $1}'`
DIR="${NAME%/*}"
rox "$DIR"
cp -ai --backup=numbered "${NAME}" "${NAME}-${MOD_TIME}"
chmod --preserve-root -R -v a-wx "${NAME}-${MOD_TIME}"

#new_base="${NAME{-$MOD_TIME}##*/}"
new_base="`basename "${NAME}-${MOD_TIME}"`"
echo $new_base
#new_dir="${NAME{-$MOD_TIME}%/*}"
new_dir="`dirname "${NAME}-${MOD_TIME}"`"
echo $new_dir

#tar --directory="$new_dir" -cjf "${new_base}.tar.bz2" "${NAME}-${MOD_TIME}"
tar -cjf "$new_dir"/"${new_base}.tar.bz2" "${NAME}-${MOD_TIME}"
exit $?

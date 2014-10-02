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
MOD_TIME=`stat -c %y "$NAME" | awk '{print $1}'`
DIR="${NAME%/*}"
rox "$DIR"
cp -ai --backup=numbered "${NAME}" "${NAME}-${MOD_TIME}"
chmod --preserve-root -R -v a-wx "${NAME}-${MOD_TIME}"

exit $?

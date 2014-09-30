#!/bin/sh

[ "$1" ] || { echo "$0: Need directory as 1. argument.";exit 4; }
[ -d "$1" ] || { echo "$0: '$1' is not a directory.";exit 5; }

[ "$2" ] || { echo "$0: Need directory as 2. argument.";exit 6; }
[ -d "$2" ] || { echo "$0: '$2' is not a directory.";exit 7; }

for entry in $1/*;do

entr="${entry##*/}"

[ -e "$2"/"$entr" ] && { echo "$entr" >> already.lst;continue; }

cp -ia "$entry" "$2"/

done

[ -s already.lst ] && geany already.lst

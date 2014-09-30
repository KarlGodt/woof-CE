#!/bin/bash

usage(){
	echo "
	$0 filename device

	get file stats using debugfs and stat commands
	useful to get crtime from ext4 filesystem

	$1
	"
	exit "$2"
}

[ "$3" ] && usage "Only two arguments allowed" 140
[ ! "$1" ] && usage "Need filename" 141

file="$1"
device=`echo "$2" |sed 's#/dev/##g'`

debugfs -R "stat $file" /dev/$device

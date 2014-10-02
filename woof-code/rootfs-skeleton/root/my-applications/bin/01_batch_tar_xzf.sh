#!/bin/bash

#
#
#

#
#
#

usage(){
	echo "$0 [.ext1[.ext2]]

	defaults to '.tar.gz'

	extracts all files.ext in current dir
	"
	exit "$?"
}

if [ "$1" ];then
PAT="$1"
else
PAT='.tar.gz'
gPAT='\.tar\.gz$'
fi

files=`find . -maxdepth 1 -type f -name "*$PAT"`
if [ ! "$files" ];then
if [ -e *.tar.bz2 ];then
exec $0 '.tar.bz2'
else
usage
fi
fi

case $PAT in
.tar.gz)execcommand='tar' ; arg='xzf';;
.tar.bz2)execcommand='tar' ; arg='xjf';;
esac

for i in $files;do

$execcommand $arg $i

done

mkdir -p ARCHIVE.D
for i in $files;do
mv $i ARCHIVE.D/`basename $i`
done


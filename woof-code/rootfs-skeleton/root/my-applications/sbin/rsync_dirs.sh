#!/bin/bash

usage(){
	echo "
	$0 [Source directory] [target directory]
	Without first or second argument, asks for directory to
	1. rsync from
	2. rsync to .
	"
	exit 0
}

case $1 in
-h|--help)usage;;
esac

DIR=''
[ "$1" ] && DIR=$1
if [ ! "$DIR" ];then
read -p "Enter Dir to rsync ('/' for all) : " DIR
fi
if [ ! "$DIR" ];then
echo "Need Source dir to rsync"
exit 1
fi
if [ ! -d "$DIR" ];then
echo "'$DIR' does not exist"
exit 1
fi

DESTDIR=''
[ "$2" ] && DESTDIR=$2
if [ ! "$DESTDIR" ];then
read -p "Enter Destination DIR : " DESTDIR
fi
if [ ! "$DESTDIR" ];then
echo "Need Targetdir dir to rsync"
exit 1
fi
if [ ! -d "$DESTDIR" ];then
echo "'$DESTDIR' does not exist"
exit 1
fi

. /etc/DISTRO_SPECS
DISTROFOLDER=`echo "$DISTRO_NAME" "$DISTRO_VERSION" | tr ' ' '_'`

NAME_DEV_FUNC(){

DEVNAME=`rdev | cut -f 1 -d ' ' | cut -f 3 -d '/' | cut -b 1-3`
}



if [ "$DIR" = "/" ] ; then

SR=`find / -maxdepth 1 -type d -o -type f -o -type l | sort`
SR=`echo "$SR" | grep -v -x -E '/|/mnt.*|/sys|/proc'`
sleep 10s
for i in $SR ; do
echo
echo -e "Rsyncing \e[35m$i\e[39m ... "
date
rsync -urlR --devices --progress --delete "$i" "$DESTDIR"
sleep 1s
echo
date
echo -e "\e[32m ... done \e[39m"
done
sleep 4s

else
rsync -urlR --devices --progress --delete "$DIR" "$DESTDIR"
fi


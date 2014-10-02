#!/bin/bash

##
#
##

rm -f bkscripts.lst

#cmt='#|[[:blank:]]*#'
cmt='[#[:blank:]]*'
DIRs='/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/X11R7/bin /usr/local/petget /etc/init.d /etc/rc.d'

for dir in $DIRs ; do
echo "greping in $dir/*"
#grep -I -m1 -Ei 'Barry | Kauler|BK|B\.K\.' $dir/*
grep -I -m1 -E -i -e "${cmt}Barry |${cmt} Kauler|${cmt}BK|${cmt}B\\.K\\." $dir/* >> bkscripts.lst
done

defaulttexteditor bkscripts.lst

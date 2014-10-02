#!/bin/bash

#
#
#

#
#
#

IA=''
[ "$1" ] && IA=YES

ALLDIRES=`ls -1F |grep '/$' | grep -vE 'NLS|DOC|DEV|\-i[0-9]../$'`

COMDIRES=`ls -1F |grep '\-i[0-9]../$' |grep -vE 'NLS|DOC|DEV'`

for i in $COMDIRES;do
echo "$i :"
MAINDIR=`echo "$i" | sed 's%-i[0-9][0-9][0-9]/$%%'`
echo "$MAINDIR :"
if [ -d "$MAINDIR" ];then

if [ "$IA" ];then
read -p "remove ?" k
if [ "$k" = 'y' ];then
rm -rf $MAINDIR
fi
else
rm -rf $MAINDIR
fi

fi
sleep 2s
done



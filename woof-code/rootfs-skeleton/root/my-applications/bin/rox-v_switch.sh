#!/bin/sh
#

currDir=`pwd`
if [ "$currDir" != '/usr/local/apps/ROX-Filer' ] ; then
cd /usr/local/apps/ROX-Filer
currDir=`pwd`
else
cd "$currDir"
fi
echo 'debug 0: '"$currDir"

if [ -e ROX-Filer ] ; then

if [ ! -L ROX-Filer ] ; then
echo -e "\e[0;31m"'WARNING: ROX-Filer is not a link [ -L ]'"\e[0;39m";fi
if [ ! -h ROX-Filer ] ; then
echo -e "\e[0;31m"'WARNING: ROX-Filer is not a link [ -h ]'"\e[0;39m";fi

else
echo -e "\e[0;31m"'WARNING: ROX-Filer does not exist in '"'$currDir'""\e[0;39m"
fi

RLRF=`readlink -e ROX-Filer`
echo 'debug 1:' "$RLRF"

if [ -n "$RLRF" ] ; then
bnameRF=`basename "$RLRF"`
echo 'debug 2:' $bnameRF
echo -e "\e[0;34m"'ROX-Filer is currently linked to '"$bnameRF""\e[0;39m"
#if [ -L ROX-Filer ] || [ -h ROX-Filer ] ; then
#rm ROX-Filer
#fi
fi

RF=`find . -maxdepth 1 -type f -iname "ROX-Filer*" | sort -g`
echo -e 'debug 3:' "\n""$RF"

if [ -z "$RF" ] ; then
echo -e "\e[1;31m"'ERROR : Apparently no ROX-Filer executables found in:'"`pwd`""\e[0;39m"
exit
fi

echo
count=0 ; rm -f /tmp/Roxfiler_switch.lst
for bin in $RF ; do
count=$((count+1))
echo -e " $count""\t""$bin"
echo "$count"':'"$bin" >>/tmp/Roxfiler_switch.lst
done
echo -n "choose NR of Which ROX-Filer to use : "
read number
echo
number=`echo "$number" | sed 's/[^0-9]//g'`

if [ -z "$number" ] ; then
echo -e "\e[1;31m"'ERROR: Chosen number was empty'"\e[0;39m"
exit
fi

if [ "$number" -lt 1 -o "$number" -gt "$count" ] ; then
echo -e "\e[1;31m"'ERROR: Chosen number not a valid number'"\e[0;39m"
exit
fi

RFTU=`grep -w "^$number" /tmp/Roxfiler_switch.lst | cut -f 2 -d ':'`
echo 'debug 4:' "$RFTU"
bnameRFTU=`basename "$RFTU"`
echo 'debug 5:' "$bnameRFTU"
ln -sfi "$bnameRFTU" ROX-Filer
linkRV=$?
if [ "$linkRV" -eq 0 ] ; then
echo 'debug 6:' "`readlink -e ./ROX-Filer`"
RLRF=`readlink -e ./ROX-Filer`
if [ -n "$RLRF" ] ; then
echo -e "\e[0;32m"'Linked ROX-Filer to '"$bnameRFTU"' in directory:'"`pwd`""\e[0;39m"
echo 'debug 7:' "`ls -lsF "$bnameRFTU"`"
else
echo -e "\e[0;31m"'ERROR : could not link ROX-Filer correctly to '"$bnameRFTU"' in directory:'"`pwd`""\e[0;39m"
fi
else
echo -e "\e[0;31m"'ERROR : The command ln -s '"$bnameRFTU"' "ROX-Filer" returned:'"$linkRV""\e[0;39m"
fi



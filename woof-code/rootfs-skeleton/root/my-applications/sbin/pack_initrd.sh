#!/bin/sh
###
##
###


programName='pack_initrd_gz'


usage(){
echo "$0
Pack INITRD folder in current directory {`pwd`)

$1

"
exit
}

cd `pwd`

f=`ls -1`  ##+2011_10_26 added -1

iNITRD=`echo "$f" |grep -w 'INITRD'`  ##+2011_10_26 added doublequotes around $f

if [ -z "$iNITRD" ] ; then 
cd ..
f=`ls -1`  ##+2011_10_26 added -1
iNITRD=`echo "$f" |grep -w 'INITRD'` ##+2011_10_26 added doublequotes around $f 
[ -z "$iNITRD" ] && usage "no INITRD directory found in `pwd`"
[ ! -d ./INITRD ] && usage "no INITRD directory found in `pwd`"
cd ./INITRD
fi

if [ -r ./DISTRO_SPECS ] ; then  ##+2011_10_26  added test
. ./DISTRO_SPECS  ##+2011_10_26  changed /etc/ to ./
else  ##+2011_10_26  added test else error msg
echo "ERROR : No DISTRO_SPECS file inside"
exit 9
fi  ##+2011_10_26  added test

find . | cpio -o -H newc >../initrd.${DISTRO_NAME// /}${DISTRO_VERSION// /}

cd ..

gzip -9 ./ initrd.${DISTRO_NAME// /}${DISTRO_VERSION// /}







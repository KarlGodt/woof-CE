#!/bin/sh
###
##
###


programName='edit_initrd_gz'

usage(){
echo "$0
open and extract initrd.gz in pwd {`pwd`)

$1

"
exit
}


cd `pwd`

f=`ls`

iNITRD=`echo $f |grep 'initrd.gz'`

[ -z "$iNITRD" ] && usage "file not found"

[ -e ./INITRD ] && usage "an INITRD file or directory already exist here"

cp ./initrd.gz ./initrd.`date| tr ' ' '-'`.backup.gz

mkdir ./INITRD

cd ./INITRD

zcat ../initrd.gz |cpio -i -d ##> ./INITRD

defaulttexteditor ./init &

#[ -s ./INITRD ] && rm ./INITRD

rox . 

xmessage "Directory now opened . Replace files as needed (kernelmodules , binaries etc)" &

exit












 
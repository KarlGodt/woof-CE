#!/bin/bash
#
#
#

#
#
#

CUSTOM='panic=30 log_buf_len=256k printk.time=1'
mkdir -p /boot/grub

usage(){
echo "$0 [ !b/path/to/boot/folder ]
Purpose is to find any kernels in !b/bootdirectory ,
and make entrys for them in !b/bootdirectory/grub/menu.lst .
If no !b/dir is given as argument on the commandline defaulting
to /boot . !b parameter especially interesting for switching into
mounted bootpartitions -ie /mnt/hda1/boot .
"
return 0 || exit 0 || exit 1
}  



PARAMS="$@"
ROOTPPART=`rdev |cut -f 1 -d ' '`
if [ ! "$ROOTPART" ];then
echo "Enter the rootdrive ie '/dev/sda1' :
"
read ROOTPART
fi

PARTNUMBER=`echo $ROOTPART | grep -o -e '[0-9]*$'`
echo ROOTPART$ROOTPART PARTNUMBER$PARTNUMBER
GRUBPART=$((PARTNUMBER-1))
echo GRUBPART$GRUBPART
PARTCHAR=`echo $ROOTPART | sed 's#[0-9]##g' | rev | cut -c 1 |rev`
echo PARTCHAR$PARTCHAR
case $PARTCHAR in
a)GRUBDRIVE=0;;
b)GRUBDRIVE=1;;
c)GRUBDRIVE=2;;
d)GRUBDRIVE=3;;
e)GRUBDRIVE=4;;
f)GRUBDRIVE=5;;
g)GRUBDRIVE=6;;
h)GRUBDRIVE=7;;
i)GRUBDRIVE=8;;
esac
echo $GRUBDRIVE



 
[ ! "$PARAMS" ] && PARAMS="!b/boot" # !l/lib"
[ "`pwd |grep '/boot$'`" ] && PARAMS="!b`pwd`"

for p in $PARAMS;do
echo $p
case $p in 
\!b/*)
echo $p
DIR=`echo "$p" |sed 's#^!b##'`
echo $DIR
cd $DIR
echo PWD=`pwd`
kernels=`find -maxdepth 1 -iname "vmlinuz*"`
echo $kernels
for kernel in $kernels ; do
kernela=${kernel%\./*} ##empty
echo $kernela
kernelb=${kernel%%\./*}
echo $kernelb ##empty
kernelc=${kernel%*\./} ##empty
echo $kernelc
kerneld=${kernel##*\./}
echo $kerneld ##empty



#list_func(){
kernel_grep=`echo "$kernel" | sed 's#\([[:punct:]]\)#\\\\\1#g'`
echo $kernel_grep
if [ ! "`grep "$kernel_grep" ./grub/menu.lst`" ];then


cat >>./grub/menu.lst << EOT
title kernel $kerneld on $ROOTPART
root (hd$GRUBDRIVE,$GRUBPART)
kernel /boot/$kerneld root=$ROOTPART ro vga=normal $CUSTOM

EOT


fi
#}

done
;;

\!h|*)
echo $p
usage;exit 0
;;
esac
done

[ ! "$RTVAL" ] && RTVAL=0
case $RTVAL in
0)
echo "$0 run OK"
exit 0
;;
*)
echo "$0 returns with $RTVAL"
exit $RTVAL
;;
esac

#!/bin/sh
##
###
##
#
#Wed Oct 19 16:04:55 GMT+1 2011
#
################################

########################################################################
#
#
#
#
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='Lucid·Puppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# Linux·puppypc·2.6.31.14·#1·Mon·Jan·24·21:03:21·GMT-8·2011·i686·GNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=Tue·Oct·25·12:32:47·GMT+1·2011
#
#
#
#
#
########################################################################


help_func(){
echo "USAGE: $0 /path/to/filename.ext

$1
"
exit 9
}

fileName="$1"
[ -z "$1" ] && help_func "No filename given"
[ -d "$1" ] && help_func "$1 is a directory"
[ ! -f "$1" ] && help_func "File $1 does not exist .. TYPO ?"
[ ! -r "$1" ] && help_func "File $1 is not readable"


filterSpace(){
sed 's/^[[:blank:]]*//g;s/[[:blank:]]*$//g'
}

rootDev=`rdev | filterSpace | cut -f 1 -d ' '`
[ -n "$rootDev" ] && blockID=`blkid $rootDev`
language='$LANG='"`echo $LANG`"
time='today='"`date | tr ' ' '·'`"
distroSpecs=`cat /etc/DISTRO_SPECS  | grep -v -E -e '^#|^[[:blank:]]*#' | filterSpace | tr ' ' '·'`
pupState=`cat /etc/rc.d/PUPSTATE | grep -v -E -e '^#|^[[:blank:]]*#' | filterSpace | tr ' ' '·'`
kernel=`uname -a | tr ' ' '·'`
xServer="Xserver=`readlink -e $(which X)`"

debug(){
p1="$1"
if [ -z "`echo $p1 | grep -w -e '[[:digit:]]*'`" ] ; then
p1='-'; fi
shift
echo "$0 line: $p1 $@"
}

old_func(){
echo '##########################################################################'
echo '#' "$distroSpecs"
echo '#' "$pupState"
echo '#' "$kernel"
echo '#' "$xServer"
echo '#' "$time"
echo '#' "$language"
echo '##########################################################################'
}

exec 1>/tmp/`basename $0`.txt
echo
for n in `seq 1 72` ; do
echo -n '#'
done
echo
for n in `seq 1 5` ; do
echo '#'
done

cont_func(){
for cont in $@ ; do
echo '#' $cont
done
}
cont_func "$rootDev"
cont_func "$blockID"
cont_func "$distroSpecs"
cont_func "$pupState"
cont_func "$kernel"
cont_func "$xServer"
cont_func "$language"
cont_func "$time"

for n in `seq 1 5` ; do
echo '#'
done
for n in `seq 1 72` ; do
echo -n '#'
done
echo
echo
#echo ##workaround needs this
exec 1>&0
echo hallo

insertLineNumber9=`grep -m1 -n '^[[:alnum:]]' "$fileName" | cut -f 1 -d ':'`
insertLineNumber1=$((insertLineNumber9-1))
[ -z "$insertLineNumber1" -o "$insertLineNumber1" -lt 3 ] && insertLineNumber1=3
insertLineNumber8=`wc -l /tmp/$(basename $0).txt | cut -f 1 -d ' '`
insertLineNumber2=$((insertLineNumber1+insertLineNumber8)) 

echo insertLineNumber1=$insertLineNumber1
echo insertLineNumber2=$insertLineNumber2

#sedPattern=`cat /tmp/$(basename $0).txt`
#echo "$sedPattern"

sed_func(){
cp "$fileName" "$fileName".backup.$$
chmod 0444 "$fileName".backup.$$

sedPattern=`cat /tmp/$(basename $0).txt`
echo "$sedPattern"
#sed -i "$insertLineNumber1,$insertLineNumber2 a\ $sedPattern" "$fileName" ##only one line

count=$insertLineNumber1
for number in `seq 1 $insertLineNumber8`; do
sedPattern=`sed -n "$number p" /tmp/$(basename $0).txt`
echo sedPattern=$sedPattern
sed -i "$count i\ $sedPattern" "$fileName"
sed -i "$count s/^[[:blank:]]*//" "$fileName"
count=$((count+1))
done

}
sed_func


work_around(){
head -n $insertLineNumber "$fileName" > /tmp/`basename "$fileName"`.tmp
cat /tmp/$(basename $0).txt >> /tmp/`basename "$fileName"`.tmp

if [ -n "`tail -n1 "$fileName" | grep -E '^[[:alnum:]]|^[[:punct:]]'`" ] ; then
echo >> "$fileName" ; fi

totalNumber=`wc -l "$fileName" | cut -f 1 -d ' '`
tailNumber=$((totalNumber-insertLineNumber))
tail -n $tailNumber "$fileName" >> /tmp/`basename "$fileName"`.tmp

cp "$fileName" "$fileName".backup.$$
cp -f /tmp/`basename "$fileName"`.tmp "$fileName"
###end work around
}
#work_around


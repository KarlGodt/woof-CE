#!/bin/bash
####
#####Thu Oct 13 09:38:16 GMT-8 2011
###

########################################################################
#
#
#
#
#
# DISTRO_NAME='Wary·Puppy'
# DISTRO_VERSION=098
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='puppy'
# DISTRO_FILE_PREFIX='wary'
# DISTRO_COMPAT_VERSION='wary5'
# DISTRO_KERNEL_PET='linux_kernel-2.6.31.14-2-w5.pet'
# DISTRO_IDSTRING='w098101114074008'
# DISTRO_PUPPYSFS='wary_098.sfs'
# DISTRO_ZDRVSFS='zw098114.sfs'
# PUPMODE=12
# PDEV1='sda7'
# DEV1FS='ext4'
# PUPSFS='sda7,ext4,/wary098/wary_098.sfs'
# PUPSAVE='sda7,ext4,/wary098/warysave-098F.3fs'
# PMEDIA='atahd'
# ATADRIVES='sda·'
# SAVE_LAYER='/pup_rw'
# PUP_LAYER='/pup_ro2'
# PUP_HOME='/mnt/dev_save'
# ZDRV='sda7,ext4,/wary098/zw098114.sfs'
# ZDRVINIT='no'
# PSAVEMARK=''
# Linux·puppypc·2.6.31.14·#1·SMP·Mon·Oct·25·23:28:59·GMT-8·2010·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xorg
# $LANG=en_US
# today=Mon·Oct·24·18:43:51·GMT-1·2011
#
#
#
#
#
########################################################################


########################################################################
#
#
#
#
#
# /dev/sda10:
# LABEL="/"
# UUID="1b68d71e-9a29-4d83-8dbd-01f71248e7a1"
# TYPE="ext3"
# DISTRO_NAME='Lighthouse·Pup'
# DISTRO_VERSION=443
# DISTRO_BINARY_COMPAT='slackware'
# DISTRO_FILE_PREFIX='spup'
# DISTRO_COMPAT_VERSION='13.0'
# PUPMODE=2
# ATADRIVES='sda·'
# PUP_HOME='/'
# Linux·Mariner·2.6.30.5·#1·SMP·Tue·Sep·1·15:48:26·GMT-8·2009·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xorg
# $LANG=de_DE@euro
# today=Sa·22.·Okt·11:44:56·UTC·2011
#
# TODO 1:
#bash-3.00# al2rl.sh 
#currentDir=/root/.wine/drive_c
#10
#11
#/proc /dev/pts /sys /dev/shm /proc/bus/usb /mnt/sda1 /mnt/sda3 /mnt/sda4 /mnt/sda5 /mnt/sda6 /mnt/sda7 /mnt/sda8 /mnt/sda9 /mnt/sda10 /mnt/sda11 /mnt/sda12 /mnt/+JUMP-10+spup-443.sfs
#/proc
#grepPattern=//proc
#/dev/pts
#grepPattern=//dev//pts
#/sys
#grepPattern=//sys
#/dev/shm
#grepPattern=//dev//shm
#/proc/bus/usb
#grepPattern=//proc//bus//usb
#/mnt/sda1
#grepPattern=//mnt//sda1
#/mnt/sda3
#grepPattern=//mnt//sda3
#/mnt/sda4
#grepPattern=//mnt//sda4
#/mnt/sda5
#grepPattern=//mnt//sda5
#/mnt/sda6
#grepPattern=//mnt//sda6
#/mnt/sda7
#grepPattern=//mnt//sda7
#/mnt/sda8
#grepPattern=//mnt//sda8
#/mnt/sda9
#grepPattern=//mnt//sda9
#/mnt/sda10
#grepPattern=//mnt//sda10
#/mnt/sda11
#grepPattern=//mnt//sda11
#/mnt/sda12
#grepPattern=//mnt//sda12
#/mnt/+JUMP-10+spup-443.sfs
#grepPattern=//mnt//+JUMP-10+spup-443.sfs
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Color: No such file or directory
#ls: cannot access Setter: No such file or directory
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Configuration: No such file or directory
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Font: No such file or directory
#ls: cannot access Smoothing: No such file or directory
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access regedit: No such file or directory
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Task: No such file or directory
#ls: cannot access Manager: No such file or directory
#/root/.wine/drive_c
#/root/.wine/drive_c
#/usr/share/applications/winetricks.desktop
#lrwxrwxrwx 1 root root 42 2010-09-10 17:01 ./Winetricks -> /usr/share/applications/winetricks.desktop
#not a relative link
#realPathLinkToRm=/root/.wine/drive_c/Winetricks
#dirNameLinkToRm=/root/.wine/drive_c
#dirNameLinkTarget=/usr/share/applications
#pattern1=root .wine drive_c
#pattern2=usr share applications
#pattern11=c_evird eniw. toor
#pattern22=snoitacilppa erahs rsu
#pattern111=drive_c .wine root
#pattern222=applications share usr
#/root/.wine /usr/share
#count1=2
#wcWordsPattern2222=3
#pattern2222=applications share usr
#count2=2
#wcWordsPattern1111=3
#pattern1111=drive_c .wine root
#pattern2222 turn ...
#applications
#wayBack=1
#share
#wayBack=2
#usr
#wayBack=3
#pathWayBack=../
#relativePath=/usr/share/applications
#1 1 /usr/share/applications
#relativePathField=applications
#relativePathField not empty
#relativePathField=applications
#relativePath=../usr/share/applications
#WARNING: ../usr/share/applications/winetricks.desktop does not exists
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Uninstaller: No such file or directory
#ls: cannot access ./Wine: No such file or directory
#ls: cannot access Wordpad: No such file or directory
#<root> ~/.wine/drive_c
#bash-3.00# 
# TODO1 : grep pattern~fixed 2011_11_22 ; [ sed pattern ]
# TODO2 : files with spaces~fixed 20_10_22 by doubble-quoting nearly(?) all flie-string-vars
# TODO3 : tr -s '/' fixed(?) 2011_11_22
# TODO4 : wayback in first pattern1111 turn did not work properly fixed(?) 2011_11_22
#
########################################################################


########################################################################
#
# Written by Karl Reimer Godt
# autumn 1969+42
#
#
# DISTRO_VERSION=430Â#481Â#416Â#218Â#478ÂÂÂÂÂÂ#####changeÂthisÂasÂrequired#####
# DISTRO_BINARY_COMPAT="puppy"Â#"ubuntu"Â#"puppy"Â#####changeÂthisÂasÂrequired#####
# caseÂ$DISTRO_BINARY_COMPATÂin
# ubuntu)
# DISTRO_NAME="JauntyÂPuppy"
# DISTRO_FILE_PREFIX="upup"
# DISTRO_COMPAT_VERSION="jaunty"
# ;;
# debian)
# DISTRO_NAME="LennyÂPuppy"
# DISTRO_FILE_PREFIX="dpup"
# DISTRO_COMPAT_VERSION="lenny"
# ;;
# slackware)
# DISTRO_NAME="SlackÂPuppy"
# DISTRO_FILE_PREFIX="spup"
# DISTRO_COMPAT_VERSION="12.2"
# ;;
# arch)
# DISTRO_NAME="ArchÂPuppy"
# DISTRO_FILE_PREFIX="apup"
# DISTRO_COMPAT_VERSION="200904"
# ;;
# t2)
# DISTRO_NAME="T2ÂPuppy"
# DISTRO_FILE_PREFIX="tpup"
# DISTRO_COMPAT_VERSION="puppy5"
# ;;
# puppy)Â#builtÂentirelyÂfromÂPuppyÂv2.xÂorÂv3.xÂorÂ4.xÂpetÂpkgs.
# DISTRO_NAME="Puppy"
# DISTRO_FILE_PREFIX="pup"Â#"ppa"Â#"ppa4"Â#"pup2"ÂÂ#pup4ÂÂ###CHANGEÂASÂREQUIRED,ÂrecommendÂlimitÂfourÂcharacters###
# DISTRO_COMPAT_VERSION="4"Â#"2"ÂÂ#4ÂÂÂÂÂ###CHANGEÂASÂREQUIRED,ÂrecommendÂsingleÂdigitÂ5,Â4,Â3,ÂorÂ2###
# ;;
# esac
# PUPMODE=2
# ATADRIVES='sdaÂ'
# PUP_HOME='/'
# LinuxÂpuppypcÂ2.6.30.5Â#1ÂSMPÂTueÂSepÂ1Â15:48:26ÂGMT-8Â2009Âi686ÂGNU/Linux
# Xserver=/usr/X11R7/bin/Xorg
# $LANG=en_US
# today=ThuÂOctÂ20Â11:28:03Â..Etc/GMTÂ2011
# TODO 1: finishing the parameterJunctionFunc
# TODO 2: failed to symlink /root/.etc -> /etc :: 'etc' no such file or directory [ missing trailing '/' ]~ fixed by addding currWorkingDir=$currentDir
# ##worked ok Thu Oct 20 10:28:08 GMT+1 2011 in /mnt/sda5/sbin [for example for some ntfs links] called without any parameters .
# TODO 3: simplyfying && coloration of the debug output
# TODO 4: give prog a better name like AbsLinksToRelLinks al2rl  ##fixed 2011_10_22
#
########################################################################

########################################################################
#
# here am i !!!!
#
#
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='LucidÂPuppy'
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
# LinuxÂpuppypcÂ2.6.31.14Â#1ÂMonÂJanÂ24Â21:03:21ÂGMT-8Â2011Âi686ÂGNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=TueÂOctÂ25Â16:52:42ÂGMT+1Â2011
#
# TODO1: 
#
# al2rl.sh 
#currentDir=/mnt/hda1/bin
#10
#11
#/proc /dev/pts /sys /dev/shm /nodev/binfmt_misc /nodev/ramfs /proc/bus/usb /mnt/hda9 /mnt/hda12 /mnt/+dpup008+dpupsave-SEC.3fs /mnt/hda4 /mnt/+JUMP-7+luci-218.sfs /mnt/hda1 /mnt/hda10
#/proc
#grepPattern=\/proc
#/dev/pts
#grepPattern=\/dev\/pts
#/sys
#grepPattern=\/sys
#/dev/shm
#grepPattern=\/dev\/shm
#/nodev/binfmt_misc
#grepPattern=\/nodev\/binfmt\_misc
#/nodev/ramfs
#grepPattern=\/nodev\/ramfs
#/proc/bus/usb
#grepPattern=\/proc\/bus\/usb
#/mnt/hda9
#grepPattern=\/mnt\/hda9
#/mnt/hda12
#grepPattern=\/mnt\/hda12
#/mnt/+dpup008+dpupsave-SEC.3fs
#grepPattern=\/mnt\/\+dpup008\+dpupsave\-SEC\.3fs
#/mnt/hda4
#grepPattern=\/mnt\/hda4
#/mnt/+JUMP-7+luci-218.sfs
#grepPattern=\/mnt\/\+JUMP\-7\+luci\-218\.sfs
#/mnt/hda1
#grepPattern=\/mnt\/hda1
#320
#21
#//mnt//hda1
#currWorkingDir=/bin
#234
#236
#./bzcmp
#./bzcmp
#./bzcmp
#./bzegrep
#./bzegrep
#./bzegrep
#./bzfgrep
#./bzfgrep
#./bzfgrep
#./bzless
#./bzless
#./bzless
#./mt
#./mt
#./mt
#/mnt/hda1/bin
#/bin
#/etc/alternatives/mt
#lrwxrwxrwx 1 root root 20 2010-09-16 04:33 ./mt -> /etc/alternatives/mt
#not a relative link
#realPathLinkToRm=/bin/mt
#dirNameLinkToRm=/bin
#dirNameLinkTarget=/etc/alternatives
#pattern1=bin
#pattern2=etc alternatives
#pattern11=nib
#pattern22=sevitanretla cte
#pattern111=bin
#pattern222=alternatives etc
#/ /etc
#count1=0
#wcWordsPattern2222=2
#pattern2222=alternatives etc
#count2=1
#wcWordsPattern1111=1
#pattern1111=fake_for_4665 bin
#content=fake_for_4665
#fake_for_4665 is not equal
#wc -w bin -gt etc alternatives
#wayBack=1
#content=bin
#bin is not equal
#wc -w bin -gt etc alternatives
#wayBack=2
#pathWayBack=../../
#relativePath=/etc/alternatives
#k2=1
#2 2 /etc/alternatives
#relativePathField=etc
#relativePathField not empty
#etc
#bin
#k2=2
#2 3 /etc/alternatives
#relativePathField=alternatives
#relativePathField not empty
#alternatives

#relativePath=../../etc/alternatives
#WARNING: ../../etc/alternatives/mt does not exists
#
# FIXED!!2011_10_25 by adding parts of code from else part , 
#        might be more to add and simplyfy 
#
#
#
########################################################################


parameterJunktion_func(){
for param in "$@" ; do
echo "$param"
case $param in
"-d * "|--dir=* ) : ;;
"-h * "|--help) : ;;
"-c * "|--check=* ) : ;;
"-r * "|--repair=* ) : ;;
*) : ;;
esac
done
}

if [ "$1" ] ; then
cd "$1"
else
cd `pwd`
fi

currentDir="`pwd`"
currWorkingDir="$currentDir"  ##2011_10_20 fixed:2
echo currentDir=$currentDir
echo 10
mountPoints=`busybox mount | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/^ *//g' | cut -f 3 -d ' ' | grep -v -w '/'`
echo 11
echo $mountPoints
for dir in $mountPoints ; do
echo $dir
#grepPattern=`echo $dir | sed 's/\\//\\/\\//g'`  ##+-+2011_10_21
grepPattern=`echo $dir | sed 's/\([[:punct:]]\)/\\\\\\1/g'`   ##+++2011_10_21
echo grepPattern=$grepPattern
if [ -n "`echo $currentDir | grep -w "$dir"`" ] ; then
echo 20
sedPattern=`echo $dir | sed 's/\\//\\/\\//g'`
echo 21
echo "$sedPattern"

currWorkingDir=`echo "$currentDir" | sed "s%$dir%%"`
echo currWorkingDir=$currWorkingDir
break
fi
done
#exit


#check_func(){  ##+-+2011_10_22

#links=`find . -maxdepth 1 -type l | sort -d`  ##+-+2011_10_22
echo 234
links=`find . -maxdepth 1 -type l | sort -d | tr '[:blank:]]' ' ' | sed 's/ /_SPACEfill_/g'`  ##+++2011_10_22
echo 236
for link1 in $links ; do
echo $link1
link="${link1//_SPACEfill_/ }"  ##+++2011_10_22
echo $link  ##+++2011_10_22
echo "$link"  ##+++2011_10_22

lsl=`ls -l "$link"`  ##+2011_10_22 doubblequoting $link1

linkTarget=`echo $lsl | rev | sed 's/^[[:blank:]]*//' | cut -f 1 -d ' ' | rev`

if [ -n "`echo $linkTarget | grep '/'`" ] ; then

echo "$linkTarget" | grep -o '^\.\./'

if [[ -n `echo "$linkTarget" | grep "^/"` ]] && [[ -z `echo "$linkTarget" | grep -o "^\\.\\./"` ]] ; then

echo $currentDir
echo $currWorkingDir
echo $linkTarget
echo -e "\e[0;36m""$lsl""\e[0;39m\n""not a relative link"

debug_func_100(){
realPath=`realpath $link`
echo realPath=$realPath
readLink=`readlink $link`
echo readLink=$readLink
readLinkm=`readlink -m $link`
echo readLinkm=$readLinkm
readLinkf=`readlink -f $link`
echo readLinkf=$readLinkf
readLinke=`readlink -e $link`
echo readLinke=$readLinke
}

baseNameLinkToRm=`basename "$link"`
realPathLinkToRm="${currWorkingDir}/${baseNameLinkToRm}"
echo realPathLinkToRm=$realPathLinkToRm

dirNameLinkToRm=`dirname "$realPathLinkToRm"`
dirNameLinkTarget=`dirname "$linkTarget"`
[ "$dirNameLinkTarget" == "." ] && dirNameLinkTarget="$dirNameLinkToRm"
baseNameLinkTarget=`basename "$linkTarget"`

echo dirNameLinkToRm=$dirNameLinkToRm
echo dirNameLinkTarget=$dirNameLinkTarget

#pattern1=${dirNameLink/\(\/\)/ /}
#pattern2=${dirNameLinkTarget/\// /}

pattern1=`echo "$dirNameLinkToRm" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`
pattern2=`echo "$dirNameLinkTarget" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern1=$pattern1
echo pattern2=$pattern2

pattern11=`echo "$pattern1" | rev`
pattern22=`echo "$pattern2" | rev`

echo pattern11=$pattern11
echo pattern22=$pattern22

for i in $pattern11 ; do
new=`echo "$i" | rev`
pattern111="$pattern111 $new"
done
pattern111=`echo "$pattern111" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`
 
for i in $pattern22 ; do
new=`echo "$i" | rev`
pattern222="$pattern222 $new"
done
pattern222=`echo "$pattern222" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern111=$pattern111
echo pattern222=$pattern222
pattern1111="$pattern111"
pattern2222="$pattern222"

echo -e "\e[1;33m"`dirname "$currWorkingDir"` `dirname "$dirNameLinkTarget"`"\e[0;39m" 

if [[ "$pattern111" == "$pattern222" ]] ; then
echo -e "\e[1;35m""same directory""\e[0;39m"
if [ -e "$baseNameLinkTarget" ] ; then
echo "rm $link .."
rm "$link"
echo -e "\e[0;32m""creating link $baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s "$baseNameLinkTarget" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[0;31m""$baseNameLinkTarget does not exists""\e[0;39m"
fi

elif [[ "`dirname $currWorkingDir`" == "`dirname $dirNameLinkTarget`" ]] ; then
echo -e "\e[1;35m""same upper directory""\e[0;39m"
sedpattern=`dirname "$dirNameLinkTarget" | sed 's#\/#\\\/#g'`
echo sedpattern=$sedpattern
shortPath=`echo "$linkTarget" | sed "s/$sedpattern//"`
echo shortPath=$shortPath
shortPath1="../$shortPath"  ##+2011_20_22
shortPath2=`echo "$shortPath1" | tr -s '/'`  ####+2011_20_22 added tr -s '/'
echo shortPath2=$shortPath2
if [ -e "$shortPath2" ] ; then
echo "rm $link .."
rm "$link"
echo -e "\e[0;32m""creating link $shortPath2 $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s "$shortPath2" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[0;31m""$shortPath2 does not exists""\e[0;39m"
fi

elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo -e "\e[1;35m""same dir""\e[0;39m"
shortPattern=`echo "$dirNameLinkTarget" | grep -o "^$dirNameLinkToRm"`
echo shortPattern=$shortPattern
shortPattern1=`echo "$shortPattern" | sed 's#\/#\\\/#g'`
echo shortPattern1=$shortPattern1
shortPattern2=`echo "$dirNameLinkTarget" | sed "s/^$shortPattern1//"`
echo shortPattern2=$shortPattern2
shortPattern3=`echo "$shortPattern2" | sed 's#^\/##'`
#baseNameLinkTarget2222=`basename $dirNameLinkTarget`
if [ -e $shortPattern3/$baseNameLinkTarget ] ; then
echo "removing $link"
rm "$link"
echo -e "\e[0;32m""creating  $shortPattern3/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s "$shortPattern3/$baseNameLinkTarget" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[0;31m""$shortPattern3/$baseNameLinkTarget does not exists""\e[0;39m"
fi

#elif [[ "`dirname $currWorkingDir`" == "`dirname $dirNameLinkTarget`" ]] ; then
#echo -e "\e[1;31m""same upper directory""\e[0;39m"
#echo "rm link .."
#rm $link
#echo "creating link ../$baseNameLinkTarget $dirNameLinkTarget/$baseNameLinkToRm"
#ln -s ../$baseNameLinkTarget $dirNameLinkTarget/$baseNameLinkToRm  ##typo solved :coun1=$((count+1))
else

count1=0
for j in $pattern1111 ; do
count1=$((count1+1))
done
count1=$((count1-1))
echo count1=$count1
wcWordsPattern2222=`echo $pattern2222 | wc -w`
echo wcWordsPattern2222=$wcWordsPattern2222

for j in `seq $count1 -1 $wcWordsPattern2222` ; do
pattern2222="fake_for_$$ $pattern2222"
done

echo pattern2222=$pattern2222

count2=0
for j in $pattern2222 ; do
count2=$((count2+1))
done
count2=$((count2-1))
echo count2=$count2
wcWordsPattern1111=`echo $pattern1111 | wc -w`
echo wcWordsPattern1111=$wcWordsPattern1111

for j in `seq $count2 -1 $wcWordsPattern1111` ; do
pattern1111="fake_for_$$ $pattern1111"
done

echo pattern1111=$pattern1111

if [[ -n "`echo $pattern1111 | grep "fake_for_$$"`" ]] ; then

func_1000(){ #169
count3=0; wayBack=0

for content in $pattern1111 ; do
count3=$((count3+1))
echo $pattern2222 | cut -f $count3 -d ' '
if [[ "$content" == "`echo $pattern2222 | cut -f $count3 -d ' '`" ]] ; then
#################!=
echo "$content is [not] equal"
if [[ "`echo $pattern2 | wc -w`" -gt "`echo $pattern1 | wc -w`" ]] ; then
echo "wc -w $pattern2 -gt $pattern1"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
else
echo "$content is not equal"
if [[ "`echo $pattern1 | wc -w`" -gt "`echo $pattern2 | wc -w`" ]] ; then
echo "wc -w $pattern1 -gt $pattern2"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
fi
done
} #func1000 157

count3=0; wayBack=0
for content in $pattern1111 ; do  ##pattern1
echo content=$content
count3=$((count3+1))

if [[ "$content" == "`echo $pattern2222 | cut -f $count3 -d ' '`" ]] ; then
#################!=
echo "$content is [not] equal"
if [[ "`echo $pattern2 | wc -w`" -gt "`echo $pattern1 | wc -w`" ]] ; then
echo "wc -w $pattern2 -gt $pattern1"
#wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
else
echo "$content is not equal"
if [[ "`echo $pattern2 | wc -w`" -gt "`echo $pattern1 | wc -w`" ]] ; then

echo "wc -w $pattern1 -gt $pattern2"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
fi
done
[ "$wayBack" == 0 ] && wayBack=1

#wayBack1=0;cdPattern="../"  ##+-+2011_10_22
wayBack1=0;cdPattern=""  ##+++2011_10_22
for i in `seq 1 $wayBack` ; do
wayBack1=$((wayBack1+1))
cdPattern="${cdPattern}../"
if [ "`cd $cdPattern && pwd`" = '/' ] ; then
break
fi
#wayBack1=$((wayBack1+1))
done

for k in `seq 1 $wayBack1` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath="$dirNameLinkTarget"
echo relativePath=$relativePath
count4=1
for k2 in `seq 1 $wayBack1` ; do  ##+2011_10_22 changed k to k2
echo k2=$k2  ##for k in $pathWayBacK "../../" == 1  ##+2011_10_22 changed k2 to k2=$k2
count4=$((count4+1))
echo $k2 $count4 "$dirNameLinkTarget"  ##+2011_10_25 changed k to k2
relativePathField=`echo "$dirNameLinkTarget" | cut -f $count4 -d '/'`
echo relativePathField="$relativePathField"

if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $dirNameLinkTarget | cut -f $count4 -d '/'`" != "`echo $dirNameLinkToRm | cut -f $count4 -d '/'`" ]] ; then
##########################################################!=
echo "$dirNameLinkTarget" | cut -f $count4 -d '/'
echo "$dirNameLinkToRm" | cut -f $count4 -d '/'

relativePath=`echo "$relativePath" | sed 's#^#\.\.\/#' | tr -s '/'`

##+++2011_10_25 added from 'else' part below
if [ -e "$relativePath/$baseNameLinkTarget" ] ; then  ##+++20_10_22
echo "$relativePath/$baseNameLinkTarget"' seems to exist'  ##+++20_10_22
break  ##+++20_10_22
fi  ##+++20_10_22
##+++2011_10_25 added from 'else' part below

else
echo 'else'
echo $dirNameLinkTarget | cut -f $count4 -d '/'
echo "$dirNameLinkTarget" | cut -f $count4 -d '/'
echo $dirNameLinkToRm | cut -f $count4 -d '/'
echo "$dirNameLinkToRm" | cut -f $count4 -d '/'

#relativePath=`echo "$relativePath" | sed "s/$relativePathField//"`  ##+-+20_10_22 commented
relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"`  ##+-+20_10_22 uncommented
echo relativePath=$relativePath
relativePath=`echo "$relativePath" | sed 's#^\/\.\.#\.\.#' | tr -s '/'`  ##+++20_10_22
echo relativePath=$relativePath  ##+++20_10_22
echo "$relativePath/$baseNameLinkTarget"  ##+++20_10_22
if [ -e "$relativePath/$baseNameLinkTarget" ] ; then  ##+++20_10_22
echo "$relativePath/$baseNameLinkTarget"' seems to exist'  ##+++20_10_22
break  ##+++20_10_22
fi  ##+++20_10_22
relativePath9=`echo $relativePath | sed 's/\.\.\///g;s/^/\.\.\//' | tr -s '/'`  ##+++20_10_22
if [ -e "$relativePath9/$baseNameLinkTarget" ] ; then  ##+++20_10_22
echo "$relativePath9/$baseNameLinkTarget"' seems to exist'  ##+++20_10_22
relativePath="$relativePath9"
break  ##+++20_10_22
fi  ##+++20_10_22
fi
else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done
relativePath=`echo "$relativePath" | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e "$relativePath/$baseNameLinkTarget" ] ; then
echo "removing $link"
rm "$link"
echo "creating link .."
echo -e "\e[1;32m""$relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"  ##+2011_10_22 added coloration
ln -s "$relativePath/$baseNameLinkTarget" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[1;31m""WARNING: $relativePath/$baseNameLinkTarget does not exists""\e[0;39m"
sleep 5s
fi 
#pathWayBack='';pathWayBack=''
#pattern1='';pattern11='';pattern111='';pattern1111=''
#pattern2='';pattern22='';pattern222='';pattern2222=''

ou_func(){
#elif [[ "`echo  "$pattern1" | wc -w`" == "`echo "$pattern2" | wc -w`" ]] ; then
echo -e "\e[1;35m""same above sub dir""\e[0;39m"
baseNameLinkTarget2222=`basename $dirNameLinkTarget`
if [ -e ../$baseNameLinkTarget2222/$baseNameLinkTarget ] ; then
echo "removing $link"
rm "$link"
echo -e "\e[0;32m""creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"  ##+2011_10_22 added coloration
ln -s ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[0;31m""../$baseNameLinkTarget2222/$baseNameLinkTarget does not exists""\e[0;39m"
fi
} 
elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo -e "\e[1;35m""same sub dir""\e[0;39m"
baseNameLinkTarget2222=`basename "$dirNameLinkTarget"`
if [ -e "$baseNameLinkTarget2222/$baseNameLinkTarget" ] ; then
echo "removing $link"
rm "$link"
echo -e "\e[0;32m""creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"  ##+2011_10_22 added coloration
ln -s "$baseNameLinkTarget2222/$baseNameLinkTarget" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[0;31m""$baseNameLinkTarget2222/$baseNameLinkTargetdoes not exists""\e[0;39m" 
fi

else
echo "pattern2222 turn ..."

count3=0; wayBack=0
for content in $pattern2222 ; do
echo $content
count3=$((count3+1))
if [[ "$content" != "`echo $pattern1111 | cut -f $count3 -d ' '`" ]] ; then
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
done
[ "$wayBack" == 0 ] && wayBack=1

#wayBack1=0;cdPattern="../"  ##+-+2011_10_22
wayBack1=0;cdPattern=""  ##+++2011_10_22
for i in `seq 1 $wayBack` ; do
echo $i  ##+++2011_10_22
echo wayBack1=$wayBack1  ##+++2011_10_22
wayBack1=$((wayBack1+1))  ##+++2011_10_22
cdPattern="${cdPattern}../"
if [ "`cd $cdPattern && pwd`" = '/' ] ; then
echo breaking now
break
fi
#wayBack1=$((wayBack1+1))  ##+-+2011_10_22
done
[ "$wayBack1" -le 0 ] && wayBack1=1

for k in `seq 1 $wayBack1` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath="$dirNameLinkTarget"
echo relativePath=$relativePath
count4=0
for k in `seq 1 $wayBack1` ; do  ##for k in $pathWayBacK "../../" == 1
count4=$((count4+1))
echo $k $count4 $dirNameLinkTarget
relativePathField=`echo "$pattern2222" | cut -f $count4 -d ' '`
echo relativePathField=$relativePathField
if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $pattern2222 | cut -f $count4 -d ' '`" != "`echo $pattern1111 | cut -f $count4 -d ' '`" ]] ; then

pat1000=`echo "$dirNameLinkTarget" | cut -f $((count4+1)) -d '/'`
pat2000=`echo "$dirNameLinkToRm" | cut -f $((count4+1)) -d '/'`

if [ "$pat1000" == "$pat2000" ] ; then
################==
relativePath=`echo "$relativePath" | sed "s/$pat2000//"`
fi

#relativePath=`echo $relativePath | sed "s/^/\\.\\.\\//"`
#echo relativePathField=$relativePathField

else
echo 'else'
echo $dirNameLinkTarget | cut -f $((count4+1)) -d '/'
echo $dirNameLinkToRm | cut -f $((count4+1)) -d '/'
relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"`
fi

relativePath=`echo "$relativePath" | sed "s/^/\\.\\.\\//"`
echo relativePathField=$relativePathField

else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done

relativePath=`echo "$relativePath" | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e "$relativePath/$baseNameLinkTarget" ] ; then
echo "removing $link"
rm "$link"
echo "creating link .."
echo -e "\e[1;32m""$relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"  ##+2011_10_22 added coloration
ln -s "$relativePath/$baseNameLinkTarget" "$currentDir/$baseNameLinkToRm"
else
echo -e "\e[1;31m""WARNING: $relativePath/$baseNameLinkTarget does not exists""\e[0;39m"
sleep 5s
fi 

fi
#pathWayBack='';pathWayBack=''
#pattern1='';pattern11='';pattern111='';pattern1111=''
#pattern2='';pattern22='';pattern222='';pattern2222=''

fi
else
echo -e "\e[1;32m""OK , $lsl""\n""is a leative link""\e[0;39m" ##+-+2011_10_22 was "\e[\0;39m"
fi
pathWayBack='';pathWayBack=''
pattern1='';pattern11='';pattern111='';pattern1111=''
pattern2='';pattern22='';pattern222='';pattern2222=''
fi

done
#}  ##+-+2011_10_22

#check_func  ##+-+2011_10_22







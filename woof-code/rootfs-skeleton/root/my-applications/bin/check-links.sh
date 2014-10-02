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
# /dev/hda8:
# LABEL="MacPup431_O2"
# UUID="6d9a8e91-c301-4ff8-9875-97ec708cbee8"
# TYPE="ext3"
# DISTRO_NAME='Puppy'
# DISTRO_VERSION=431
# DISTRO_BINARY_COMPAT='puppy'
# DISTRO_FILE_PREFIX='pup'
# DISTRO_COMPAT_VERSION='4'
# PUPMODE=2
# KERNVER=2.6.37.4-KRG-Pentium-Classic-LowLatency-TmpDevFs-1
# PUP_HOME='/'
# SATADRIVES='·'
# USBDRIVES='·sda·'
# Linux·puppypc·2.6.37.4-KRG-Pentium-Classic-LowLatency-TmpDevFs-1·#5·SMP·PREEMPT·Sat·Mar·19·03:33:33·GMT-8·2011·i686·GNU/Linux
# X·Window·System·Version·1.3.0
# Release·Date:·19·April·2007
# X·Protocol·Version·11,·Revision·0,·Release·1.3
# Build·Operating·System:·UNKNOWN·
# Current·Operating·System:·Linux·puppypc·2.6.37.4-KRG-Pentium-Classic-LowLatency-TmpDevFs-1·#5·SMP·PREEMPT·Sat·Mar·19·03:33:33·GMT-8·2011·i686
# Build·Date:·28·November·2007
# $LANG=de_DE@euro
# today=Mi·2.·Nov·13:06:58·GMT+1·2011
# TODO1 : {
#         OK , lrwxrwxrwx 1 root root 26 2011-10-14 12:02 ./compiled ->
#         ../../../../../var/lib/xkb
#         is a leative link
#         }
#
# TODO2 : {
#   /etc/X11/xkb
#
#   /usr/X11R7/bin/xkbcomp
#   lrwxrwxrwx 1 root root 22 2011-11-02 13:04 ./xkbcomp -> /usr/X11R7/bin/xkbcomp
#   not a relative link
#   realPathLinkToRm=/xkbcomp
#   dirNameLinkToRm=/
#   dirNameLinkTarget=/usr/X11R7/bin
#   pattern1=
#   pattern2=usr X11R7 bin
#   pattern11=
#   pattern22=nib 7R11X rsu
#   pattern111=
#   pattern222=bin X11R7 usr
#   BusyBox v1.18.3 (2011-05-01 19:45:13 CEST) multi-call binary.
#
#   Usage: dirname FILENAME
#
#   Strip non-directory suffix from FILENAME
#
#   /usr/X11R7
#   BusyBox v1.18.3 (2011-05-01 19:45:13 CEST) multi-call binary.
#
#   Usage: dirname FILENAME
#
#   Strip non-directory suffix from FILENAME
#
#   same dir
#   shortPattern=/
#   shortPattern1=\/
#   shortPattern2=usr/X11R7/bin
#   usr/X11R7/bin/xkbcomp does not exists
#   } ~FIXED with currWorkingDir=$currentDir
#   }
#   /etc/X11/xkb
#   /etc/X11/xkb
#   /usr/X11R7/bin/xkbcomp
#   lrwxrwxrwx 1 root root 22 2011-11-02 13:04 ./xkbcomp -> /usr/X11R7/bin/xkbcomp
#   not a relative link
#   realPathLinkToRm=/etc/X11/xkb/xkbcomp
#   dirNameLinkToRm=/etc/X11/xkb
#   dirNameLinkTarget=/usr/X11R7/bin
#   pattern1=etc X11 xkb
#   pattern2=usr X11R7 bin
#   pattern11=bkx 11X cte
#   pattern22=nib 7R11X rsu
#   pattern111=xkb X11 etc
#   pattern222=bin X11R7 usr
#   /etc/X11 /usr/X11R7
#   count1=2
#   wcWordsPattern2222=3
#   pattern2222=bin X11R7 usr
#   count2=2
#   wcWordsPattern1111=3
#   pattern1111=xkb X11 etc
#   pattern2222 turn ...
#   bin
#   wayBack=1
#   X11R7
#   wayBack=2
#   usr
#   wayBack=3
#   pathWayBack=../
#   relativePath=/usr/X11R7/bin
#   1 1 /usr/X11R7/bin
#   relativePathField=bin
#   relativePathField not empty
#   relativePathField=bin
#   relativePath=../usr/X11R7/bin
#   WARNING: ../usr/X11R7/bin/xkbcomp does not exists
#   } ~FIXED by setting wayBack1=0;cdPattern=''
#   {
#   wayBack=3
#   pathWayBack=../../
#   relativePath=/usr/X11R7/bin
#   1 1 /usr/X11R7/bin
#   relativePathField=bin
#   relativePathField not empty
#   relativePathField=bin
#   2 2 /usr/X11R7/bin
#   relativePathField=X11R7
#   relativePathField not empty
#   relativePathField=X11R7
#   relativePath=../../usr/X11R7/bin
#   WARNING: ../../usr/X11R7/bin/xkbcomp does not exists
#   } ~FIXED by counting wayback1 BEFORE break
#
#
#   TODO3 : doubblequote filenames
#
# TODO-2011_11_04 :
# {
# /usr/X11R6/bin
# /var/X11R6/bin/X
# lrwxrwxrwx 1 root root 16 2010-06-15 12:45 ./X -> /var/X11R6/bin/X
# not a relative link
# realPathLinkToRm=/usr/X11R6/bin/X
# dirNameLinkToRm=/usr/X11R6/bin
# dirNameLinkTarget=/var/X11R6/bin
# pattern1=usr X11R6 bin
# pattern2=var X11R6 bin
# pattern11=nib 6R11X rsu
# pattern22=nib 6R11X rav
# pattern111=bin X11R6 usr
# pattern222=bin X11R6 var
# /usr/X11R6 /var/X11R6
# count1=2
# wcWordsPattern2222=3
# pattern2222=bin X11R6 var
# count2=2
# wcWordsPattern1111=3
# pattern1111=bin X11R6 usr
# pattern2222 turn ...
# bin
# X11R6
# var
# wayBack=1
# pathWayBack=../
# relativePath=/var/X11R6/bin
# 1 1 /var/X11R6/bin
# relativePathField=bin
# relativePathField not empty
# else
# var
# usr
# relativePathField=bin
# relativePath=../var/X11R6/..
# WARNING: ../var/X11R6/../X does not exists
# } ~FIXED
#
# TODO :
# {
# currWorkingDir=/var/X11R6
# /mnt/sda1/var/X11R6
# /var/X11R6
# /usr/X11R6/lib/X11
# lrwxrwxrwx 1 root root 18 2010-06-13 04:54 ./lib -> /usr/X11R6/lib/X11
# not a relative link
# realPathLinkToRm=/var/X11R6/lib
# dirNameLinkToRm=/var/X11R6
# dirNameLinkTarget=/usr/X11R6/lib
# pattern1=var X11R6
# pattern2=usr X11R6 lib
# pattern11=6R11X rav
# pattern22=bil 6R11X rsu
# pattern111=X11R6 var
# pattern222=lib X11R6 usr
# /var /usr/X11R6
# count1=1
# wcWordsPattern2222=3
# pattern2222=lib X11R6 usr
# count2=2
# wcWordsPattern1111=2
# pattern1111=fake_for_23969 X11R6 var
# content=fake_for_23969
# fake_for_23969 is not equal
# wc -w var X11R6 -gt usr X11R6 lib
# wayBack=1
# content=X11R6
# X11R6 is [not] equal
# wc -w usr X11R6 lib -gt var X11R6
# wayBack=1
# content=var
# var is not equal
# wc -w var X11R6 -gt usr X11R6 lib
# wayBack=2
# pathWayBack=../../
# relativePath=/usr/X11R6/lib
# k2
# 1 2 /usr/X11R6/lib
# relativePathField=usr
# relativePathField not empty
# usr
# var
# k2
# 2 3 /usr/X11R6/lib
# relativePathField=X11R6
# relativePathField not empty
# else
# X11R6
# X11R6
# relativePath=../usr/lib
# WARNING: ../usr/lib/X11 does not exists
# }

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
currWorkingDir="$currentDir"  ##+++2011_11_02
echo currentDir=$currentDir
echo 10
mountPoints=`busybox mount | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/^ *//g' | cut -f 3 -d ' ' | grep -v -w '/'`
echo 11
echo $mountPoints
for dir in $mountPoints ; do
echo $dir
#grepPattern=`echo $dir | sed 's/\\//\\/\\//g'`  #-2011-11-04
grepPattern=`echo $dir | sed 's/\([[:punct:]]\)/\\\\\\1/g'`  #+++2011-11-04
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


check_func(){

links=`find . -maxdepth 1 -type l | sort -d`

for link in $links ; do
#echo $link

lsl=`ls -l $link`
exist=`readlink -e "$link"`
linkTarget=`echo $lsl | rev | sed 's/^[[:blank:]]*//' | cut -f 1 -d ' ' | rev`
echo $exist
echo $linkTarget

if [ ! "$exist" ]; then
echo /"${linkTarget//\.\.\//}"
echo "${linkTarget##*/}"
find /"${linkTarget//\.\.\//}" -name "${linkTarget##*/}"
linkTarget=`find /"${linkTarget//\.\.\//}" -name "${linkTarget##*/}"`
#exit
fi

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

baseNameLinkToRm=`basename $link`
realPathLinkToRm="${currWorkingDir}/${baseNameLinkToRm}"
echo realPathLinkToRm=$realPathLinkToRm

dirNameLinkToRm=`dirname $realPathLinkToRm`
dirNameLinkTarget=`dirname $linkTarget`
[ "$dirNameLinkTarget" == "." ] && dirNameLinkTarget="$dirNameLinkToRm"
baseNameLinkTarget=`basename $linkTarget`

echo dirNameLinkToRm=$dirNameLinkToRm
echo dirNameLinkTarget=$dirNameLinkTarget

#pattern1=${dirNameLink/\(\/\)/ /}
#pattern2=${dirNameLinkTarget/\// /}

pattern1=`echo "$dirNameLinkToRm" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`
pattern2=`echo "$dirNameLinkTarget" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern1=$pattern1
echo pattern2=$pattern2

pattern11=`echo $pattern1 | rev`
pattern22=`echo $pattern2 | rev`

echo pattern11=$pattern11
echo pattern22=$pattern22

for i in $pattern11 ; do
new=`echo $i | rev`
pattern111="$pattern111 $new"
done
pattern111=`echo $pattern111 | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

for i in $pattern22 ; do
new=`echo $i | rev`
pattern222="$pattern222 $new"
done
pattern222=`echo $pattern222 | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern111=$pattern111
echo pattern222=$pattern222
pattern1111="$pattern111"
pattern2222="$pattern222"

echo -e "\e[1;33m"`dirname $currWorkingDir` `dirname $dirNameLinkTarget`"\e[0;39m"

if [[ "$pattern111" == "$pattern222" ]] ; then
echo -e "\e[1;35m""same directory""\e[0;39m"
if [ -e $baseNameLinkTarget ] ; then
echo "rm link .."
rm $link
echo -e "\e[0;32m""creating link $baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s $baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[0;31m""$baseNameLinkTarget does not exists""\e[0;39m"
fi

elif [[ "`dirname $currWorkingDir`" == "`dirname $dirNameLinkTarget`" ]] ; then
echo -e "\e[1;35m""same upper directory""\e[0;39m"
sedpattern=`dirname $dirNameLinkTarget | sed 's#\/#\\\/#g'`
echo sedpattern=$sedpattern
shortPath=`echo $linkTarget | sed "s/$sedpattern//"`
echo shortPath=$shortPath
shortPath1=''
shortPath2="../$shortPath"
if [ -e $shortPath2 ] ; then
echo "rm link .."
rm $link
echo -e "\e[0;32m""creating link $shortPath2 $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s $shortPath2 $currentDir/$baseNameLinkToRm
else
echo -e "\e[0;31m""$shortPath2 does not exists""\e[0;39m"
fi

elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo -e "\e[1;35m""same dir""\e[0;39m"
shortPattern=`echo "$dirNameLinkTarget" | grep -o "^$dirNameLinkToRm"`
echo shortPattern=$shortPattern
shortPattern1=`echo $shortPattern | sed 's#\/#\\\/#g'`
echo shortPattern1=$shortPattern1
shortPattern2=`echo $dirNameLinkTarget | sed "s/^$shortPattern1//"`
echo shortPattern2=$shortPattern2
shortPattern3=`echo $shortPattern2 | sed 's#^\/##'`
#baseNameLinkTarget2222=`basename $dirNameLinkTarget`
if [ -e $shortPattern3/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo -e "\e[0;32m""creating  $shortPattern3/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s $shortPattern3/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
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

wayBack1=0;cdPattern="../"
for i in `seq 1 $wayBack` ; do
cdPattern="${cdPattern}../"
if [ "`cd $cdPattern && pwd`" = '/' ] ; then
break
fi
wayBack1=$((wayBack1+1))
done

for k in `seq 1 $wayBack1` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath=$dirNameLinkTarget
echo relativePath=$relativePath
count4=1
for k2 in `seq 1 $wayBack1` ; do
echo k2=$k2  ##for k in $pathWayBacK "../../" == 1
count4=$((count4+1))
echo $k $count4 $dirNameLinkTarget
relativePathField=`echo $dirNameLinkTarget | cut -f $count4 -d '/'`
echo relativePathField=$relativePathField

if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $dirNameLinkTarget | cut -f $count4 -d '/'`" != "`echo $dirNameLinkToRm | cut -f $count4 -d '/'`" ]] ; then
##########################################################!=
echo $dirNameLinkTarget | cut -f $count4 -d '/'
echo $dirNameLinkToRm | cut -f $count4 -d '/'

relativePath=`echo $relativePath | sed 's#^#\.\.\/#' | tr -s '/'`
[ -e $relativePath/$baseNameLinkTarget ] && break
else
echo 'else'
echo $dirNameLinkTarget | cut -f $count4 -d '/'
echo $dirNameLinkToRm | cut -f $count4 -d '/'

#relativePath=`echo $relativePath | sed "s/$relativePathField//"`  ##-2011-11-04
#relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"`
relativePath=`echo $relativePath | sed 's#^#\.\.\/#' | tr -s '/'` ##+++2011-11-04
[ -e $relativePath/$baseNameLinkTarget ] && break
fi
else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done
relativePath=`echo $relativePath | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e $relativePath/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo "creating link .."
echo -e "\e[1;32m""$relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm""\e[0;39m"
ln -s $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[1;31m""WARNING: $relativePath/$baseNameLinkTarget does not exist""\e[0;39m"
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
rm $link
echo "creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[0;31m""../$baseNameLinkTarget2222/$baseNameLinkTarget does not exists""\e[0;39m"
fi
}
elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo -e "\e[1;35m""same sub dir""\e[0;39m"
baseNameLinkTarget2222=`basename $dirNameLinkTarget`
if [ -e $baseNameLinkTarget2222/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo "creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s $baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[0;31m""$baseNameLinkTarget2222/$baseNameLinkTargetdoes not exists""\e[0;39m"
fi

else
echo "pattern2222 turn ..."
echo pattern1111="$pattern1111"
count3=0; wayBack=0
for content in $pattern2222 ; do
echo $content
count3=$((count3+1))
#if [[ "$content" != "`echo $pattern1111 | cut -f $count3 -d ' '`" ]] ; then  ##--2011_11_04
wayBack=$((wayBack+1))
echo wayBack=$wayBack
#fi  ##--2011_11_04
done
[ "$wayBack" == 0 ] && wayBack=1

#wayBack1=0;cdPattern="../"  ##-2011_11_02
wayBack1=0;cdPattern=''      ##+2011_11_02
for i in `seq 1 $wayBack` ; do
wayBack1=$((wayBack1+1))  ##+2011_11_02
cdPattern="${cdPattern}../"
if [ "`cd $cdPattern && pwd`" = '/' ] ; then
break
fi
#wayBack1=$((wayBack1+1))  ##-2011_11_02
done
[ "$wayBack1" -le 0 ] && wayBack1=1

for k in `seq 1 $wayBack1` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath=$dirNameLinkTarget
echo relativePath=$relativePath
count4=0
for k in `seq 1 $wayBack1` ; do  ##for k in $pathWayBacK "../../" == 1
count4=$((count4+1))
echo $k $count4 $dirNameLinkTarget
relativePathField=`echo $pattern2222 | cut -f $count4 -d ' '`
echo relativePathField=$relativePathField
if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $pattern2222 | cut -f $count4 -d ' '`" != "`echo $pattern1111 | cut -f $count4 -d ' '`" ]] ; then

pat1000=`echo $dirNameLinkTarget | cut -f $((count4+1)) -d '/'`
pat2000=`echo $dirNameLinkToRm | cut -f $((count4+1)) -d '/'`

###---2011-11-04 : out again
#if [ "$pat1000" == "$pat2000" ] ; then
 ################==
#relativePath=`echo $relativePath | sed "s/$pat2000//"`
#fi
###---2011-11-04 : out again

#relativePath=`echo $relativePath | sed "s/^/\\.\\.\\//"`
#echo relativePathField=$relativePathField

else
echo 'else'
echo $dirNameLinkTarget | cut -f $((count4+1)) -d '/'
echo $dirNameLinkToRm | cut -f $((count4+1)) -d '/'
# relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"` ##---2011_11_04 ../usr/../
fi

relativePath=`echo $relativePath | sed "s/^/\\.\\.\\//"`
echo relativePathField=$relativePathField
[ -e $relativePath/$baseNameLinkTarget ] && break
else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done

relativePath=`echo $relativePath | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e $relativePath/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo "creating link .."
echo $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
ln -s $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
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
echo -e "\e[1;32m""OK , $lsl""\n""is a leative link""\e[0;39m"
fi
pathWayBack='';pathWayBack=''
pattern1='';pattern11='';pattern111='';pattern1111=''
pattern2='';pattern22='';pattern222='';pattern2222=''
fi

done
}

check_func







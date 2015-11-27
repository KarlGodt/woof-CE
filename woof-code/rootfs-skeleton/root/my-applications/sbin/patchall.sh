#!/bin/bash

#alias patch=/usr/bin/patch
PATCH_BIN=/usr/bin/patch

usage (){
	echo "$0 [-pNUMBER] [-o] [-h]
	-p*) patchlevel ie -p1 (default)
	-o)  omitt *.diff in toplevel dir: ie debian.diff
		to apply ony patces created by that diff
	-h) help to show this usage

	Cause to show this usage:
	$1
	"
	exit $2
}

echo $LINENO $0 START
echo `pwd`

PL=1;OMIT='NO';MAXDEPTH=1;
for p in $@;do
case $p in
-p[0-9])PL="${p//-p/}";;
-a)OMIT='YES';MAX_DEPTH=2;;
-h)usage "Show usage" 0;;
*)usage "INVALID option $p" 1;;
esac
done
echo "PATCHLEVEL='$PL'"


#find the patch files
#find: paths must precede expression
#P=`find -name "*.patch" |sort`
echo "looking for .patch files .."
P=`find . -name "*.patch" |sort`

for i in $P;do
c=$((c+1))
echo "$i"
#apply the patches and log the output
echo "
$i" >> patch.log
logsave -a patch.log $PATCH_BIN -p$PL < $i;
read -p "hit any key to continue " -n1 k; echo;done

#show rej files in geany
echo "looking for .rej files .."
find -name "*.rej" -exec defaulttexteditor {} \;

#for .dpatch
echo "looking for .dpatch files .."
P=`find . -name "*.dpatch" |sort`
#[ ! "$P" ] && exit 0

for i in $P;do
c=$((c+1))
echo "$i"
#apply the patches and log the output
echo "
$i" >> patch.log
logsave -a patch.log $PATCH_BIN -p$PL < $i;
read -p "hit any key to continue " -n1 k; echo;done

#show rej files in geany
echo "looking for .rej files .."
find -name "*.rej" -exec defaulttexteditor {} \;

ALL='./*'
if [ "$OMIT" = 'YES' ];then
ALL='./*/*'
fi

#for .diff
echo "looking for .diff files .."
P=`find $ALL -name "*.diff" |sort`
if [ ! "$P" ];then
echo
exit 0
fi

for i in $P;do
c=$((c+1))
echo "$i"
#apply the patches and log the output
echo "
$i" >> patch.log
logsave -a patch.log $PATCH_BIN -p$PL < $i;
read -p "hit any key to continue " -n1 k; echo;done

#show rej files in geany
echo "looking for .rej files .."
find -name "*.rej" -exec defaulttexteditor {} \;

defaulttexteditor patch.log

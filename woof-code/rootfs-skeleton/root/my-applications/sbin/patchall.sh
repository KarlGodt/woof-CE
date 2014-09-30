#!/bin/bash

usage (){
	echo "$0 [-pNUMBER] [-a]

	$1
	"
	exit $2
}

echo $LINENO $0 START
echo `pwd`

PL=1;ALLo='NO'
for p in $@;do
case $p in
-p[0-9])PL="${p//-p/}";;
-a)ALLo='YES';;
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
#apply the patches and loo the output
logsave -a patch.log patch -p$PL < $i;
read -p "hit any key to continue " -n1 k; done

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
#apply the patches and loo the output
logsave -a patch.log patch -p$PL < $i;
read -p "hit any key to continue " -n1 k; done

#show rej files in geany
echo "looking for .rej files .."
find -name "*.rej" -exec defaulttexteditor {} \;

ALL='./*'
if [ "$ALLo" = 'YES' ];then
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
#apply the patches and loo the output
logsave -a patch.log patch -p$PL < $i;
read -p "hit any key to continue " -n1 k; done

#show rej files in geany
echo "looking for .rej files .."
find -name "*.rej" -exec defaulttexteditor {} \;

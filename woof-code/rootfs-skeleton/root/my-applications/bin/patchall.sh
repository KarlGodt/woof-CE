#!/bin/bash

echo "$LINENO $0 START"
echo `pwd`

#find the patch files
#find: paths must precede expression
#P=`find -name "*.patch" |sort`
P=`find . -name "*.patch" |sort`

for i in $P;do
c=$((c+1))
echo -n "Applying $i ?";read k
echo
if [ "$k" = 'N' ];then
echo "exiting $0";exit $?
elif [ "$k" = 'n' ];then
echo "skipping $i";continue;fi
#apply the patches and loo the output
logsave -a patch.log patch -p1 < $i;
#read -n1 k;
done

#show rej files in geany
find -name "*.rej" -exec defaulttexteditor {} \;

#for .dpatch
P=`find . -name "*.dpatch" |sort`
#[ ! "$P" ] && exit 0

for i in $P;do
c=$((c+1))
echo -n "Applying $i ?";read k
echo
if [ "$k" = 'N' ];then
echo "exiting $0";exit $?
elif [ "$k" = 'n' ];then
echo "skipping $i";continue;fi
#apply the patches and loo the output
logsave -a patch.log patch -p1 < $i;
#read -n1 k;
done

#show rej files in geany
find -name "*.rej" -exec defaulttexteditor {} \;

ALL='./*'
if [ $1 ];then
ALL='./*/*'
fi

#for .diff
P=`find $ALL -name "*.diff" |sort`
[ ! "$P" ] && exit 0

for i in $P;do
c=$((c+1))
echo -n "Applying $i ?";read k
echo
if [ "$k" = 'N' ];then
echo "exiting $0";exit $?
elif [ "$k" = 'n' ];then
echo "skipping $i";continue;fi
#apply the patches and loo the output
logsave -a patch.log patch -p1 < $i;
#read -n1 k;
done

#show rej files in geany
find -name "*.rej" -exec defaulttexteditor {} \;

echo "$LINENO $0 END"
exit $?

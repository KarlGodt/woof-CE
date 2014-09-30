#!/bin/sh
#

#
#
#

#
#
#

for dir in `pwd`/* ; do
echo "$dir"
if [ -d "$dir" ];then
#cd ./$dir
cd "$dir"
pwd
if [ -x ./configure ];then
configureall.sh
echo "Proceed ?"
read -t20 -n1 k
k=`echo $k |tr '[[:upper:]]' '[[:lower:]]'`
if [ "$k" = 'n' ];then

#break
echo;exit 100
fi
pwd
fi
cd ..
fi
pwd
done



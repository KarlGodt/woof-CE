#!/bin/bash


files=`ls -1`
files=`echo "$files" |grep '\.deb$'`

for f in $files ;do
echo $f
fd=`echo $f |sed 's#\.deb$##'`
mkdir "$fd"
dpkg-deb2 -x $f ./$fd
sync
mv $f ./$fd
done


#!/bin/bash


files=`ls -1`
files=`echo "$files" |grep '\.tar\.gz$'`

for f in $files ;do
echo $f
#fd=`echo $f |sed 's#\.tar\.gz$##'`
#mkdir "$fd"
tar -xf $f
sync
mv $f ./$fd
done

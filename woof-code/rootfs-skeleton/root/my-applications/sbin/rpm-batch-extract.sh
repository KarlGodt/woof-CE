#!/bin/bash


files=`ls -1`
files=`echo "$files" |grep '\.rpm$'`

for f in $files ;do
echo $f
fd=`echo $f |sed 's#\.rpm$##'`
mkdir "$fd"
#cp $f "$fd.cpio"
rpm2cpio $f >$fd.cpio
cd ./$fd
cat ../$fd.cpio |cpio -i -d
cd ..
sync
#rm $fd.cpio
mv $f ./$fd
#revert:
#find . -name "*.rpm" -exec cp {} ../ \
done

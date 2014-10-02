#!/bin/bash
bf=`ls -1 |grep '~$'`
for i in $bf;do
echo $i
nn="${i//~/}"
echo $nn
if [ -e $nn ];then
mv $nn $nn.back
fi
mv $i $nn
done
bf=`ls -1 |grep '\.back$'`
for i in $bf;do
echo $i
nn="${i//\.back/~}"
echo $nn
mv $i $nn
done

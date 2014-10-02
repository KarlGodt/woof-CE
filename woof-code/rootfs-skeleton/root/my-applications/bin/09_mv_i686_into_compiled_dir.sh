#!/bin/bash

#
#
#

#
#
#

mkdir COMPILED.D

CD=`find . -type d -name "*-i686"`

for i in $CD;do
echo $i
bn=`basename $i`
mv $i COMPILED.D/$bn

done


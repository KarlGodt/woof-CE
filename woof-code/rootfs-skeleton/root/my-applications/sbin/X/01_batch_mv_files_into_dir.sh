#!/bin/bash

#
#
#

#
#
#

PAT='.tar.gz'
gPAT='\.tar\.gz$'

mkdir TARGZs
files=`find . -maxdepth 1 -type f -name "*$PAT"`

for i in $files;do

mv $i ./TARGZs/

done






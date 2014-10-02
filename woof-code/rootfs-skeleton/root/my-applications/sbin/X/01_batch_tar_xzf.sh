#!/bin/bash

#
#
#

#
#
#

PAT='.tar.gz'
gPAT='\.tar\.gz$'

files=`find . -maxdepth 1 -type f -name "*$PAT"`

for i in $files;do

tar xzf $i

done

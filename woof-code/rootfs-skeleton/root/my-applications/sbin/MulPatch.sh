#!/bin/sh

cd `pwd`
pwd
sleep 9s

DIRS=`find . -maxdepth 1 -type d | sed 's#\./##g'`
PATCHES=`find . -maxdepth 1 -name "*.diff" -o -name "*.patch"`
[ -z "$PATCHES" ] && echo "No patches found. Exiting" && exit
for i in $PATCHES ; do
echo "$i"
#grep -A 1 '\-\-\-' $i
pathline=`grep -m 1 '\-\-\- .*' $i | cut -f 2 -d ' '`
echo '$pathline='"$pathline"
for j in $DIRS ; do
pathdir=`echo $pathline | grep -o ".*$j/" | sed "s,$j/(.*),$j/,"`
echo '$pathdir='"$pathdir"
[ -z "$pathdir" ] && continue
[ -n "$pathdir" ] && break
done
patchline=`echo $pathdir | sed 's#^/## ; s#/$##'`
echo '$patchline='"$patchline"
pVal=`echo $patchline | grep -o '/' | wc -l`
echo '$pVal='"$pVal"
patch -p $pVal < $i
echo
echo
done


###EXPRIEMENTAL for XORG compile>>>
cleanup_func(){
mkdir _A_LA
A=`find . -name "*.a"`
for i in $A ; do echo $i; cp $i _A_LA/`basename $i` ; done
LA=`find . -name "*.la"`
for i in $LA ; do echo $i; cp $i _A_LA/`basename $i` ; done
mkdir _SO
SO=`find . -name "*.so"`
for i in $SO ; do echo $i; cp $i _SO/`basename $i` ; done
}
##########<<<<


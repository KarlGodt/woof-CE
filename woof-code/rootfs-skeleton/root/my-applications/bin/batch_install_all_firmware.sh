#!/bin/sh

cd /lib/modules/all-firmware

dirs=`find . -maxdepth 1 -type d`

dirs=`echo "$dirs" | sed 's#^\.##'`

echo "$dirs"

first(){
for i in $dirs ; do echo $i ;
cd .$i; cp -i -r * / ;
pwd ;cd ../ ; 
pwd ; sleep 3s;
done
}

second(){
for i in $dirs ; do echo $i ;
cd .$i ;
pwd ; ls ;
if [ -d ./etc/init.d ] ; then
echo 'chmoding ...'
chmod 0660 ./etc/init.d/*
fi
bname=`basename $(pwd)`
[ ! -d /lib/firmware/$bname ] && mkdir /lib/firmware/$bname
find . -iname "LICENSE" -exec mv "{}" "{}.$bname" \; -exec echo 'renaming license file' \;
sync
cp -a -r * / ;
pwd ; sleep 3 ; sync ;
if [ -f /pinstall* ] ; then
echo 'pinstall.sh exists'
mv /pinstall* /lib/firmware/$bname/
fi
echo "/lib/firmware/$bname EMPTY ?"
ls /lib/firmware/$bname
if [ -z "`ls /lib/firmware/$bname 2>/dev/null`" ] ; then
echo 'EMPTY'
rmdir /lib/firmware/$bname
fi
echo '**********'
cd ../ ; pwd ;
done
}
second


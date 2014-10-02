#!/bin/sh

##/dev/.udev/db :

DB=`find /dev/.udev/db/ -type l`

##getting the sysfs path :

echo "$DB" | 
sed 's/^\/dev\/\.udev\/db//g ;
s/^/\\\/sys/g ;
s:\\x::g ;
s:2f:\\\/:g ;
s:\\::g' | tr -s '/'

##getting the link target:

for i in $DB ; do ls -l $i | grep -o '\/.*' ; done






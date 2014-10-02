#!/bin/sh
#
#
#


fIlename="$1"
hEad="$2"

wc -l /sbin/init #$filename
dc 1909 150 \- p #tAil=

head -n 150 /sbin/init >/root/init.head.150
tail -n 1759 /sbin/init >/root/init.tail.1759

cat /root/init.tail.1759 | sed 's/^#.*//g' >/root/init.tail.nocomments
wc -l /root/init.tail.nocomments

cat /root/init.tail.nocomments | sed '/^$/d' >/root/init.tail.new
wc -l /root/init.tail.new

cat /root/init.tail.new | sed 's/[[:blank:]]*$//g' >/root/init.tail.new.1
wc -l /root/init.tail.new.1

cat /root/init.tail.new.1 | sed 's/^[[:blank:]]*#.*//g' >/root/init.tail.new.2
wc -l /root/init.tail.new.2

cat /root/init.tail.new.2 | sed '/^$/d' >/root/init.tail.new.3
wc -l /root/init.tail.new.3

cat /root/init.head.150 >/root/init.complete
cat /root/init.tail.new.3 >>/root/init.complete
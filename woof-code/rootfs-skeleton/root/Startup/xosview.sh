#!/bin/ash

mySELF=`realpath "$0"`
myDIR="${mySELF%/*}"

test -f "$myDIR"/bin/xosview || exit
exec "$myDIR"/bin/xosview 2>/dev/null

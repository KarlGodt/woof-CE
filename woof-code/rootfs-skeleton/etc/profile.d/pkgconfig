#!/bin/ash
# set the PKG_CONFIG_PATH variable
#

__old_func__(){  #needs bash
export PKG_CONFIG_PATH=""
for x in {/usr,/opt}{,/*}/{share,lib?*,lib}/pkgconfig $HOME/lib{?*,}/pkgconfig ; do
    [ -d "$x" ] && PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$x"
done
}

wantOVERRIDE=;  # ←  if set to any regular char: precede libray paths, else append
fMAXDEPTH=4     # ← -maxdepth level argument for find command
[ "$fMAXDEPTH" ] || fMAXDEPTH=5

PKG_CONFIG_PATH='';

#DIRS=`find /usr -maxdepth $fMAXDEPTH -type d -name "pkgconfig"`
#2016-02-08: This find code is very slow on K7 1045MHz
# GNU find: 5-8 sec., bb find 20 sec.

for n in `seq 1 1 $fMAXDEPTH` ;
do
DIRS=`/bin/find /usr -mindepth $n -maxdepth $n -type d -name pkgconfig | sort -d`
 for dir in $DIRS; do [ -d "$dir" ] || continue;
  if test "$wantOVERRIDE"; then
   PKG_CONFIG_PATH="$dir:${PKG_CONFIG_PATH}"
  else
   PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:$dir"
 fi
 done
done

case $PKG_CONFIG_PATH in
\:*) PKG_CONFIG_PATH="${PKG_CONFIG_PATH#:}";;
*\:) PKG_CONFIG_PATH="${PKG_CONFIG_PATH%:}";;
esac

export PKG_CONFIG_PATH

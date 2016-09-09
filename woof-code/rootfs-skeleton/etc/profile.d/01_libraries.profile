#!/bin/bash

wantOVERRIDE=;  # ←  if set to any regular char: precede libray paths, else append
fMAXDEPTH=4     # ← -maxdepth level argument for find command
[ "$fMAXDEPTH" ] || fMAXDEPTH=5

LD_LIBRARY_PATH='';
case `uname -m` in
*_64)
[ "$LD_LIBRARY_PATH" ] || LD_LIBRARY_PATH=/lib64;;
*)
[ "$LD_LIBRARY_PATH" ] || LD_LIBRARY_PATH=/lib;;
esac

#DIRS=`find /usr -maxdepth $fMAXDEPTH -type d -name lib`
#2016-02-08: This find code is very slow on K7 1045MHz
# GNU find: 5-8 sec., bb find 20 sec.

__todo_find_usr_multilib(){
# does not work many tries even using eval if wrapped into double quotes
# like
#multiLIBDIRS='"lib" "lib32*" "lib64*" "lib-*86*"'
# for ignores the wildcard in such case
multiLIBDIRS='lib lib32* lib64* lib-*86*'
# TODO: check against machine arch and if kernel supports i386 if x86_64

unset fNAMES
set - $multiLIBDIRS
_debug "\$@='$@'"
#for  entry in $multiLIBDIRS
for entry
do
_debug "$entry "
if test "$fNAMES"; then
fNAMES="-name $entry -o $fNAMES"
else
fNAMES="-name $entry"
fi
done

_debug "$fNAMES"
unset LD_LIBRARY_PATH

[ "$LD_LIBRARY_PATH" ] || LD_LIBRARY_PATH=/lib
#DIRS=`/bin/find /usr -maxdepth $fMAXDEPTH -type d \( $fNAMES \) |sort`
#DIRS=$(/bin/find /usr -maxdepth $fMAXDEPTH -type d \( "$fNAMES" \) |sort)
#DIRS="$(/bin/find /usr -maxdepth $fMAXDEPTH -type d \( $fNAMES \) |sort)"
#DIRS="`/bin/find /usr -maxdepth $fMAXDEPTH -type d ( "$fNAMES" ) |sort`"

set - $fNAMES
_debug "\$@='$@'"
#eval DIRS="`/bin/find /usr -maxdepth $fMAXDEPTH -type d \( $@ \) |sort`"
DIRS=`/bin/find /usr -maxdepth $fMAXDEPTH -type d \( "$@" \) |sort`

_debug DIRS=$DIRS
#for dir in $DIRS; do LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$dir" ; done
 for dir in $DIRS; do [ -d "$dir" ] || continue;
  if test "$wantOVERRIDE"; then
   LD_LIBRARY_PATH="$dir:${LD_LIBRARY_PATH}"
  else
   LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$dir"
  fi
 done

_debug "\$@='$@'"
}
__todo_find_usr_multilib

_stable_find_usr_lib(){
for n in `seq 1 1 $fMAXDEPTH`;
do
DIRS_USR=`/bin/find /usr -mindepth $n -maxdepth $n -type d -name lib | sort -d`
 for dir in $DIRS_USR; do [ -d "$dir" ] || continue;
  if test "$wantOVERRIDE"; then
   LD_LIBRARY_PATH="$dir:${LD_LIBRARY_PATH}"
  else
   LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$dir"
  fi
 done
done
}
#_stable_find_usr_lib

_stable_find_opt_lib(){
test -d /opt || mkdir /opt
for n in `seq 1 1 $fMAXDEPTH` ;
do
DIRS_OPT=`/bin/find /opt -mindepth $n -maxdepth $n -type d -name lib | sort -d`
 for dir in $DIRS_OPT; do [ -d "$dir" ] || continue;
  if test "$wantOVERRIDE"; then
   LD_LIBRARY_PATH="$dir:${LD_LIBRARY_PATH}"
  else
   LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$dir"
  fi
 done
done
}
#_stable_find_opt_lib

# ↓ add /usr/X11[R[67]] -- just in case ↓ #
_add_x11_lib_path(){
# ↓ add /usr/X11[R[67]] -- just in case ↓ #
if test "$wantOVERRIDE"; then :; else
case $LD_LIBRARY_PATH in */X11*/lib*) return 0;; esac # ← already in LD_LIBRARY_PATH
fi

if test -e /usr/X11; then
rpX11=`realpath /usr/X11`
 if [ -d "$rpX11" ]; then
  if [ "$wantOVERRIDE" ]; then
   LD_LIBRARY_PATH="${rpX11}:${LD_LIBRARY_PATH}"
  else
   LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${rpX11}"
  fi
 fi
fi
}
_add_x11_lib_path

# ↓  2016-09-09 get rid of any pre or post colons ↓ #
case $LD_LIBRARY_PATH in
\:*) LD_LIBRARY_PATH=${LD_LIBRARY_PATH#\:} ;;
*\:) LD_LIBRARY_PATH=${LD_LIBRARY_PATH%\:} ;;
esac

export LD_LIBRARY_PATH

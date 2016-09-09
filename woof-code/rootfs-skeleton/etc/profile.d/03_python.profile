#!/bin/bash

fMAXDEPTH=4 # ← -maxdepth level argument for find command
[ "$fMAXDEPTH" ] || fMAXDEPTH=5

__create_pythonpath(){

export PYTHON="/usr/bin/python"
PYTHONPATH='';

#DIRS=`find /usr -maxdepth $fMAXDEPTH -type d -name python*`

#2016-02-08: This find code is very slow on K7 1045MHz
# GNU find: 5-8 sec., bb find 20 sec.
for n in `seq 1 1 $fMAXDEPTH` ;
do
DIRS=`/bin/find /usr -mindepth $n -maxdepth $n -type d \( -wholename "*/bin/*python*" -o -wholename "*python*/bin" \) | sort -d`
for dir in $DIRS ; do [ -d "$dir" ] || continue; PYTHONPATH="${PYTHONPATH}:$dir" ; done
done
}



# 2016-09-06 want to set to version
whichPY=`which python`
test -e "$whichPY" || return 1 # ← could be a broken symlink ;)
export PYTHON="$whichPY"

lpyVERSION=`python -V 2>&1 | awk '{print $2}'`
pyVERSION=${lpyVERSION:0:3}    # ← just the first two digits eg. "2.5" of eg. "2.5.6"

unset PYTHONPATH

if [ "$pyVERSION" ]; then
DIRS=`/bin/find /usr -maxdepth $fMAXDEPTH -type d -path "*/lib/python${pyVERSION}" | sort`
 for dir in $DIRS ; do [ -d "$dir" ] || continue
  if test "$wantOVERRIDE"; then
   PYTHONPATH="$dir:${PYTHONPATH}" ;
  else
   PYTHONPATH="${PYTHONPATH}:$dir"
  fi
 done
else
DIRS=`/bin/find /usr -maxdepth $fMAXDEPTH -type d -path "*/lib/python*" | sort`
 for dir in $DIRS ; do [ -d "$dir" ] || continue
  if test "$wantOVERRIDE"; then
   PYTHONPATH="$dir:${PYTHONPATH}"
  else
   PYTHONPATH="${PYTHONPATH}:$dir"
  fi
 done
fi

case $PYTHONPATH in
\:*) PYTHONPATH="${PYTHONPATH#:}";;
*\:) PYTHONPATH="${PYTHONPATH%:}";;
esac

export PYTHONPATH

#PYTHONSTARTUP: file executed on interactive startup (no default)
#
#PYTHONPATH   : ':'-separated list of directories prefixed to the
#               default module search path.  The result is sys.path.
#PYTHONHOME   : alternate <prefix> directory (or <prefix>:<exec_prefix>).
#               The default module search path uses <prefix>/pythonX.X.
#PYTHONCASEOK : ignore case in 'import' statements (Windows).
#
#PYTHONIOENCODING: Encoding[:errors] used for stdin/stdout/stderr.
#
#PYTHONHASHSEED: if this variable is set to 'random', the effect is the same
#   as specifying the -R option: a random value is used to seed the hashes of
#   str, bytes and datetime objects.  It can also be set to an integer
#   in the range [0,4294967295] to get hash values with a predictable seed.

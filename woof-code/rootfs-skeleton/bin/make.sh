#!/bin/ash

Version='1.1-Opera2'
Version='1.2.1-Fox3'


_kill_jobs(){
    for j in `jobs -p`; do kill -9 $j; done
}

trap "_kill_jobs;exit" INT KILL TERM


_TTY_=`tty`
[ "$_TTY_" = 'not a tty' ] && unset _TTY_

errlog=make-errs.log
OUT=/dev/null #/dev/stdout
ERR=/dev/null #/dev/stderr
VERB=-v  #-v
#Q=-q

DATE_START="`date`"

_echo(){
 if test "$_TTY_"; then
  echo "$@" >$_TTY_
 else
  echo "$@" >&2
 fi
}

sleep 0.2 #1.0

if [ -e "$errlog" ] ; then

## get max number
max=2
#( ls -1 "$errlog".[0-9]* ) 2>>$ERR && rotates=`ls -1 "$errlog".[0-9]* |cut -f3 -d. | sort -n |tail -n1`
#( ls -1 "$errlog".[0-9]* ) 2>>$ERR && rotates=`ls -1 "$errlog".[0-9]* |cut -f3 -d. | wc -l`
( ls -1 "$errlog".[0-9]* ) 2>>$ERR && rotates=`ls -1 "$errlog".[0-9]* |cut -f3 -d.`

[ "$DEBUG" ] && _echo rotates=$rotates

#test "$rotates" || rotates=0
test "$rotates" || rotates='';

[ "$DEBUG" ] && _echo rotates=$rotates
[ "$DEBUG" ] && _echo max=$max

#for r in `seq $rotates -1 0`; do
for r in $rotates ; do
[ "$r" -gt $max ] && max=$r
done

[ "$DEBUG" ] && _echo rotates=$rotates
[ "$DEBUG" ] && _echo max=$max

## start at last number (max) and rotate down
for n in `seq $max -1 0` ; do

[ "$DEBUG" ] && echo 1 $n
#[ -e "$errlog".$n ] && mv $VERB "$errlog".$n "$errlog".$((n+1))
 [ -e "${errlog}".$n ] || continue
[ "$DEBUG" ] && echo 2 $n
 [ -L "${errlog}".$n ] && continue
[ "$DEBUG" ] && echo 3 $n
 [ -f "${errlog}".$n ] || continue
[ "$DEBUG" ] && echo 4 $n

 #grep -iE 'warning|error|warnung|fehler|mismatch|fatal' "${errlog}".$n >$_TTY_ || { rm ${VERB:+'-v'} "${errlog}".$n; continue; } >$_TTY_
 cat "${errlog}".$n | grep -iE 'warning|error|warnung|fehler|mismatch|fatal' || { rm ${VERB:+'-v'} "${errlog}".$n; continue; }

[ "$DEBUG" ] && echo 5 $n
 mv $VERB "${errlog}".$n "${errlog}".$((n+1))
done >$_TTY_

#[ -f "$errlog" ] && mv $VERB "$errlog" "$errlog".0
[ "$DEBUG" ] && ls "$errlog" >$_TTY_
( [ -f "$errlog" ] && { cat "$errlog" >>"$errlog".0;rm ${VERB:+'-v'} "$errlog"; } ) >$_TTY_

fi


(
echo
echo `date` "$@"
echo "$PWD:`pwd`"
) >> "$errlog"

_quote_parameters(){
##make.bin: *** No rule to make target `/root/Downloads/KERNEL/linux-3.4/arch/"x86_64"/Makefile'.  Stop.
_echo LINENO $LINENO
PARAMETERS=`echo "$@" |sed 's|=|=\\\\"|g'`
#PARAMETERS=`echo "$@" |sed 's|=|="|g'`

_echo LINENO $LINENO
#PARAMETERS=`echo "$PARAMETERS" | sed 's|\( [[-_][:alpha:][:digit:]]*=\)|\\\\"\1|g'`
#sed: -e expression #1, char 41: Invalid range end
PARAMETERS=`echo "$PARAMETERS" | sed 's|\( [[:punct:][:alpha:][:digit:]]*=\)|\\\\"\1|g'`

_echo LINENO $LINENO
PARAMETERS=`echo "$PARAMETERS" | sed 's|=\\\\" |=\\\\"\\\\" |g'`

_echo LINENO $LINENO
#***
#~ # C='STATE="BAC -ghj -I/usr/include" NEWSTATE="WERT -Y/gh'
#~ # echo "$C" |sed 's|=\("[^" ]*\)|=\1"|g'
#STATE="BAC" -ghj -I/usr/include" NEWSTATE="WERT" -Y/gh
#PARAMETERS=`echo "$PARAMETERS" |sed 's|=\("[^" ]*\)|=\1"|g'`
#***

#***
PARAMETERS=`echo "$PARAMETERS" |sed 's|=\("[^"]*\)$|=\1"|'`
_echo LINENO $LINENO

}

#
if [ "$_TTY_" ]; then
#echo "
#PARAMETERS:
#$PARAMETERS
#" >$_TTY_

echo "
ALL:
$@
" >$_TTY_

else

#echo "
#PARAMETERS:
#$PARAMETERS
#" >&2

echo "
ALL:
$@
" >&2
fi


#if [ "`echo "$@"`" != '' ]; then
if test "$*"; then
make.bin "$@" 2>>"$errlog"
 RET_VAL=$?
else
make.bin $PARAMETERS 2>>"$errlog"
 RET_VAL=$?
#lief gut bisher# make.bin "$@" 2>>"$errlog"
fi
#RET_VAL=$?

if [ "$RET_VAL" -ne '0' ];then

if [ "$_TTY_" ]; then
echo -e "\\033[1;31m""ERROR : '$RET_VAL' for
make '$@' .""\\033[0;39m" >$_TTY_
else
echo -e "\\033[1;31m""ERROR : '$RET_VAL' for
make '$@' .""\\033[0;39m" >&2
fi

#test -s "$errlog" && defaulttexteditor "$errlog" &

else
 if [ "$_TTY_" ]; then
  echo -e "\\033[1;32m""OK : make '$@' finished with '$RET_VAL'""\\033[0;39m" >$_TTY_
 else
  echo -e "\\033[1;32m""OK : make '$@' finished with '$RET_VAL'""\\033[0;39m" >&2
 fi

fi

if [ -f "$errlog" ]; then
 if  [ "$_TTY_" ]; then
  ( grep -Ei 'warning|error|warnung|fehler|mismatch|fatal' "$errlog" || { echo "Removing $errlog" ;
  rm ${VERB:+'-v'} "$errlog" ;
  } )         | tail -n15 >$_TTY_
# } ) >$_TTY_ | tail -n15 >$_TTY_
 else
#( grep -Ei 'warning|error|warnung|fehler' "$errlog" >&2 || { echo "Removing $errlog" >&2 ;rm "$errlog" >&2; } ) |tail -n15 >&2
( grep -Ei 'warning|error|warnung|fehler|mismatch|fatal' "$errlog" || { echo "Removing $errlog" ;
rm ${VERB:+'-v'} "$errlog" && sleep 0.2;
  } )     | tail -n15 >&2
# } ) >&2 | tail -n15 >&2
 fi
fi

sleep 0.2
test -s "$errlog" && {
if [ "$_TTY_" ]; then
  echo -e "\\033[1;31m""See '$errlog' for details ..
""\\033[0;39m" >$_TTY_
else
  echo -e "\\033[1;31m""See '$errlog' for details ..
""\\033[0;39m" >&2
fi
    defaulttexteditor "$errlog" &
}

if [ "$_TTY_" ]; then
echo "$DATE_START" >$_TTY_
echo "`date`" >$_TTY_
else
echo "$DATE_START" >&2
echo "`date`" >&2
fi

exit $RET_VAL

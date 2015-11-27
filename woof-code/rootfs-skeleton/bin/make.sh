#!/bin/ash

Version='1.1-Opera2'
Version='1.2-Fox3'


_kill_jobs(){
    for j in `jobs -p`; do kill -9 $j; done
}

trap "_kill_jobs;exit" INT KILL TERM


_TTY_=`tty`
[ "$_TTY_" = 'not a tty' ] && unset _TTY_

errlog=make-errs.log

DATE_START="`date`"
sleep 1

if [ -e "$errlog" ] ; then

## get max number
max=0
rotates=`ls -1 "$errlog".[0-9]* |cut -f3 -d.`

for r in $rotates ; do
[ "$r" -gt $max ] && max=$r
done

## start at last number (max) and rotate down
for n in `seq $max -1 0` ; do
#[ -e "$errlog".$n ] && mv $VERB "$errlog".$n "$errlog".$((n+1))
 [ -e "$errlog".$n ] || continue
 grep -q -Ei 'warning|error|warnung|fehler|mismatch|fatal' "$errlog".$n || { rm "$errlog".$n; continue; }
 mv $VERB "$errlog".$n "$errlog".$((n+1))
done

#[ -f "$errlog" ] && mv $VERB "$errlog" "$errlog".0
 [ -f "$errlog" ] && { cat "$errlog" >>"$errlog".0;rm "$errlog"; }

fi


echo >> "$errlog"
echo `date` "$@" >> "$errlog"
echo "$PWD:`pwd`" >> "$errlog"

_quote(){  ##make.bin: *** No rule to make target `/root/Downloads/KERNEL/linux-3.4/arch/"x86_64"/Makefile'.  Stop.
echo $LINENO >&2
PARAMETERS=`echo "$@" |sed 's|=|=\\\\"|g'`
#PARAMETERS=`echo "$@" |sed 's|=|="|g'`
echo $LINENO >&2
#PARAMETERS=`echo "$PARAMETERS" | sed 's|\( [[-_][:alpha:][:digit:]]*=\)|\\\\"\1|g'`
#sed: -e expression #1, char 41: Invalid range end
PARAMETERS=`echo "$PARAMETERS" | sed 's|\( [[:punct:][:alpha:][:digit:]]*=\)|\\\\"\1|g'`
echo $LINENO >&2
PARAMETERS=`echo "$PARAMETERS" | sed 's|=\\\\" |=\\\\"\\\\" |g'`
echo $LINENO >&2

#***
#~ # C='STATE="BAC -ghj -I/usr/include" NEWSTATE="WERT -Y/gh'
#~ # echo "$C" |sed 's|=\("[^" ]*\)|=\1"|g'
#STATE="BAC" -ghj -I/usr/include" NEWSTATE="WERT" -Y/gh
#PARAMETERS=`echo "$PARAMETERS" |sed 's|=\("[^" ]*\)|=\1"|g'`
#***

#***
PARAMETERS=`echo "$PARAMETERS" |sed 's|=\("[^"]*\)$|=\1"|'`
echo $LINENO >&2

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


if [ "`echo "$@"`" != '' ]; then
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
make '$@' .
See '$errlog' for details ..
""\\033[0;39m" >$_TTY_
else
echo -e "\\033[1;31m""ERROR : '$RET_VAL' for
make '$@' .
See '$errlog' for details ..
""\\033[0;39m" >&2
fi

defaulttexteditor "$errlog" &

else
 if [ "$_TTY_" ]; then
  echo -e "\\033[1;32m""OK : make '$@' finished with '$RET_VAL'""\\033[0;39m" >$_TTY_
 else
  echo -e "\\033[1;32m""OK : make '$@' finished with '$RET_VAL'""\\033[0;39m" >&2
 fi

fi

if [ -f "$errlog" ]; then
 if  [ "$_TTY_" ]; then
  ( grep -Ei 'warning|error|warnung|fehler|mismatch|fatal' "$errlog" || { echo "Removing $errlog" >$_TTY_ ;
  rm "$errlog" >$_TTY_;
  } ) |tail -n15 >$_TTY_
 else
#( grep -Ei 'warning|error|warnung|fehler' "$errlog" >&2 || { echo "Removing $errlog" >&2 ;rm "$errlog" >&2; } ) |tail -n15 >&2
( grep -Ei 'warning|error|warnung|fehler|mismatch|fatal' "$errlog" || { echo "Removing $errlog" >&2 ;
rm "$errlog" >&2;
} ) |tail -n15 >&2
 fi
fi

if  [ "$_TTY_" ]; then
echo "$DATE_START" >$_TTY_
echo "`date`" >$_TTY_
else
echo "$DATE_START" >&2
echo "`date`" >&2
fi

exit $RET_VAL

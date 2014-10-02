#!/bin/bash

#****************
#
#****************

log=bkscripts_macro.log

MACRO_BEGIN='
#************
#KRG
'
MACRO_END='
#KRG
#************
'
MACRO_DEBUG='
OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x
'
MACRO_INFO='
Version=1.1-KRG-MacPup_O2
usage(){
MSG="
$0 [ help | version ]
"
echo "$MSG
$2"
exit $1
}
[ "`echo "$1" | grep -Ei 'help|\-h'`" ] && usage 0
[ "`echo "$1" | grep -Ei 'version|\-V'`" ] && { echo "$0: $Version";exit 0; }
'
MACRO_TRAP='
trap "exit" HUP INT QUIT ABRT KILL TERM
'

[ -f bkscripts.lst ] || { echo "No bkscipts.lst file in $PWD. Run bkscripts_find.sh again|first";exit 0; }

while read line ; do
wp="${line%%\:*}"
echo "$wp"; echo "$wp" >>$log
[ "$wp" ] || continue
[ -L "$wp" ] && { echo "Is LINK"; echo "Is LINK" >>$log ; continue; }
[ -f "$wp" ] || { echo "Not a FILE" ; echo "Not a FILE" >>$log ; continue; }

IS_EXE=`ls -l "$wp" |awk '{print $1}' | grep 'x'`
if [ "$IS_EXE" ] ;then

cp -a --backup=numbered "$wp" "${wp}.orig"

#total lines
tl=`wc -l "$wp" |awk '{print $1}'`
#first free line
ffl=`grep -n -m1 '^$' "$wp" |awk '{print $1}'`

[ "$ffl" ] || { echo "No free line"; continue; }
[[ "$ffl" =~ '[[:alpha:]]' ]] && { echo "$ffl Not clean number" ; echo "$ffl Not clean number" >>$log ; continue; }
[[ "$ffl" =~ '[[:punct:]]' ]] && { echo "$ffl Not clean number" ; echo "$ffl Not clean number" >>$log ; continue; }

head -n $ffl "$wp" > "${wp}.head"
tail -n $((tl-ffl)) "$wp" > "${wp}.tail"

if [ "`grep 'usage(){' "$wp"`" ];then
echo "Already done" ; echo "Already done" >>$log
else

cat "${wp}.head" > "$wp"
sleep 1
echo "
$MACRO_BEGIN
$MACRO_DEBUG
$MACRO_INFO
$MACRO_TRAP
$MACRO_END
" >> "$wp"

#sed 's|2>/dev/null|2>$ERR|' "${wp}.tail" >"${wp}.tail.new"
sed -e 's|\([^"`=]*\)\( 2>/dev/null\)\([^"`]*\)$|\1 2>$ERR\3|' "${wp}.tail" >"${wp}.tail.new"
[ $? = 0 ] || { echo "SED ERROR" ; echo "SED ERROR" >>$log ; exit 1; }
#further checks
[ -s "${wp}.tail.new" ] || { echo "CHANGED FILE EMPTY" ; echo "CHANGED FILE EMPTY" >>$log ; exit 1; }
[ "`ls -s "${wp}.tail.new" |awk '{print $1}'`" -gt 0 ] || { echo "LS CHANGED FILE EMPTY" ; echo "LS CHANGED FILE EMPTY" >>$log ; exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' "${wp}.tail.new"`" ] || { echo "GREP CHANGED FILE EMPTY" ; echo "GREP CHANGED FILE EMPTY" >>$log ; exit 1; }
#grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2

cat "${wp}.tail.new" >> "$wp"
sleep 1
chmod +x "$wl"

fi #grep usage

else
echo "NOT executable" ; echo "NOT executable" >>$log
fi #IS_EXE

done<bkscripts.lst

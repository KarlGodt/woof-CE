#!/bin/bash

DATE=`date`

MACRO_CHANGELOG_B="
###KRG $DATE

"

MACRO_CHANGELOG_E="

###KRG $DATE
"
MACRO_TRAP='
trap "exit 1" HUP INT QUIT KILL TERM
'

MACRO_DEBUG='
OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x
'

MACRO_VERSION="
Version='1.1'
"

MACRO_USAGE='
usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
echo "$USAGE_MSG"
exit $1
}

[ "`echo "$1" | grep -wE "[Hh]elp|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wE "[Vv]ersion|\-V"`" ] && { echo "$0 -version $Version";exit 0; }
'

#[ "`echo "$1" | grep -wE "\-help|\-H"`" ] && usage 0
#[ "`echo "$1" | grep -wE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }

[ -s bkscripts.lst ] || { echo need db file bkscripts.lst; exit 1; }

cut -f1 -d ':' bkscripts.lst | grep -v '^#' |sort -d >bkscripts.lst.sorted

while read line_is_wholepath;do
echo $line_is_wholepath
[ -L "$line_is_wholepath" ] && { echo is LINK;continue; }
[ -f "$line_is_wholepath" ] || { echo Not a FILE;continue; }

#IS_EXE=`ls -l $line_is_wholepath |awk '{print $1}' | grep 'x'`
PERMIS=`stat -c %a $line_is_wholepath`

## '2>/dev/null'
sed -e 's|\([^"]*\)\( 2>/dev/null\)\([^"]*\)$|\1 2>$ERR\3|' $line_is_wholepath > ${line_is_wholepath}.new2
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new2 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new2 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
#grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2

##TODO : '2> /dev/null'
#sed -e 's|\([^"]*\)\( 2> /dev/null\)\([^"]*\)$|\1 2>$ERR\3|' $line_is_wholepath > ${line_is_wholepath}.new2
#[ $? = 0 ] || { echo SED ERROR;exit 1; }
#[ -s ${line_is_wholepath}.new2 ] || { echo CHANGED FILE EMPTY;exit 1; }
#[ "`ls -s ${line_is_wholepath}.new2 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
##[ "`grep -v '^$' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
#[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
##grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2


sleep 1
cp ${line_is_wholepath}.new2 $line_is_wholepath
#[ "$IS_EXE" ] && chmod 0754 $line_is_wholepath
chmod $PERMIS $line_is_wholepath

if grep -Ee 'usage([[:blank:]]*)\(\)|usage\(\)' $line_is_wholepath | grep -vEe '^#|^([[:blank:]]*)#' ;then
echo ADDING usage ALREADY DONE
else
if [ -x $line_is_wholepath ] ;then
FIRST_free_line=`grep -n -m 1 '^$' $line_is_wholepath| cut -f1 -d ':'`
[ "$FIRST_free_line" ] || { echo NOTICE : NO FREE LINE;continue; }
LINES_TOTAL=`wc -l $line_is_wholepath | awk '{print $1}'`
echo $FIRST_free_line $LINES_TOTAL

head -n $FIRST_free_line $line_is_wholepath >${line_is_wholepath}.head
tail -n $((LINES_TOTAL-FIRST_free_line)) $line_is_wholepath >${line_is_wholepath}.tail
cat ${line_is_wholepath}.head >${line_is_wholepath}.new3
echo "$MACRO_CHANGELOG_B
$MACRO_TRAP
$MACRO_DEBUG
$MACRO_VERSION
$MACRO_USAGE
$MACRO_CHANGELOG_E" >>${line_is_wholepath}.new3
cat ${line_is_wholepath}.tail >>${line_is_wholepath}.new3
sleep 1
cp ${line_is_wholepath}.new3 $line_is_wholepath
chmod 0754 $line_is_wholepath
else
echo NOT EXECUTABLE
fi
fi



sed_attempt(){
#sed -e 's|\([^"]*\)\( 2>/dev/null\)\([^"]*\)$|\1 2>$ERR\3|' \
# -e "${FIRST_free_line} i\ $MACRO_CHANGELOG_E" \
# -e "${FIRST_free_line} i\ $MACRO_USAGE" \
# -e "${FIRST_free_line} i\ $MACRO_VERSION" \
# -e "${FIRST_free_line} i\ $MACRO_DEBUG" \
# -e "${FIRST_free_line} i\ $MACRO_CHANGELOG_B" $line_is_wholepath > ${line_is_wholepath}.new2

echo 0
sed -e 's|\([^"]*\)\( 2>/dev/null\)\([^"]*\)$|\1 2>$ERR\3|' $line_is_wholepath > ${line_is_wholepath}.new2
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new2 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new2 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
#grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new2

sleep 1
cp ${line_is_wholepath}.new2 $line_is_wholepath


echo 1
echo "$MACRO_CHANGELOG_E"
sed "${FIRST_free_line} i\ $MACRO_CHANGELOG_E" $line_is_wholepath > ${line_is_wholepath}.new3
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new3 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new3 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new3`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new3`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }

sleep 1
cp ${line_is_wholepath}.new3 $line_is_wholepath


echo 2
sed "${FIRST_free_line} i\ $MACRO_USAGE" $line_is_wholepath > ${line_is_wholepath}.new4
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new4 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new4 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new4`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new4`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }

sleep 1
cp ${line_is_wholepath}.new4 $line_is_wholepath


echo 3
sed "${FIRST_free_line} i\ $MACRO_VERSION" $line_is_wholepath > ${line_is_wholepath}.new5
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new5 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new5 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new5`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new5`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }

sleep 1
cp ${line_is_wholepath}.new5 $line_is_wholepath


echo 4
sed "${FIRST_free_line} i\ $MACRO_DEBUG" $line_is_wholepath > ${line_is_wholepath}.new6
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new6 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new6 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new6`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new6`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }

sleep 1
cp ${line_is_wholepath}.new6 $line_is_wholepath


echo 5
sed "${FIRST_free_line} i\ $MACRO_CHANGELOG_B" $line_is_wholepath > ${line_is_wholepath}.new7
[ $? = 0 ] || { echo SED ERROR;exit 1; }
[ -s ${line_is_wholepath}.new7 ] || { echo CHANGED FILE EMPTY;exit 1; }
[ "`ls -s ${line_is_wholepath}.new7 |awk '{print $1}'`" -gt 0 ] || { echo LS CHANGED FILE EMPTY;exit 1; }
#[ "`grep -v '^$' ${line_is_wholepath}.new7`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }
[ "`grep -m 1 '[[:alnum:]]' ${line_is_wholepath}.new7`" ] || { echo GREP CHANGED FILE EMPTY;exit 1; }

sleep 1
cp ${line_is_wholepath}.new7 $line_is_wholepath
}

done<bkscripts.lst.sorted


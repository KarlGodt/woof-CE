#!/bin/sh
##
#
##

#
#
#


dd if=/dev/vcs1 of=/tmp/TTY1screen bs=1 count=9192

echo -e `cat /tmp/TTY1screen | tr ' ' '�' | sed 's/���/\\\\n/g'` | sed '/^$/d' | tr '�' ' ' | sed 's/^[[:blank:]]*//g'

alternatives(){
#for i in `seq 1 80 9999` ; do
#echo `cat /tmp/TTY1screen | wc -`
#fi
echo -e `cat /tmp/TTY1screen |\
sed -r '{ 
s/(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\
(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)/\
\1\2\3\4\5\6\7\8\9\10\
\11\12\13\14\15\16\17\18\19\20\
\21\22\23\24\25\26\27\28\29\30\
\31\32\33\34\35\36\37\38\39\40\
\41\42\43\44\45\46\47\48\49\50\
\51\52\53\54\55\56\57\58\59\60\
\61\62\63\64\65\66\67\68\69\70\
\71\72\73\74\75\76\77\78\79\80\\\n/g
 }'`

#echo -e `cat /tmp/TTY1screen | tr -s ' ' | sed 's/\(.\{80\}\)/\1\\\\n/g' | sed 's/^[[:blank:]]*//g'`
#echo -e `cat /tmp/TTY1screen | sed 's/^[[:blank:]]*//' | sed 's/\(.\{128\}\)/\1\\\\n/g'` | sed 's/^[[:blank:]]*//g'
echo -e `cat /tmp/TTY1screen | sed 's/\(.\{132\}\)/\1\\\\n/g'` | sed 's/^[[:blank:]]*//g'
echo -e `cat /tmp/TTY1screen | sed 's/\(.\{130\}\)/\1\\\\n/g'`
}
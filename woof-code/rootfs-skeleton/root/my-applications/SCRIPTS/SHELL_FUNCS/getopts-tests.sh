#!/bin/bash

echo "$@"
echo $#

#echo "${BASH_ARGV[@]}"
#set -- `echo "${BASH_ARGV[@]}"`

#PARAMS=`echo "$@" |LC_ALL=C sed 's|\(.*\)\(-A[ ""][a-zA-Z]*\)\(.*\)|\2 \1 \3|'`
#PARAMS=`echo "$PARAMS" |LC_ALL=C sed 's|\(.*\)\(-B[ ""][a-zA-Z]*\)\(.*\)|\2 \1 \3|'`
#PARAMS=`echo "$PARAMS" |LC_ALL=C sed 's|\(.*\)\(-C[ ""][a-zA-Z]*\)\(.*\)|\2 \1 \3|'`
#while [ "`echo "$@" | grep -e '\-[a-zA-Z] *[[:alnum:]]* *\-[a-zA-Z]' | grep -v '\-[ABC] *[[:alnum:]]* *\-[ABC]'`" ];do
#PARAMS=`echo "$PARAMS" |LC_ALL=C sed 's|\(.*\)\(-[^ABC]\)\(.*\)|\2 \1 \3|g'`
#echo "$PARAMS";sleep 2
#done
for i in $@;do
((c++))
PARAMS[$c]=$i
done
echo '------'
echo "${PARAMS[@]}"
echo '------'
while getopts aA:bB:cC: opt;do
echo $opt $OPTARG
case $opt in
a)echo "opt should be 'a' : '$opt'";((SHIFT++));;
A)echo "opt should be 'A' : '$opt' with OPTARG '$OPTARG'";SHIFT=$((SHIFT+2));;
b)echo "opt should be 'b' : '$opt'";((SHIFT++));;
B)echo "opt should be 'B' : '$opt' with OPTARG '$OPTARG'";SHIFT=$((SHIFT+2));;
c)echo "opt should be 'c' : '$opt'";((SHIFT++));;
C)echo "opt should be 'C' : '$opt' with OPTARG '$OPTARG'";SHIFT=$((SHIFT+2));;
*)echo "Unrecognized option '$opt'";;
esac;
#shift; #here it leaves the loop
done
#for i in {1..$SHIFT};do echo -n "$i ";shift;done
#for i in `seq 2 1 $SHIFT`;do echo -n "$i ";shift;done
#echo

pyramide_func(){
while [ "$2" ];do
echo "$@" ;sleep 2
case $1 in
-a|-b|-c)shift;;
-A*|-B*|-C*)shift;;
-A|-B|-C)shift;shift;;
#hHdD:ovVw:W:s:S:
-h|-H|-d|-o|-v|-V)shift;;
-D*|-w*|-W*|-s*|-S*)shift;;
-D|-w|-W|-s|-S)shift;shift;;
*)
#echo $1 ;sleep 2;;#>/dev/null;;
while [ "$2" ];do
echo "$@" ;sleep 2
case $2 in
-a|-b|-c)shift;;
-A*|-B*|-C*)shift;;
-A|-B|-C)shift;shift;;
#hHdD:ovVw:W:s:S:
-h|-H|-d|-o|-v|-V)shift;;
-D*|-w*|-W*|-s*|-S*)shift;;
-D|-w|-W|-s|-S)shift;shift;;
*)
while [ "$3" ];do
echo "$@";sleep 2
case $3 in
#hHdD:ovVw:W:s:S:
-a|-b|-c)shift;;
-A*|-B*|-C*)shift;;
-A|-B|-C)shift;shift;;
-h|-H|-d|-o|-v|-V)shift;;
-D*|-w*|-W*|-s*|-S*)shift;;
-D|-w|-W|-s|-S)shift;shift;;
esac;done
esac;done
esac;done
#esac;done
}
another_no_go(){
for opt in $@;do
echo $@
case $opt in
-a|-b|-c)shift;;
-A[[:alnum:][:punct:]]*|-B[[:alnum:][:punct:]]*|-C[[:alnum:][:punct:]]*)shift;;
-A|-B|-C)shift;shift;;
*)P_KEEP="$P_KEEP $opt";shift;;
esac;done
}
for w in ${PARAMS[@]};do
((cc++))
case $w in
#-h|-H|-d|-o|-v|-V)PARAM[$cc]='';;
-a|-b|-c) echo 1;PARAMS[$cc]='';;
#-D*|-w*|-W*|-s*|-S*)PARAM[$cc]='';;
-A[[:alnum:][:punct:]]?*|-B[[:alnum:][:punct:]]?*|-C[[:alnum:][:punct:]]?*) echo 2;PARAMS[$cc]='';;
#-D|-w|-W|-s|-S)PARAM[$cc]='';dd=$((cc+1));PARAM[$dd]='';;
-A|-B|-C) echo 3;PARAMS[$cc]='';dd=$((cc+1));PARAMS[$dd]='';;
*)echo 4;;
esac;done

echo
echo "$@"
echo $#
#echo "P_KEEP='$P_KEEP'"
echo "${PARAMS[@]}"

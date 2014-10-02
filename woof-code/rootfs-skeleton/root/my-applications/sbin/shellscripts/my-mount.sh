#!/bin/ash

[ $1 ] || { exec busybox mount|sed 's|\(.*\)\( on \)\(.*\)\( type \)\(.*\)\( (.*)\)|"\1"\2"\3"\4"\5"\6|';exit $?; }

echo "'$@'"
echo "LANG='$LANG'"
#echo "${BASH_ARGV[@]}"
#locale
#export LC_ALL='';
set
#export IFS='\n \t';
#OLD_IFS="$IFS"
#IFS=' ';
#export IFS=' \t\n';
#export IFS=" \t\n";
#IFS=`echo -e " \\t\\n"`
#echo -e "' \\t\\n'"
#I=$IFS; IFS=""
#export IFS
echo "IFS='$IFS'"

#for i in `busybox seq 1 1 $#`;do
#for i in {1..$#};do
#for i in `/usr/bin/seq 1 1 $#`;do

PARAMETER_LINE="$@"
PARAM_NR=$#
echo "PARAMETER_LINE='$PARAMETER_LINE' PARAM_NR='$PARAM_NR'"

func_2(){
PARAMS_ALL=`set | grep 'BASH_ARGV='`
echo "PARAMS_ALL='$PARAMS_ALL'"
unset PARAMS_ALL
PARAMS_ALL=`set | grep 'BASH_ARGV=' | sed 's|BASH_ARGV=(||;s|)$||;s|\[|p|g;s|\]|p|g'`
unset PARAMS_ALL
PARAMS_ALL=`set | grep 'BASH_ARGV=' | sed 's|BASH_ARGV=(||;s|)$||;s|\[|p\[|g'`

echo "PARAMS_ALL='$PARAMS_ALL'"
eval `echo "$PARAMS_ALL"`
echo "${p[@]}"
echo ${p[0]}
echo ${p[1]}
echo ${p[2]}
echo ${p[3]}
echo ${p[4]}
echo ${p[5]}
echo '-----'
echo $PARAMS_ALL
eval `echo $PARAMS_ALL`
echo "${p[@]}"
echo ${p[0]}
echo ${p[1]}
echo ${p[2]}
echo ${p[3]}
echo ${p[4]}
echo ${p[5]}
echo '-----'
for con in $PARAMS_ALL;do echo $con

done
echo '-----'
unset PARAMS_ALL
eval `set | grep 'BASH_ARGV=' | sed 's|BASH_ARGV=(||;s|)$||;s|\[|p\[|g'`
echo "${p[@]}"
echo ${p[0]}
echo ${p[1]}
echo ${p[2]}
echo ${p[3]}
echo ${p[4]}
echo ${p[5]}
echo ${p[6]}
echo ${p[7]}

echo '-----'
}
echo "${BASH_ARGV[@]}"
echo "${BASH_ARGV[0]}"
echo "${BASH_ARGC[@]}"
echo "${BASH_ARGC[0]}"
#TC=`echo "${BASH_ARGC[0]}"`
for c in `seq $(echo "${BASH_ARGC[0]}") -1 1`;do
vc=$((c-1));((C++));echo $c $vc $C
if [ "`echo "${BASH_ARGV[$vc]}" | grep '[[:blank:]]'`" ];then
P[$C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^|"|;s|$|"|'`
else
P[$C]=`echo "${BASH_ARGV[$vc]}"`
fi
done
readonly C
echo "${P[@]}"
echo ${P[0]}
echo ${P[1]}
echo ${P[2]}
echo ${P[3]}
echo ${P[4]}
echo ${P[5]}
echo ${P[6]}
echo ${P[7]}
echo ${P[@]}
echo '-----'

func_1(){
while getopts hfvVaFO:inswrp:t:o:L:U: opt;do echo $opt $OPTARG
case $opt in
h|f|v|V|a|F|i|n|s|w|r)PARAMETERLINE_NEW="$PARAMETERLINE_NEW \"-$opt\"";;
O|t|o|L|U)PARAMETERLINE_NEW="$PARAMETERLINE_NEW \"-$opt $OPTARG\"";;
*):;;
esac;done
echo "PARAMETERLINE_NEW='$PARAMETERLINE_NEW'"
echo '-----'
echo $@
echo $#
echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo '-----'
for i in $@;do echo $i
PARAMETERLINE_NEW="$PARAMETERLINE_NEW \"$i\"";shift;done
set $PARAMETERLINE_NEW
echo "$@"
set |head
}

func_0(){

for i in `/usr/local/bin/seq 1 1 $#`;do
echo `eval A=$(echo $i)`;echo "A='$A'"

j=$i;echo "${i}stens";echo "${j}stens";echo ${PARAMETER_LINE[0]}
echo "${i}-----------:::"
/usr/local/bin/echo -n "${i}::::${j}="
P_1=`/usr/local/bin/echo "$@" |awk '{print '$'$i}'`
/usr/local/bin/echo $P_1
/usr/local/bin/echo -n "${i}::::${i}="
/usr/local/bin/echo $@ |awk '{print $i}'

/usr/local/bin/echo -n "${i}::::${j}="
P_2=`/usr/local/bin/echo "$@" |awk '{print $2}'`
/usr/local/bin/echo $P_2
/usr/local/bin/echo -n "${i}::::${i}="
/usr/local/bin/echo $* |awk '{print $i}'

/usr/local/bin/echo -n "${i}::::${j}="
P_3=`/usr/local/bin/echo "$@" |awk '{print $3}'`
/usr/local/bin/echo $P_3
/usr/local/bin/echo -n "${i}::::${i}="
/usr/local/bin/echo "$*" |awk '{print $i}'

/usr/local/bin/echo -n "${i}::::${j}="
P_4=`/usr/local/bin/echo "$@" |awk '{print $4}'`
/usr/local/bin/echo $P_4
/usr/local/bin/echo -n "${i}::::${i}="
/usr/local/bin/echo "$PARAMETER_LINE" |awk '{print $i}'

echo "-----------"

done

unset IFS
IFS="$OLD_IFS"
}

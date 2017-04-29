#!/bin/ash

_exit(){
retVAL=$1
shift
echo "$*"
exit $retVAL
}


_usage(){
RV=${1:-0}
shift
EXTRA_MSG=`gettext "$*"`

MSG="
$0 :

# script to find non-scripts like
# .pet or .jpg in
# /root/GitHub.d/KarlGodt_ForkWoof.Push.D
# directory.
# just prints filename if LSB.
"

MSG=`gettext "$MSG"`
test "$EXTRA_MSG" && echo "$EXTRA_MSG
"
echo "$MSG
"

exit $RV
}

case $* in
-h|*help|*usage) _usage;;
esac

cd /root/GitHub.d/KarlGodt_ForkWoof.Push.D || _exit 1 "No directory /root/GitHub.d/KarlGodt_ForkWoof.Push.D"

test -d woof-code || _exit 1 "Directory woof-code missing"
test -d woof-code/rootfs-skeleton || _exit "Directory woof-code/rootfs-skeleton mising"


FILE_LOCALE='\.pot$|\.mo$'
   FILE_PIC='\.gif$|\.xpm$|\.png$|\.svg$|\.jpg$'
  FILE_EDIT='\.sh$|\.desktop$|\.directory$|\.menu$|\.html$|\.htm$|\.txt$|\.xml$'
 FILE_MUSIC='\.wav$|\.au$|\.mp3$'
  FILE_FONT='\.pcf$|\.pfb$|\.afm$|\.ttf$'
 FILE_OTHER='EMPTYDIRMARKER'

 FILE_COMPR='.tar .gz .bz2 .lz .xz .Z .tgz .txz .rpm .sfs'
  FILE_EDIT='.sh .desktop .directory .menu .html .htm .txt .xml .conf .rules'
  FILE_FONT='.pcf .pfb .afm .ttf'
FILE_LOCALE='.pot .mo'
 FILE_MUSIC='.wav .au .mp3'
 FILE_OTHER='EMPTYDIRMARKER'
   FILE_PIC='.gif .xpm .png .svg .jpg'



for file in     \
 $FILE_COMPR    \
 $FILE_EDIT     \
 $FILE_FONT     \
 $FILE_LOCALE   \
 $FILE_MUSIC    \
 $FILE_OTHER    \
 $FILE_PIC
do

echo "$file" #DEBUG

case "$file"
in
.*) file=`echo "$file" | sed 's/\./\\\\./;s/$/\$/'`;;

*) : ;;
esac

echo "$file" #DEBUG
GREP_LINE="${GREP_LINE}${file}|" # for grep -E

done

GREP_LINE=`echo "$GREP_LINE" | sed 's/^|*//;s!|*$!!' | tr -s '|'`

echo "GREP_LINE='$GREP_LINE'" #DEBUG
#exit #DEBUG

while read oneFILE

do

test "$oneFILE" || continue
#test "`echo "$oneFILE" | grep -E 'EMPTYDIRMARKER|\.pot$|\.mo$|\.pcf$|\.pfb$|\.afm$|\.ttf$|\.wav$|\.au$|\.mp3$|\.sh$|\.desktop$|\.directory$|\.menu$|\.gif$|\.xpm$|\.png$|\.svg$|\.jpg$|\.html$|\.htm$|\.txt$|\.xml$'`" && continue
test "`echo "$oneFILE" | grep -E "$GREP_LINE"`" && continue

oneFILEonOS=`echo "${oneFILE}" | sed 's!woof-code/rootfs-skeleton!!'`

echo "$oneFILE"  #DEBUG

#echo "realpath:`realpath $oneFILE`"
#echo "readlink:`readlink $oneFILE`"

echo -en '\e[1;31m'
file "$oneLINK" | grep LSB
echo -e '\e[0;39m'

#if test -f "$oneFILEonOS";
#then

# oneFILE_MOD=`stat -c %Y "$oneFILE"`
# oneFILEonOS_MOD=`stat -c %Y "$oneFILEonOS"`

# if test $oneFILEonOS_MOD -gt $oneFILE_MOD; then
# echo "$oneFILEonOS is newly modificated"
# cp -a "$oneFILEonOS" "$oneFILE" || break
# git add "$oneFILE" || break
# git commit -m "${oneFILE}:Bulk update." || break
# fi

#fi


sleep 0.1s
done<<EoI
`find woof-code/rootfs-skeleton/ \( -type f \)`
EoI

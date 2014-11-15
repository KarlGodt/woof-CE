
alias modprobe='modprobe -b'
alias xmlto='xmlto --skip-validation --noclean'

#echo "
#LANG='$LANG'
#"
#echo "LC_IDENTIFICATION='$LC_IDENTIFICATION'"
#echo "LC_CTYPE='$LC_CTYPE'"
#echo "LC_COLLATE='$LC_COLLATE'"
#echo "LC_TIME='$LC_TIME'"
#echo "LC_NUMERIC='$LC_NUMERIC'"
#echo "LC_MONETARY='$LC_MONETARY'"
#echo "LC_MESSAGES='$LC_MESSAGES'"
#echo "LC_PAPER='$LC_PAPER'"
#echo "LC_NAME='$LC_NAME'"
#echo "LC_ADDRESS='$LC_ADDRESS'"
#echo "LC_TELEPHONE='$LC_TELEPHONE'"

#LANG_BASE="${LANG%%\_*}"
#echo "LANG_BASE='$LANG_BASE'"
#LANG_2_2="${LANG%%\@*}"
#echo  "LANG_2_2='$LANG_2_2'"
#LANG_MAIN="${LANG_2_2##*\_}"
#echo "LANG_MAIN='$LANG_MAIN'"


#locale -a >/tmp/locale.lst #shows already compiled LANGs from /urs/lib/locale
#locale >tmp/loclae.lst
#source /tmp/loclae.lst

#LCs=`locale`
#for loc in $LCs;do export $loc;done
#echo "
#LANG='$LANG'
#"
#echo "LC_IDENTIFICATION='$LC_IDENTIFICATION'"
#echo "LC_CTYPE='$LC_CTYPE'"
#echo "LC_COLLATE='$LC_COLLATE'"
#echo "LC_TIME='$LC_TIME'"
#echo "LC_NUMERIC='$LC_NUMERIC'"
#echo "LC_MONETARY='$LC_MONETARY'"
#echo "LC_MESSAGES='$LC_MESSAGES'"
#echo "LC_PAPER='$LC_PAPER'"
#echo "LC_NAME='$LC_NAME'"
#echo "LC_ADDRESS='$LC_ADDRESS'"
#echo "LC_TELEPHONE='$LC_TELEPHONE'"

#export LC_IDENTIFICATION LC_CTYPE LC_COLLATE LC_TIME LC_NUMERIC LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE

#function
flashvideo () {
echo "VID='$VID'"
VID=$(stat -c %N /proc/*/fd/* 2>&1|awk -F[\`\'] '/flash/{print$2}')
echo "VID='$VID'"
#VID=`echo "$VID" | grep -v 'flashblock'`
#mplayer -autosync 30 -mc 2.0 -cache 1000 $VID
LINK_TARGET=`readlink -e "$VID"`
echo "LINK_TARGET='$LINK_TARGET'"
if [ "`echo "$LINK_TARGET" | grep -iE 'flashblock|block'`" ]; then
:
else
ffplay $VID
fi
}



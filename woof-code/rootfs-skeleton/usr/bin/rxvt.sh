#!/bin/bash

_set_wrapper(){
MYSELF=`realpath "$0"`
 MYDIR=${MYSELF%/*}
 WRXVT=`which rxvt`
WRXVTB=`which rxvt.bin`
test -x "$WRXVTB" && return 0
test    "$WRXVT"  || return 1
case `file "$WRXVT"` in
*ELF*32-bit*LSB*executable*)
mv $VERB "$WRXVT" "$WRXVT".bin
mv $VERB "$MYSELF" "$MYDIR"/rxvt
;;
esac
}
_set_wrapper

_rxvt_random_font(){
if FONTS=`xlsfonts` ; then
NR_FONTS=`echo "$FONTS" |wc -l`
RANDOM_FONT=`echo $((RANDOM%$NR_FONTS))`
echo $RANDOM_FONT
FONT_USE=`echo "$FONTS" | sed -n "$RANDOM_FONT p"`
echo "$FONT_USE"
test "${FONT_USE//[[:blank:]]/}" || return 0
rxvt.bin -font "$FONT_USE" -name "$FONT_USE" "$@"
else
 rxvt.bin "$@"
fi
exit $?
}

case $* in
*-fn*|*-font*) rxvt.bin "$@"; exit $?;;
*) _rxvt_random_font "$@"
   rxvt.bin "$@"; exit $?;;
esac

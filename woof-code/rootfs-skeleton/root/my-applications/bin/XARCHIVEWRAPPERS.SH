#!/bin/sh

cd /usr/local/lib/xarchive/wrappers

for i in *; do cat $i | sed 's#>/dev/stderr#>>/tmp/xarchive_errs.log#g' > /tmp/$i; mv -f /tmp/$i ./$i ; done 

for i in *; do cat $i | sed 's#> /dev/stderr#>>/tmp/xarchive_errs.log#g' > /tmp/$i; mv -f /tmp/$i ./$i ; done

                                               
for FILE in *; do L=`grep -n 'E_UNSUPPORTED=' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L - 2`; SEDINS='echo >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for FILE in *; do L=`grep -n 'opt="$1"' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L + 1`; SEDINS='echo "options $opt" >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for FILE in *; do L=`grep -n 'archive="$1"' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L + 1`; SEDINS='echo "archive $archive" >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for i in *; do chmod 0755 $i ; done

for i in *; do geany $i ; done

#ARJ_PROG="arj \-+ \-ja1 \-r"


FXARCHIVE=`which xarchive`
DIRXARCHIVE=`dirname "$FXARCHIVE"`
FILEXARCHIVE=`file "$FXARCHIVE"`

if [ -n "`echo $FILEXARCHIVE | grep 'ELF' | grep 'LSB' | grep -i 'executable'`" ] ; then
mv "$FXARCHIVE" "$DIRXARCHIVE"/xarchive.bin


echo '#!/bin/sh
###

exec 2>/tmp/xarchive.bin.err.log

xarchive.bin "$@"

'> "$FXARCHIVE"

chmod 0755 "$FXARCHIVE"

fi


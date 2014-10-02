#!/bin/bash

cd /usr/local/lib/xarchive/wrappers

for file in *; do
echo $file 
LE=`grep -n 'E_UNSUPPORTED=' $file | cut -f 1 -d ':'` ; echo $LE
SEDINSLE=`expr $LE - 2`; echo $SEDINSLE
SEDINSE='echo >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSLE i $SEDINSE" $file

Lo=`grep -n 'opt="$1"' $file | cut -f 1 -d ':'` ; echo $Lo
SEDINSLo=`expr $Lo + 1` ; echo $SEDINSLo
SEDINSo='echo opt $opt >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSLo i $SEDINSo" $file

La=`grep -n 'archive="$1"' $file | cut -f 1 -d ':'` ; echo $La
SEDINSLa=`expr $La + 1`; echo $SEDINSLa
SEDINSa='echo archive $archive >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSLa i $SEDINSa" $file

cat $file | sed -e 's#> /dev/stderr#>>/tmp/xarchive_errs.log#g' -e 's#>/dev/stderr#>>/tmp/xarchive_errs.log#g' > $file-s

cat $file-s | sed '/^$/d' > $file-t ## removes empty lines ; would save 1Byte every empty line
rm $file
rm $file-s ## comment if remove empty lines is commented
mv "$file-t" "$file"
# mv "$file-s" "$file" ## uncomment if remove empty lines is commented out

chmod +x $file ## cat $file > changes permissions
done




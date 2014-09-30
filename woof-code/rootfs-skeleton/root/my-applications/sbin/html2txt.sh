#!/bin/bash

HTMLfile=`ls -1| grep '\.htm$'`
HTMLfile=`echo "$HTMLfile" | head -n1`
file_body="${HTMLfile%.*}"
echo "$file_body"
rm -f "$file_body".txt
cat "$HTMLfile" | sed 's#<#\n<#g;s#>#>\n#g' >"$file_body".txt

TAGS='<!DOCTYPE.*>,<html.*>,<[/""]html>,<head>,<[/""]head>,<meta.*>,<title>,<[/""]title>,<link.*>,<body>,<[/""]body>,<a.*>,</a>,<div.*>,</div>,<img.*>,<h[0-9]>,<[/""]h[0-9]>,<span.*>,</span>,<script.*>,<[/""]noscript>,'

echo "$TAGS" | sed 's#,#\n#g' |while read tag;do echo $tag >&2;
sed -i "s~${tag}~~" "$file_body".txt
done


cat sonderzeichen.txt | grep '&.*\;.*&.*\;' >sonderz.0.txt
cat sonderzeichen.txt | grep -e '[[:blank:]]*–[[:blank:]]*&.*\;' >>sonderz.0.txt
cat sonderz.0.txt |sed 's#, #,#g' >sonderz.1.txt
cat sonderz.1.txt |sed 's# (Programmierung)#(Programmierung)#g' >sonderz.2.txt
cat sonderz.2.txt |sed 's# Symbol#Symbol#g' >sonderz.2.0.txt
cat sonderz.2.0.txt |sed 's, ,|,g' >sonderz.3.txt
cat sonderz.3.txt |sed 's,"|"," ",g' >sonderz.4.txt
cat sonderz.4.txt |sed 's,\t,|,g' >sonderz.6.txt
cat sonderz.6.txt |tr -s '|' >sonderz.8.txt
#cat sonderz.3.txt |grep -o '\|.\|&.*\;\|&.*\;' >sonderz.4.txt
#grep -o '\|.\|&.*\;\|&.*\;' sonderz.3.txt >sonderz.4.txt
cat sonderz.8.txt |cut -f2-4 -d'|' >sonderz.9.txt

UMLAUTS=`cat sonderz.9.txt`
#echo "$UMLAUTS"

cat sonderz.9.txt |while read line;do
#echo "$line"
[ ! "`echo "$line" | grep '[[:alnum:]]'`" ] && continue
SIGN=`echo "$line" |cut -f1 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
HTML=`echo "$line" |cut -f2 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
NUMERIC=`echo "$line" |cut -f3 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
echo "'$SIGN' '$HTML' '$NUMERIC'"
#echo "sed 1"
[ "$HTML" != "–" ] && sed -i "s/$HTML/$SIGN/g" "$file_body".txt
#echo "sed 2"
sed -i "s/$NUMERIC/$SIGN/g" "$file_body".txt

done

LL=`grep -n 'zum Seitenanfang' "$file_body".txt |cut -f1 -d':'`
KEEP=`head -n $LL "$file_body".txt`
echo "$KEEP" |sed '/^$/d' > "$file_body".txt

sed -i 's#Nichtamtliches Inhaltsverzeichnis##' "$file_body".txt
sed -i 's#zum Seitenanfang##' "$file_body".txt
rm sed*

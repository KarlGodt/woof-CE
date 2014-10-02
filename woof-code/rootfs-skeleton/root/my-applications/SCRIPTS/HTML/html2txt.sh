#!/bin/bash

echo $LANG
#NO: export LANG=C
#NO: export LANG=de_DE
#NO: export LANG=de_DE-utf8
#NO: export LANG=de_DE.utf8
export LANG=C
echo $LANG
#sleep 10s

#ECHO=/bin/echo_9base-6
ECHO=echo

#checks part
usage () {
	ERRORMSG="ERROR $2"
	$ECHO "
	$0 [-f]

	Bash shellscript to convert .htm/.html files to .txt files
	in current directory (`pwd`) .
	If invoked with the -f parameter , deletes  tmp dir and target dir ."
	if [ "$2" ];then
	$ECHO "
	$ERRORMSG"
	fi
	$ECHO ""
	exit $1
}

PROGRAM_NAME="$0"
DIRNAME_PROG=`dirname "${PROGRAM_NAME}"`
MAIN_DIRNAME_PROG=`dirname "${DIRNAME_PROG}"`

PROG_LIB_DIR="${MAIN_DIRNAME_PROG}/lib/html2txt"
[ ! -d "${PROG_LIB_DIR}" ] && usage 1 "Could not determine '${PROG_LIB_DIR}'"
SPECIAL_CHAR_FILE="${PROG_LIB_DIR}/special_chars.txt"
[ ! -f "${SPECIAL_CHAR_FILE}" ] && usage 1 "Could not determine '${SPECIAL_CHAR_FILE}'"
HTML_TAGS_FILE="${PROG_LIB_DIR}/default.txt.tags.txt"
[ ! -f "${HTML_TAGS_FILE}" ] && usage 1 "Could not determine '${HTML_TAGS_FILE}'"

#main part
SOURCE_DIR=`pwd`
DIRNAME_SOURCE=`dirname "${SOURCE_DIR}"`
$ECHO "$DIRNAME_SOURCE"
BASENAME_SOURCEDIR=`basename "${SOURCE_DIR}"`
TARGET_MAIN_DIR="${HOME}/${BASENAME_SOURCEDIR}"

TMP_DIR="/tmp/html2txt_wkdir"

DATABASE_MAIN="${TARGET_MAIN_DIR}/.html_files.db"
DATABASE_TMP="${TMP_DIR}/html_files.db"

FORCE="$1";[ "$FORCE" != '-f' ] && FORCE=''
[ "$FORCE" = '-f' ] && rm -rf "${TMP_DIR}" "${TARGET_MAIN_DIR}"
mkdir -p "${TARGET_MAIN_DIR}"
mkdir -p "${TMP_DIR}"


if [ ! -f "${DATABASE_MAIN}" ];then
$ECHO "Building database ..
Dependent on the amount of files this can take a long time .."

#HTML_FILES=`find . -type f \( -name "*.html" -o -name "*.htm" \) -print -exec echo " \"-ORIG-\"" \;`
HTML_FILES0=`find . -type f \( -name "*.html" -o -name "*.htm" \)`


FILENAME_PATTERN='bjnr[0-9]*'
NOT_FILENAME_PATTERN='/__[0-9a-z]*.htm$|index.htm$|art_[0-9a-z_]*.htm$'
HTML_FILES=`echo "${HTML_FILES0}" |grep -Ee "${FILENAME_PATTERN}"`
echo "$HTML_FILES" | head
HTML_FILES=`echo "${HTML_FILES0}" |grep -vEe "${NOT_FILENAME_PATTERN}"`
echo "$HTML_FILES" | head


$ECHO "${HTML_FILES}" > "${DATABASE_TMP}"
if [ ! "`grep -m1 -E '\.htm$|\.html$' ${DATABASE_TMP}`" ];then
usage 1 "Could not find any .htm/.html files"
else
cat "${DATABASE_TMP}" |sort > "${DATABASE_MAIN}"
sedPAT__source=`$ECHO "$SOURCE_DIR" | sed 's,\([[:punct:]]\),\\\\\1,g'`
$ECHO "sedPAT='$sedPAT__source'"
sed -i "s|^\./|${sedPAT__source}/|" "${DATABASE_MAIN}"
sed -i 's|\(.*\)|\1 "-ORIG-"|' "${DATABASE_MAIN}"
$ECHO "Finished building database ."
fi;fi

$ECHO "Preparing html special char database .."
TMP_SPECIAL_CHAR_FILE="${TMP_DIR}/special_chars.txt"
cp "${SPECIAL_CHAR_FILE}" "${TMP_SPECIAL_CHAR_FILE}"
tmp_specials="${TMP_DIR}/special"
german_specials='Ä|&Auml;|&#196;
ä|&auml;|&#228;
Ö|&Ouml;|&#214;
ö|&ouml;|&#246;
" "|&nbsp;|&#160;
Ü|&Uuml;|&#220;
ü|&uuml;|&#252;
ß|&szlig;|&#223;
§|&sect;|&#167;
"|&quot;|&#34;
&|&amp;|&#38;
à|&agrave;|&#224;
€|&euro;|&#8364;'
$ECHO "${german_specials}" > "${tmp_specials}".9.txt

specials_function(){
cat "${TMP_SPECIAL_CHAR_FILE}" | grep '&.*\;.*&.*\;' >"${tmp_specials}".0.txt
#more specials
#cat "${TMP_SPECIAL_CHAR_FILE}" | grep -e '[[:blank:]]*–[[:blank:]]*&.*\;' >>"${tmp_specials}".0.txt
cat "${tmp_specials}".0.txt |sed 's#, #,#g' >"${tmp_specials}".1.txt
cat "${tmp_specials}".1.txt |sed 's# (Programmierung)#(Programmierung)#g' >"${tmp_specials}".2.txt
cat "${tmp_specials}".2.txt |sed 's# Symbol#Symbol#g' >"${tmp_specials}".2.0.txt
cat "${tmp_specials}".2.0.txt |sed 's, ,|,g' >"${tmp_specials}".3.txt
cat "${tmp_specials}".3.txt |sed 's,"|"," ",g' >"${tmp_specials}".4.txt
cat "${tmp_specials}".4.txt |sed 's,\t,|,g' >"${tmp_specials}".6.txt
cat "${tmp_specials}".6.txt |tr -s '|' >"${tmp_specials}".8.txt
cat "${tmp_specials}".8.txt |cut -f2-4 -d'|' >"${tmp_specials}".9.txt
#UMLAUTS=`cat "${tmp_specials}".9.txt`
}

SPECIAL_NR=`wc -l "${tmp_specials}".9.txt |awk '{print $1}'`

$ECHO "Preparing html tags database .."
#TAGS='<!DOCTYPE.*>,<html.*>,<[/""]html>,<head>,<[/""]head>,<meta.*>,<title>,<[/""]title>,<link.*>,<body>,<[/""]body>,<a.*>,</a>,<div.*>,</div>,<img.*>,<h[0-9]>,<[/""]h[0-9]>,<span.*>,</span>,<script.*>,<[/""]noscript>,<ul>,<ul*>,</ul>,<li>,</li>,<table>,<table>,<tr>,<td>,</tr>,</td>,<abbr>,</abbr>'
TMP_TAGS_FILE="${TMP_DIR}/tags.txt"
cp "${HTML_TAGS_FILE}" "${TMP_TAGS_FILE}"
tmp_tags="${TMP_DIR}/tags"
cat "${TMP_TAGS_FILE}" | grep '^<.*>' | cut -f1 -d '>' |sed 's|$|>|' >"${tmp_tags}".0.txt
#custom adds:
$ECHO '<html>
<h[0-9]>
<h[0-9][a-z]>
<h[0-9a-z]*>
<hlj>
<script>
<noscript>' >> "${tmp_tags}".0.txt

cat "${tmp_tags}".0.txt | sort -u > "${tmp_tags}".1.txt
cat "${tmp_tags}".1.txt | grep -vE '<http://.*>|</.*>' > "${tmp_tags}".2.txt
TAGS_NR=`wc -l "${tmp_tags}".2.txt | awk '{print $1}'`

rm -f "${tmp_tags}".4.txt
linenr=0
for m in `seq 1 1 $TAGS_NR`;do
linenr=$((linenr+1))
tag0=`sed -n "$linenr p" "${tmp_tags}".2.txt`
tag1=`$ECHO "$tag0" | sed 's|>|\.\*>|'`
tag2=`$ECHO "$tag0" | sed 's|<|</|'`
$ECHO "$tag0
$tag1
$tag2" >> "${tmp_tags}".4.txt
done

TAGS=`cat "${tmp_tags}".4.txt | tr '\n' ',' |sed 's#,$##'`
#TAGS="${TAGS}<html>,<h[0-9]>,<script>,<noscript>"

$ECHO "Starting to convert .."

FILES_NR=`wc -l "${DATABASE_MAIN}" |awk '{print $1}'`
linenr=0
for n in `seq 1 1 $FILES_NR`;do
linenr=$((linenr+1))

FILE_to_CONVERT=`sed -n "$linenr p" "${DATABASE_MAIN}"`
[ "`$ECHO "${FILE_to_CONVERT}" | grep '\-CONVERTED\-'`" ] && continue

FILE_to_CONVERT=`sed -n "$linenr p" "${DATABASE_MAIN}" |cut -f1 -d '"' |sed 's/ *$//'`
$ECHO "Converting $FILE_to_CONVERT ..."

basename_file_to_conv=`basename "$FILE_to_CONVERT"`
part_dirname_file_to_conv=`basename $(dirname "$FILE_to_CONVERT")`

file_body="${basename_file_to_conv%.*}"
file_tmp="${TMP_DIR}/${file_body}.txt"
converted_file="${TARGET_MAIN_DIR}/${part_dirname_file_to_conv}/${file_body}.txt"
mkdir -p "${TARGET_MAIN_DIR}/${part_dirname_file_to_conv}"
rm -f "${converted_file}"


TMP_FILE_to_CONVERT="${TMP_DIR}/${basename_file_to_conv}"
cp -a "${FILE_to_CONVERT}" "${TMP_FILE_to_CONVERT}"

encoding_func(){
	echo "function encoding_func :"
#ENCODING=`chardet "${TMP_FILE_to_CONVERT}" |cut -f2 -d':' |awk '{print $1}'`
#echo "${FILE_to_CONVERT} : $ENCODING"

ENCODING=`chardet "${1}" |cut -f2 -d':' |awk '{print $1}'`
echo "${1} : $ENCODING"

TMP_CONVERTED="${1}".tmp
rm -f "${TMP_CONVERTED}"

if [ ! "${2}" ];then

if [ ! "`echo "$ENCODING" | grep -i 'ascii'`" ];then
echo -n "Need to 'iconv' it to ASCII ..."

#TMP_CONVERTED="${TMP_FILE_to_CONVERT}".tmp
#TMP_CONVERTED="${1}".tmp
#rm -f "${TMP_CONVERTED}"
#iconv -c --verbose -f $ENCODING -t ASCII -o "${TMP_CONVERTED}" "${TMP_FILE_to_CONVERT}"
iconv -c --verbose -f $ENCODING -t ASCII -o "${TMP_CONVERTED}" "${1}" 2>>"${TMP_CONVERTED}".ERR
sleep 1s

#mv "${TMP_CONVERTED}" "${TMP_FILE_to_CONVERT}"
#cp "${TMP_CONVERTED}" "${1}"
mv "${TMP_CONVERTED}" "${1}"

echo "done"

fi
####

else

ENCODING2=`chardet "${2}" |cut -f2 -d':' |awk '{print $1}'`
echo "${2} : $ENCODING2"

if [ "$ENCODING" != "$ENCODING2" ];then
if [ ! "`echo "$ENCODING2" |grep -i 'ascii'`" ];then
echo -n "Need to 'iconv' $ENCODING to $ENCODING2 ..."

#/tmp/html2txt_wkdir/art_7.txt.tail : EUC-KR
#/tmp/html2txt_wkdir/art_7.txt.head : ISO-8859-2
#Need to 'iconv' EUC-KR to ISO-8859-2 ...iconv: conversion from `EUC-KR' is not supported
#iconv: conversion from `IBM866' is not supported

iconv -c --verbose -f $ENCODING -t $ENCODING2 -o "${TMP_CONVERTED}" "${1}" 2>>"${TMP_CONVERTED}".ERR
#[ "$?" != '0' ] && return
sleep 1s

mv "${TMP_CONVERTED}" "${1}"

echo "done"
fi;fi

fi
}

#encoding_func "${TMP_FILE_to_CONVERT}"

cat "${TMP_FILE_to_CONVERT}" | sed 's#<#\n<#g;s#>#>\n#g' > "${file_tmp}"
[ ! -f "${file_tmp}" ] && exit

$ECHO "Formatting '${file_tmp}' ... head"
$ECHO "$TAGS" | sed 's#,#\n#g' |while read tag;do #echo $tag >&2;
sed -i "s~${tag}~~" "${file_tmp}"
done
cat "${file_tmp}" |sed '/^$/d' > "${file_tmp}".tmp
sleep 1s
mv "${file_tmp}".tmp "${file_tmp}"

#head=`sed -n "1 p" "${file_tmp}"`
#$ECHO "$head" > "${file_tmp}".head
sed -n "1 p" "${file_tmp}" > "${file_tmp}".head
#sed -n "1 !p" "${file_tmp}" > "${file_tmp}".tail



#encoding_func "${file_tmp}"
#encoding_func "${file_tmp}".tail

echo "$part_dirname_file_to_conv"
if [ ! "$part_dirname_file_to_conv" = 'abweiche' ];then
encoding_func "${TMP_FILE_to_CONVERT}"
fi

FUSSNOTE=`grep -n -i 'fu.*note' "${file_tmp}"`
if [ ! "${FUSSNOTE}" ] ;then

cat "${TMP_FILE_to_CONVERT}" | sed 's#<#\n<#g;s#>#>\n#g' > "${file_tmp}"
[ ! -f "${file_tmp}" ] && exit

$ECHO "Formatting '${file_tmp}' ... body"
$ECHO "$TAGS" | sed 's#,#\n#g' |while read tag;do #echo $tag >&2;
sed -i "s~${tag}~~" "${file_tmp}"
done
cat "${file_tmp}" |sed '/^$/d' > "${file_tmp}".tmp
sleep 1s
mv "${file_tmp}".tmp "${file_tmp}"

sed -n "1 !p" "${file_tmp}" > "${file_tmp}".body

else

#FUSS_NOTE_LINE_NR=`echo "${FUSSNOTE}" |cut -f 1 -d ':'`
#echo "FUSS_NOTE_LINE_NR='$FUSS_NOTE_LINE_NR'"
#sed -n "$FUSS_NOTE_LINE_NR,$ p"

cat "${TMP_FILE_to_CONVERT}" | sed 's#<#\n<#g;s#>#>\n#g' > "${file_tmp}"
[ ! -f "${file_tmp}" ] && exit

$ECHO "Formatting '${file_tmp}' ... body and tail"
$ECHO "$TAGS" | sed 's#,#\n#g' |while read tag;do #echo $tag >&2;
sed -i "s~${tag}~~" "${file_tmp}"
done
cat "${file_tmp}" |sed '/^$/d' > "${file_tmp}".tmp
sleep 1s
FUSSNOTE1=`grep -n -i 'fu.*note' "${file_tmp}".tmp`
FUSS_NOTE_LINE_NR=`echo "${FUSSNOTE1}" |cut -f 1 -d ':'`
echo FUSS_NOTE_LINE_NR=$FUSS_NOTE_LINE_NR

#sed -n "$FUSS_NOTE_LINE_NR,$ p" "${file_tmp}".tmp > "${file_tmp}".foot
for fn in $FUSS_NOTE_LINE_NR;do
sed -n "$fn p" "${file_tmp}".tmp > "${file_tmp}".$fn.foot
encoding_func "${file_tmp}".$fn.foot "${file_tmp}".head
done

#sed -i "$FUSS_NOTE_LINE_NR,$ d" "${file_tmp}".tmp
sed -i "1 d" "${file_tmp}".tmp
mv "${file_tmp}".tmp "${file_tmp}".body


#encoding_func "${file_tmp}".foot "${file_tmp}".head

fi


#for j in `seq 1 1 $SPECIAL_NR`;do
#line=`sed -n "$j p" "${tmp_specials}".9.txt`
#line=`/bin/read_9base-6 "${tmp_specials}".9.txt`

#cat "${tmp_specials}".9.txt |while /bin/read_9base-6 line;do
cat "${tmp_specials}".9.txt |while read -r line;do
#cat "${tmp_specials}".9.txt |while read -r -n1 char;do
#$ECHO "$j: $line"

#$ECHO "$line"

#echo "$char"
#done
#exit
[ ! "`$ECHO "$line" | grep '[[:alnum:]]'`" ] && continue

SIGN2=`$ECHO "$line" |cut -f1 -d'|' |sed 's/\([[:punct:]]\)/\\\\\\\\\1/g'`
SIGN1=`$ECHO "$line" |cut -f1 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
SIGN0=`$ECHO "$line" |cut -f1 -d'|'`

HTML0=`$ECHO "$line" |cut -f2 -d'|'`
HTML1=`$ECHO "$line" |cut -f2 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
HTML2=`$ECHO "$line" |cut -f2 -d'|' |sed 's/\([[:punct:]]\)/\\\\\\\\\1/g'`

NUMERIC0=`$ECHO "$line" |cut -f3 -d'|'`
NUMERIC1=`$ECHO "$line" |cut -f3 -d'|' |sed 's/\([[:punct:]]\)/\\\\\1/g'`
NUMERIC2=`$ECHO "$line" |cut -f3 -d'|' |sed 's/\([[:punct:]]\)/\\\\\\\\\1/g'`

#$ECHO "'$SIGN' '$HTML' '$NUMERIC'"

#html_lang(){
#echo "sed 1"
#[ "$HTML" != "–" ] && sed -i "s/$HTML/$SIGN/g" "${file_tmp}" #&& continue

if [ "$HTML" != "–" ];then # &&

#echo "grep 1"
#echo "${HTML0}"
#grep "${HTML0}" "${file_tmp}"
#echo "---"
#echo "grep 2"
#echo "${HTML1}"
#grep "${HTML1}" "${file_tmp}"
#echo "---"
#echo "grep 3"
#echo "${HTML2}"
#grep "${HTML2}" "${file_tmp}"
#echo "---"
#echo "sed 1"
#busybox sed -i "s,${HTML},${SIGN},g" "${file_tmp}" #&&

#sed -i "s,${HTML0},${SIGN0},g" "${file_tmp}"
sed -i "s,${HTML0},${SIGN0},g" "${file_tmp}".head
sed -i "s,${HTML0},${SIGN0},g" "${file_tmp}".body

#if [ -f "${file_tmp}".*.foot ];then #&& sed -i "s,${HTML0},${SIGN0},g" "${file_tmp}".foot
#if [ -f "${file_tmp}.*.foot" ];then
foots=`ls "${file_tmp}".*.foot`
if [ "${foots}" ];then
for foot in $foots;do
echo "${foot}" is a file, seding "'${SIGN0}'"
sed -i "s,${HTML0},${SIGN0},g" "${foot}"
done
fi

#echo "grep 2"
#grep "${SIGN}" "${file_tmp}"
#echo ---
#cat "${file_tmp}"
#continue
fi
#}
#sync
#echo "sed 2"
#sed -i "s/$NUMERIC0/$SIGN1/g" "${file_tmp}"

#cat "${file_tmp}" | sed -r "s/$NUMERIC0/$SIGN1/g" > "${file_tmp}".1

sed -i "s,${NUMERIC0},${SIGN0},g" "${file_tmp}".head
sed -i "s,${NUMERIC0},${SIGN0},g" "${file_tmp}".body
#[ -f "${file_tmp}".foot ] && sed -i "s,${NUMERIC0},${SIGN0},g" "${file_tmp}".foot
#if [ -f "${file_tmp}".*.foot ];then #&& sed -i "s,${HTML0},${SIGN0},g" "${file_tmp}".foot
#if [ -f "${file_tmp}.*.foot" ];then
foots=`ls "${file_tmp}".*.foot`
if [ "${foots}" ];then
for foot in $foots;do
nr=`echo "${foot}" |rev|cut -f2 -d'.'`
echo "${foot}" is a file, seding "'${SIGN0}'"
sed -i "s,${NUMERIC0},${SIGN0},g" "${foot}"
done
fi


sync
#mv "${file_tmp}".1 "${file_tmp}"

done
sleep 2s
#mv "${file_tmp}" "${converted_file}"
cat "${file_tmp}".head > "${file_tmp}"

encoding_func "${file_tmp}".body "${file_tmp}".head
cat "${file_tmp}".body >> "${file_tmp}"

#if [ -f "${file_tmp}".foot ];then
#encoding_func "${file_tmp}".foot "${file_tmp}".head
#cat "${file_tmp}".foot >> "${file_tmp}"
#fi
#if [ -f "${file_tmp}".*.foot ];then
foots=`ls "${file_tmp}".*.foot`
if [ "${foots}" ];then
for foot in $foots;do
nr=`echo "${foot}" |rev|cut -f2 -d'.'|rev`
#encoding_func "${file_tmp}".$nr.foot "${file_tmp}".head
encoding_func "${file_tmp}".$nr.foot "${file_tmp}".body

#SEDp0=`sed -n "$nr p" "${file_tmp}".body`
SEDp0=`sed -n "$nr p" "${file_tmp}"`
echo "SEDp0='$SEDp0'"
SEDp1=`cat "${foot}"`
echo "SEDp1='$SEDp1'"
#encoding_func "${file_tmp}".$nr.foot "${file_tmp}".head
#encoding_func "${file_tmp}".$nr.foot "${file_tmp}".body
#sed -i "$nr s,${SEDp0},${SEDp1}," "${file_tmp}".body
sed -i "$nr s,${SEDp0},${SEDp1}," "${file_tmp}"
done
fi


cp "${file_tmp}" "${converted_file}"
cp "$0" "${TARGET_MAIN_DIR}/${part_dirname_file_to_conv}/"
rm -f "${TMP_DIR}"/sed*
cat "${TMP_DIR}"/*.ERR >> "${TMP_DIR}"/html2txt.errs
#rm -f "${TMP_DIR}"/"${file_body}"*

#custom cleanup
LL=`grep -n 'zum Seitenanfang' "${converted_file}" |cut -f1 -d':'`
KEEP=`head -n $LL "${converted_file}"`
$ECHO "$KEEP" |sed '/^$/d' > "${converted_file}"

sed -i 's#Nichtamtliches Inhaltsverzeichnis##' "${converted_file}"
[ "$?" != 0 ] && exit
sed -i 's#zum Seitenanfang##' "${converted_file}"
[ "$?" != 0 ] && exit

#end custom cleanup

#update status
sed -i "${linenr} s/-ORIG-/-CONVERTED-/" "${DATABASE_MAIN}"
[ "$?" != 0 ] && exit
rm -f "${TARGET_MAIN_DIR}"/sed*
sleep 2s
echo "Finished '${converted_file}'"
done

#cp "${file_tmp}" "${converted_file}"
echo "Finished $0"




























simple_dir_function(){
HTMLfile=`ls -1| grep '\.htm$'`
HTMLfile=`echo "${HTMLfile}" | head -n1`
file_body="${HTMLfile%.*}"
echo "$file_body"

file_tmp="${WK_DIR}/${file_body}.txt"

rm -f "$file_body".txt
cat "${HTMLfile}" | sed 's#<#\n<#g;s#>#>\n#g' >"$file_body".txt

TAGS='<!DOCTYPE.*>,<html.*>,<[/""]html>,<head>,<[/""]head>,<meta.*>,<title>,<[/""]title>,<link.*>,<body>,<[/""]body>,<a.*>,</a>,<div.*>,</div>,<img.*>,<h[0-9]>,<[/""]h[0-9]>,<span.*>,</span>,<script.*>,<[/""]noscript>,'

echo "$TAGS" | sed 's#,#\n#g' |while read tag;do echo $tag >&2;
sed -i "s~${tag}~~" "$file_body".txt
done

PROG_DIR=`dirname $(dirname $0)`
SPECIALS_DIR="${PROG_DIR}/html2txt"
SPECIALS_FILE="${SPECIALS_DIR}/sonderzeichen.txt"

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
}

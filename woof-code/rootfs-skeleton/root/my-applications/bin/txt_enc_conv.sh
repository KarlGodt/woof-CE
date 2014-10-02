#!/bin/bash

ICONV_BIN=`which iconv`

WANTED_ENCODING=`echo "$@" | tr ' ' '\n' | grep -v '^\-'|tail -n1`
echo "WANTED_ENCODING='$WANTED_ENCODING'"

usage(){
echo "
$0 ENCODING

Wrapper for '$ICONV_BIN'
Finds all .txt files in current directory
and converts the detected encoding to
the given ENCODING .

Options :
-i) interactive .
-l) list available encodings .
-c) omit invalid characters from output .
-v) verbose output .
"
exit $1
}

while getopts licv opt;do
case $opt in
c) OMIT_INVALID='-c';;
i) INTERACTIVE='1';;
l) iconv -l >/tmp/iconv.out
cat /tmp/iconv.out | tr -d ','| tr ' ' '\n' >/tmp/iconv.lst
cat /tmp/iconv.lst | tr -d '/'| sort -u >/tmp/iconv.srt
cat /tmp/iconv.srt

exit 0
;;
v) VERBOSE='-v';LONG_VERBOSE='--verbose';;
*):;;
esac;done

if [ ! "$ICONV_BIN"  ];then
ICONV_BIN='iconv: Hmmm... apparently not installed'
usage 1
fi

if [ ! "$WANTED_ENCODING" ];then
usage 1
fi

if [ ! "`iconv -l| grep -wi "$WANTED_ENCODING"`" ];then
echo "Hmmm... seems '$WANTED_ENCODING' not supported"
usage 1
fi

TXT_FILES=`ls -1 | grep '\.txt$'`
if [ ! "$TXT_FILES" ];then
echo "Sorry , no *.txt files found in
`pwd`"
exit $?
fi

for txtfile in $TXT_FILES;do
echo "
Found '$txtfile'"
CHARDET_file=`chardet "$txtfile"`
echo "$CHARDET_file"
CURRENT_ENCODING=`echo "$CHARDET_file" |cut -f2 -d':' |awk '{print $1}'`
echo "CURRENT_ENCODING='$CURRENT_ENCODING'"
if [ "$INTERACTIVE" ];then
read -n1 -p "[Yy]es or skip? " YES_SKIP_KEY
case "$YES_SKIP_KEY" in
y|Y):;;
""|*)continue;;
esac;fi
file_base="${txtfile%\.txt}" #doesnt like \.txt$
echo "file_base='$file_base'"
cp "$txtfile" "${file_base}.${CURRENT_ENCODING}.txt"
iconv $OMIT_INVALID $LONG_VERBOSE -f "$CURRENT_ENCODING" -t "$WANTED_ENCODING" -o "${file_base}.${WANTED_ENCODING}.txt" "$txtfile"
sleep 1s
done








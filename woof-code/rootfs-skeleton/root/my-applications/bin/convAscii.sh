#!/bin/sh


usage(){
echo "USAGE :
$0

Usage message triggered by
$2
"
exit $1
}

#checks
[ "$1" ] || usage 1 "Requires filename to convert ."
[ -f "$1" ] || usage 1 "$1 not a file ."
[ "`which ascii`" ] || usage 1 "ascii binary not found in PATH ."
tmp='/tmp/asciiconvert'
mkdir -p "$tmp"

#prepare databáse
ascii | grep -A99 '^Dec' >"$tmp/asciitable.0.txt"
cat "$tmp/asciitable.0.txt" | sed 's/^[[:blank:]]*//g' >"$tmp/asciitable.1.txt"
cat "$tmp/asciitable.1.txt" | sed 's/Hex/Hex Char/g' >"$tmp/asciitable.1.1.txt"
cat "$tmp/asciitable.1.1.txt" | sed 's/20   /20 SP/' >"$tmp/asciitable.2.txt"
cat "$tmp/asciitable.2.txt" | tr -s ' ' >"$tmp/asciitable.3.txt"
cat "$tmp/asciitable.3.txt" | cut -f 1-3 -d ' ' >"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 4-6 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 7-9 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 10-12 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 13-15 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 16-18 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 19-21 -d ' ' >>"$tmp/asciitable.4.txt"
cat "$tmp/asciitable.3.txt" | cut -f 22-24 -d ' ' >>"$tmp/asciitable.4.txt"

#hexdump wanted file
rm -f "$tmp"/hex*
hexdump -C "$1" >"$tmp/hexdump.0.txt"
cat "$tmp/hexdump.0.txt" | tr -s ' ' >"$tmp/hexdump.0.1.txt"
cat "$tmp/hexdump.0.1.txt" | cut -f 2-17 -d ' ' >"$tmp/hexdump.1.txt"
cat "$tmp/hexdump.1.txt" | sed 's/^\([0-9]\{8\}\)//g' >"$tmp/hexdump.2.txt"

hexdump_lines=`cat "$tmp/hexdump.2.txt" | wc -l`
for line in `seq 1 1 $hexdump_lines`; do
#sed -n "$line p" "$tmp/hexdump.2.txt" | tr -d ' ' >>"$tmp/hexdump.3.txt"
#tail -n 1 "$tmp/hexdump.3.txt" | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1|\2|\3|\4|\5|\6|\7|\8|\9|\10|\"11"|\"12"|\"13"|\"14"|\"15"|\"16"/' >>"$tmp/hexdump.4.txt"
sed -n "$line p" "$tmp/hexdump.2.txt" | sed 's/\([0-9a-f][0-9a-f]\)/\1 /g' >>"$tmp/hexdump.3.txt"
tail -n 1 "$tmp/hexdump.3.txt" | tr -s ' ' >>"$tmp/hexdump.4.txt"
done
rm -f "$tmp/output.txt"
hexdump_lines=`cat "$tmp/hexdump.4.txt" | wc -l`
for line in `seq 1 1 $hexdump_lines`; do
sed -n "$line p" "$tmp/hexdump.4.txt" | while read s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16; do
grep -m2 -i -w -e "^[0-9]* $s1" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s2" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s3" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s4" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s5" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s6" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s7" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s8" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s9" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s10" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s11" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s12" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s13" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s14" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s15" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
grep -m2 -i -w -e "^[0-9]* $s16" "$tmp/asciitable.4.txt" | cut -f 3 -d ' ' >>"$tmp/output.txt"
done
done

rm -f "$tmp"/final*
output_lines=`cat "$tmp/output.txt" | wc -l`
for line in `seq 1 1 $output_lines`; do
sed -n "$line p" "$tmp/output.txt" | while read sign ; do
case $sign in
SP)echo -n ' ' >>"$tmp/final.0.txt";;
LF)echo >>"$tmp/final.0.txt";;
*)echo -n "$sign" >>"$tmp/final.0.txt";;
esac
done
done

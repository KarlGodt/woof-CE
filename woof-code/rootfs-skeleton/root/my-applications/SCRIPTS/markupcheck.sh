P='<b>.*</b>'
P1=`echo "$P" |sed 's%\(.\)%\1\.\*%g'`
echo "$P1"
<.*b.*>.*..**.*<.*/.*b.*>.*
grep -o "$P1" *.po | grep -v "$P"
#<b>Teknisk set</ b> \n"
#<b> Advarsel </ b> \n"

MPDB="<b>.*</b>
<u>.*</u>
<i>.*</i>
"

MPDBNOT=`echo "$MPDB" |tr -d '[[:blank:]]' |tr '\n' '|' |sed 's%^|*%%;s%|*$%%'`


while read P; do
[ "$P" ] || continue;
P1=`echo "$P" | sed 's%\(.\)%\.\*\1\.\*%g'`;
grep -o "$P1" *.po | grep -v "$P";
done<<EOI
$(echo "$MPDB")
EOI


while read P; do
echo "P=$P'"
[ "$P" ] || continue;
#P1=`echo "$P" | sed 's%\(.\)%\.\*\1\.\*%g'`; ##doesn't work for me
P1=`echo "$P" | sed 's%\(.\)%\1\.\*%g'`;
echo "P1=$P1'"
grep -o "$P1" *.po | grep -v "$P" | grep -vE "$MPDBNOT";
done<<EOI
$(echo "$MPDB")
EOI

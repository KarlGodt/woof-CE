#!/bin/sh
###KRG
###wrapper to write selected font to
###$HOME/.Xresources

[ -f $HOME/.Xresources ] && cp -f $HOME/.Xresources /tmp

xfontsel -print > /tmp/xfontsel.txt

LINE=`cat /tmp/xfontsel.txt | tail -n 1`
GREPLINE=`echo "$LINE" | sed 's#\-#\\\-#g ; s#\*#\\\*#g'`
echo LINE="$LINE"
echo GREPLINE="$GREPLINE"

if [ ! -f /tmp/.Xresources ] ; then
echo '*font: '"$LINE" > /tmp/.Xresources
defaulttexteditor /tmp/.Xresources
#exit
fi

LINEHOMEXRES=
LINEHOMEXRESNEW=
OLDCURRENTFONT=
COMMENTOLDFONT=

if [ -n "`grep "$GREPLINE" /tmp/.Xresources`" ] ; then
echo "$0 : found ' $GREPLINE ' in /tmp/.Xresources"
if [ -n "`grep "$GREPLINE" /tmp/.Xresources | grep -v '^\*'`" ] ; then
echo "$0 : ' $GREPLINE ' already in /tmp/.Xresources but commented"

LINEHOMEXRES=`grep "$GREPLINE" /tmp/.Xresources | head -n 1 | sed 's%\!%\\\!% ; s%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`
LINEHOMEXRESNEW=`echo "$LINEHOMEXRES" | sed 's/^\\\!//'`
echo LINEHOMEXRES="$LINEHOMEXRES"
echo LINEHOMEXRESNEW="$LINEHOMEXRESNEW"

grep '^\*font\:\ ' /tmp/.Xresources | while read l ; do
LINEOLD="`echo "$l" | sed 's%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`"
LINENEW="`echo "$LINEOLD" | sed 's/^/\\\!/'`"
echo LINEOLD="$LINEOLD"
echo LINENEW="$LINENEW"
sed -i "s/$LINEOLD/$LINENEW/" /tmp/.Xresources
done

sed -i "s/$LINEHOMEXRES/$LINEHOMEXRESNEW/" /tmp/.Xresources
defaulttexteditor /tmp/.Xresources
cp -f /tmp/.Xresources $HOME
rm /tmp/.Xresources
exit
fi
else
echo "$0 : ' $GREPLINE ' new for $HOME/.Xresources"

OLDCURRENTFONT=`grep '^\*font\:\ ' /tmp/.Xresources | head -n 1 | sed 's%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`
COMMENTOLDFONT=`echo "$OLDCURRENTFONT" | sed 's%^%\\\!%'`

echo OLDCURRENTFONT="$OLDCURRENTFONT"
echo COMMENTOLDFONT="$COMMENTOLDFONT"

sed -i "s/$OLDCURRENTFONT/$COMMENTOLDFONT/" /tmp/.Xresources

echo '*font: '"$LINE" >> /tmp/.Xresources
cp -f /tmp/.Xresources $HOME
rm /tmp/.Xresources
fi

DTE=`cat $(which defaulttexteditor) | grep -o 'exec.*' | cut -f 2-99 -d ' ' | cut -f 1 -d '"' | cut -f 1 -d ' '`
if [ "$DTE" = "geany" ] ; then
if [ -n "`pidof geany`" ] ; then
geany $HOME/.Xresources
else
geany -i $HOME/.Xresources &
fi
fi


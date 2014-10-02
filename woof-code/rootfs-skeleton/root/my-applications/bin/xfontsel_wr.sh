#!/bin/sh
###KRG
###wrapper to write selected font to
###$HOME/.Xresources

xfontsel -print > /tmp/xfontsel.txt

LINE=`cat /tmp/xfontsel.txt | tail -n 1`
GREPLINE=`echo "$LINE" | sed 's#\-#\\\-#g ; s#\*#\\\*#g'`
echo LINE="$LINE"
echo GREPLINE="$GREPLINE"
##if [ ! -f $HOME/.Xresources ] ; then
##echo '*font: '"$LINE" > $HOME/.Xresources
##defaulttexteditor $HOME/.Xresources
##exit
##fi

if [ ! -f /tmp/.Xresources ] ; then
echo '*font: '"$LINE" > /tmp/.Xresources
defaulttexteditor /tmp/.Xresources
exit
fi

LINEHOMEXRES=
LINEHOMEXRESNEW=
OLDCURRENTFONT=
COMMENTOLDFONT=
##if [ -n "`grep "$GREPLINE" $HOME/.Xresources`" ] ; then
##if [ -n "`grep "$GREPLINE" $HOME/.Xresources | grep -v '^\*'`" ] ; then
if [ -n "`grep "$GREPLINE" /tmp/.Xresources`" ] ; then
echo 31
if [ -n "`grep "$GREPLINE" /tmp/.Xresources | grep -v '^\*'`" ] ; then
echo 32
##LINEHOMEXRES=`grep "$GREPLINE" $HOME/.Xresources`
LINEHOMEXRES=`grep "$GREPLINE" /tmp/.Xresources | head -n 1 | sed 's%\!%\\\!% ; s%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`
LINEHOMEXRESNEW=`echo "$LINEHOMEXRES" | sed 's/^\\\!//'`
echo LINEHOMEXRES="$LINEHOMEXRES"
echo LINEHOMEXRESNEW="$LINEHOMEXRESNEW"

##sed -i "s/$LINEHOMEXRES/$LINEHOMEXRESNEW/" $HOME/.Xresources
##defaulttexteditor $HOME/.Xresources
grep '^\*font\:\ ' /tmp/.Xresources | while read l ; do
LINEOLD="`echo "$l" | sed 's%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`"
LINENEW="`echo "$LINEOLD" | sed 's/^/\\\!/'`"
echo LINEOLD="$LINEOLD"
echo LINENEW="$LINENEW"
sed -i "s/$LINEOLD/$LINENEW/" /tmp/.Xresources
done 


sed -i "s/$LINEHOMEXRES/$LINEHOMEXRESNEW/" /tmp/.Xresources
defaulttexteditor /tmp/.Xresources

exit
fi
echo 'anything other'
else
echo 47
##OLDCURRENTFONT=`grep '^\*font\:\ ' $HOME/.Xresources | head -n 1 | sed 's%^%\\\!% ; s%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`
OLDCURRENTFONT=`grep '^\*font\:\ ' /tmp/.Xresources | head -n 1 | sed 's%\-%\\\-%g ; s#\*#\\\*#g ; s%\ %\\\ % ; s%\:%\\\:%'`
COMMENTOLDFONT=`echo "$OLDCURRENTFONT" | sed 's%^%\\\!%'` 

echo OLDCURRENTFONT="$OLDCURRENTFONT"
echo COMMENTOLDFONT="$COMMENTOLDFONT"

##sed -i "s/$OLDCURRENTFONT/$COMMENTOLDFONT/" $HOME/.Xresources 
sed -i "s/$OLDCURRENTFONT/$COMMENTOLDFONT/" /tmp/.Xresources 

##SEDLINE="$GREPLINE"
#echo SEDLINE="$SEDLINE"

##echo '*font: '"$LINE" >> $HOME/.Xresources
echo '*font: '"$LINE" >> /tmp/.Xresources
fi

##defaulttexteditor $HOME/.Xresources
##defaulttexteditor /tmp/.Xresources
DTE=`cat $(which defaulttexteditor) | grep -o 'exec.*' | cut -f 2-99 -d ' ' | cut -f 1 -d '"' | cut -f 1 -d ' '`
if [ "$DTE" = "geany" ] ; then
if [ -n "`pidof geany`" ] ; then
##geany $HOME/.Xresources
geany /tmp/.Xresources
else
##geany -i $HOME/.Xresources &
geany -i /tmp/.Xresources &
fi
fi


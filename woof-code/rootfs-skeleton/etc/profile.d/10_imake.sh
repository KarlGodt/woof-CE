#!/bin/sh

[ "$DEBUG" ] || DEBUG=`grep -iw 'debug' /proc/cmdline`

IMAKEINCLUD=/usr/X11R7/lib/X11/config
if [ -d $IMAKEINCLUD ];then
 if [ -f $IMAKEINCLUD/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/X11R7/lib/X11/config
 else
  echo "WARNING: $IMAKEINCLUD exist but no file Imake.tmpl"
 fi
elif [ -d /usr/local/lib/X11/config ];then
 if [ -f /usr/local/lib/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/local/lib/X11/config
 else
  echo "WARNING:  /usr/local/lib/X11/config exist but no file Imake.tmpl"
 fi
elif [ -d /usr/share/X11/config ];then
 if [ -f /usr/share/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE= /usr/share/X11/config
 else
  echo "WARNING: /usr/share/X11/config  exist but no file Imake.tmpl"
 fi
elif [ -d /usr/lib/X11/config ];then
 if [ -f /usr/lib/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/lib/X11/config
 else
  echo "WARNING: /usr/lib/X11/config exists but no file Imake.tmpl"
 fi
else
 IMAKEINCLUDE=''
 echo "ERROR: IMAKEINCLUDE variable could not been set"
fi

if [ "$IMAKEINCLUDE" ];then
[ "$DEBUG" ] &&  echo "Exporting IMAKEINCLUDE='-I$IMAKEINCLUDE'"
 export IMAKEINCLUDE="-I$IMAKEINCLUDE"
else
 echo "ERROR : could not export IMAKEINCLUDE"
fi


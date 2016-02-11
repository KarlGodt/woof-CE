#!/bin/ash

#[ "$DEBUG" ] || DEBUG=`grep -iw 'debug' /proc/cmdline`
. /etc/rc.d/f4puppy5

IMAKEINCLUD=/usr/X11R7/lib/X11/config
if [ -d "$IMAKEINCLUD" ];then
 if [ -f "$IMAKEINCLUD"/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/X11R7/lib/X11/config
 else
  _warn "$IMAKEINCLUD exist as directory, but no file Imake.tmpl"
 fi
elif [ -d /usr/local/lib/X11/config ];then
 if [ -f /usr/local/lib/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/local/lib/X11/config
 else
  _warn "/usr/local/lib/X11/config exist but no file Imake.tmpl"
 fi
elif [ -d /usr/share/X11/config ];then
 if [ -f /usr/share/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE= /usr/share/X11/config
 else
  _warn "/usr/share/X11/config  exist but no file Imake.tmpl"
 fi
elif [ -d /usr/lib/X11/config ];then
 if [ -f /usr/lib/X11/config/Imake.tmpl ];then
  IMAKEINCLUDE=/usr/lib/X11/config
 else
  _warn "/usr/lib/X11/config exists but no file Imake.tmpl"
 fi
else
 IMAKEINCLUDE=''
 _warn "IMAKEINCLUDE variable could not been set"
fi

if [ "$IMAKEINCLUDE" ];then
_info "Exporting IMAKEINCLUDE='-I$IMAKEINCLUDE'"
 export IMAKEINCLUDE="-I$IMAKEINCLUDE"
else
 _warn "Could not export IMAKEINCLUDE"
fi


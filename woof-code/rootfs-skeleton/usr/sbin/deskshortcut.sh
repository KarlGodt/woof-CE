#!/bin/sh
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)
# This is very primitive script to create desktop shortcut.

FILENAME0=

FILENAME10=
FILENAME11=
FILENAME12=

FILENAME20=
FILENAME21=
FILENAME22=

FILENAME30=
FILENAME31=
FILENAME32=

FILENAME40=
FILENAME41=
FILENAME42=
FILENAME43=

FILENAME50=
FILENAME51=
FILENAME52=

  _TITLE_=deskshortcut
_VERSION_=1.0omega
_COMMENT_="Xdialog to create desktop shortcut."

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
 set +e
 source /etc/rc.d/f4puppy5 && {
 set +n
 source /etc/rc.d/f4puppy5; } || echo "WARNING : Could not source /etc/rc.d/f4puyppy5 ."

ADD_PARAMETER_LIST=
ADD_PARAMETERS=
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
for i in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
} || echo "Warning : No /etc/rc.d/f4puppy5 installed."

while [ 1 ]
do

RETSTR=`Xdialog --wmclass "desktopshortcut" --title "Create desktop shortcut" --stdout --left --separator "|" --2inputsbox "This is a very primitive script to create a shortcut in the icon-block at the\nbottom-right of the screen. for CREATING SHORTCUTS ANYWHERE ON THE DESKTOP, DO\nNOT USE THIS SCRIPT -- INSTEAD, OPEN ROX, GO TO /usr/local/bin AND DRAG AN ICON\nONTO THE DESKTOP -- IT IS THAT SIMPLE.\n\nif you really want an icon in the icon-block, then keep going with this script,\nelse exit. An example entry is shown, but you have to type in your own.\nThis script will insert a line into $HOME/.fvwm95rc, and you then have to exit\nfrom X graphics mode to the prompt then restart X for the shortcut to become\nvisible. You have to manually delete the line in $HOME/.fvwm95rc to remove the\nshortcut.\n\nNote: you can find programs in /usr/local/bin. The pixmap filename\nmust be chosen from /usr/local/lib/X11/pixmaps folder." 0 0 "Program filename:" "skipstone" "Pixmap:" "nis24.xpm"`

RETVAL=$?
case $RETVAL in
 0) #ok
  PROGFILE=`echo -n "$RETSTR" | cut -f 1 -d "|"`
  PROGPIXMAP=`echo -n "$RETSTR" | cut -f 2 -d "|"`
  SEDSTUFF="s/SHORTCUTSSTART/SHORTCUTSSTART\n*FvwmButtons $PROGFILE $PROGPIXMAP Exec \"$PROGFILE\" $PROGFILE/g"
  cat $HOME/.fvwm95rc | sed -e "$SEDSTUFF" > /tmp/fvwm95rc
  sync
  mv -f $HOME/.fvwm95rc $HOME/.fvwm95rc.bak
  mv -f /tmp/fvwm95rc $HOME/.fvwm95rc
  sync
  break
  ;;
 1) #cancel
  break
  ;;
 2) #help
  ;;
 *)
  break
  ;;
esac
done

# Very End of this file 'usr/sbin/deskshortcut.sh' #
###END###

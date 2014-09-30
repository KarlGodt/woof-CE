#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_mtpaintsnapshot.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/bin/mtpaintsnapshot.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap

}
# End new header
#
#Puppy Screenshot
# Trio Tj - GPL 2009

export Screenshot="	
<window title=\"Screenshot\">
	
  <frame      Please choose     >
  <pixmap><input file>/usr/share/pixmaps/gtkam.png</input></pixmap>
  <vbox>
   <button>
    <input file icon=\"gtk-refresh\"></input>
    <label>Wait 10 Sec</label>
	<action>(echo 10; sleep 1 ; echo 20; sleep 1 ; echo 30 ; sleep 1 ; echo 40; sleep 1 ; echo 50 ; sleep 1 ; echo 60 ; sleep 1 ; echo 70 ; sleep 1 ; echo 80 ; sleep 1 ; echo 90 ; sleep 1 ; echo 100 ) | Xdialog --title 'Puppy Screenshot' --beep-after --wrap --screen-center --center --no-buttons --gauge 'Please wait & prepare your screen ' 10 50 100 ; exec mtpaint -s &</action>
	<action>exit: Screenshot</action>
   </button>
   <button>
    <input file icon=\"gtk-apply\"></input>
    <label>  Now  </label>
    <action>exec mtpaint -s &</action>
	<action>exit: Screenshot</action>
   </button>
   <button>
    <input file icon=\"gtk-quit\"></input>
    <label>Quit</label>
   </button>
 </vbox>
 </frame>
</window>"

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog3 --program=Screenshot --center ); do
	eval $STATEMENTS
done
IFS=$I

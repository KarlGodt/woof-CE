#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_loadDefault.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/jwmconfig3/loadDefault.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in 1; do shift; done; }

_trap

}
# End new header
#
PRO="/loadDefault.sh"

########################################################################
#
#
#
#
#
# /dev/hda8:
# LABEL="MacPup431_O2"
# UUID="6d9a8e91-c301-4ff8-9875-97ec708cbee8"
# TYPE="ext3"
# DISTRO_NAME='Puppy'
# DISTRO_VERSION=431
# DISTRO_BINARY_COMPAT='puppy'
# DISTRO_FILE_PREFIX='pup'
# DISTRO_COMPAT_VERSION='4'
# PUPMODE=2
# KERNVER=2.6.37.4-KRG-i486-StagingDrivers-2
# PUP_HOME='/'
# SATADRIVES='�'
# USBDRIVES='�sda�'
# Linux�puppypc�2.6.37.4-KRG-i486-StagingDrivers-2�#4�SMP�Thu�Mar�17�06:05:58�GMT-8�2011�i686�GNU/Linux
# X�Window�System�Version�1.3.0
# Release�Date:�19�April�2007
# X�Protocol�Version�11,�Revision�0,�Release�1.3
# Build�Operating�System:�UNKNOWN�
# Current�Operating�System:�Linux�puppypc�2.6.37.4-KRG-i486-StagingDrivers-2�#4�SMP�Thu�Mar�17�06:05:58�GMT-8�2011�i686
# Build�Date:�28�November�2007
# $LANG=de_DE@euro
# today=So�30.�Okt�12:49:02�GMT+1�2011
#
#
#
#
#
########################################################################

SCRIPT_DIR="/usr/local/jwmconfig3"
. $SCRIPT_DIR/path


. $ColorFileDef

if [ -z "$MENU_BG" ]; then
 pidof jwm >/dev/null && jwm -restart
 exit 2
else 

. $SCRIPT_DIR/func -gradientcolors
 
. $SCRIPT_DIR/func -themedef
  
fi

echo "$DefTheme" > "$ThemeFile"

#########
#John Doe created code for the applet backgrounds, old jwmconfig, port here...
. $SCRIPT_DIR/func -trayapply 
#end John Doe's code.
########

sync
pidof jwm >/dev/null && jwm -restart
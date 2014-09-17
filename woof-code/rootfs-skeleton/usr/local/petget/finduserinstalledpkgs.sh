#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_finduserinstalledpkgs.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/finduserinstalledpkgs.sh"
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
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/pkg_chooser.sh
#find all pkgs that have been user-installed, format for display.

__old_header__(){  #BEGIN
###KRG Fr 31. Aug 23:34:58 GMT+1 2012

trap "exit 1" HUP INT QUIT KILL TERM

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x

Version='1.1'

usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
exit $1
}

[ "`echo "$1" | grep -wiE "help|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wiE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }

###KRG Fr 31. Aug 23:34:58 GMT+1 2012
}  ###__old_header__(){ #END

echo "$0:$*" >&2

#/root/.packages/usr-installed-packages has the list of installed pkgs...
touch /root/.packages/user-installed-packages
cut -f 1,10 -d '|' /root/.packages/user-installed-packages | sed '/^$/d' | sort -u > /tmp/installedpkgs.results


###END###

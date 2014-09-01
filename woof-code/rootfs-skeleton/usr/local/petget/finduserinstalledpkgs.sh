#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
# Called from /usr/local/petget/pkg_chooser.sh
# Find all pkgs that have been user-installed, format for display.

_TITLE_=find_installed_packages
_COMMENT_="Convert $HOME/.packages/user-installed-packages to installedpkgs.results"

MY_SELF="$0"

#************
#KRG

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x

Version=1.1-KRG-MacPup_O2

usage(){
MSG="
$0 [ help | version ]
"
echo "$MSG
$2"
exit $1
}
[ "`echo "$1" | grep -Ei "help|\-h"`" ] && usage 0
[ "`echo "$1" | grep -Ei "version|\-V"`" ] && { echo "$0: $Version";exit 0; }

trap "exit" HUP INT QUIT ABRT KILL TERM

#KRG
#************


echo "$0: START" >&2

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

#/root/.packages/usr-installed-packages has the list of installed pkgs...
touch /root/.packages/user-installed-packages
sort -u /root/.packages/user-installed-packages >"$tmpDIR"/installedpkgs.db
cp --remove-destination "$tmpDIR"/installedpkgs.db /root/.packages/user-installed-packages
cut -f 1,10 -d '|' /root/.packages/user-installed-packages |sed '/^$/d' |sort -u > "$tmpDIR"/installedpkgs.results
#cp -f "$tmpDIR"/installedpkgs.results /root/.packages/user-installed-packages
echo "$0: END" >&2
###END###

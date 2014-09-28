#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_findmissingpkgs.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"
MY_SELF="/usr/local/petget/findmissingpkgs.sh"
MY_PID=$$
test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5
ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }
_trap
}
# End new header
#
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
# Called from /usr/local/petget/installpreview.sh or check_deps.sh
# "$tmpDIR"/petget_pkg_name_aliases_patterns is written by pkg_chooser.sh.
# Passed param is a list of dependencies (DB_dependencies field of the pkg database).
# Results format, see comment end of this script.

__old_default_info_header__(){
_TITLE_=find_missing_packages
_COMMENT_="CLI to check for dependencies"
MY_SELF="$0"
#************
#KRG
OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x
Version=1.1-KRG-MacPup_O2
usage(){
MSG="
$0 [ help | version | DB_dependencies ]
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
}

echo "$0: START" >&2
DB_dependencies="$1" #in standard format of the package database, field 9.
. /etc/DISTRO_SPECS                 #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE
. /root/.packages/PKGS_MANAGEMENT   #has DISTRO_PPM_DEVX_EXCEPTIONS, PKG_ALIASES_INSTALLED
tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"
#need patterns of all installed pkgs...
if [ ! -f "$tmpDIR"/petget_installed_patterns_system ];then
 INSTALLED_PATTERNS_SYS=`cat /root/.packages/woof-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
 echo "$INSTALLED_PATTERNS_SYS" > "$tmpDIR"/petget_installed_patterns_system
 #PKGS_SPECS_TABLE also has system-installed names, some of them are generic combinations of pkgs...
 INSTALLED_PATTERNS_GEN=`echo "$PKGS_SPECS_TABLE" | grep '^yes' | cut -f 2 -d '|' |  sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
 echo "$INSTALLED_PATTERNS_GEN" >> "$tmpDIR"/petget_installed_patterns_system
 echo "$PKG_CAT_BuildingBlock" |tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g' >>"$tmpDIR"/petget_installed_patterns_system
 sync
 sort -u "$tmpDIR"/petget_installed_patterns_system > "$tmpDIR"/petget_installed_patterns_systemx
 mv -f "$tmpDIR"/petget_installed_patterns_systemx "$tmpDIR"/petget_installed_patterns_system
fi
[ "$DEBUG" ] && cat "$tmpDIR"/petget_installed_patterns_system | grep -E 'libz|zlib'
cp -f "$tmpDIR"/petget_installed_patterns_system "$tmpDIR"/petget_installed_patterns_all
INSTALLED_PATTERNS_USER=`cat /root/.packages/user-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
echo "$INSTALLED_PATTERNS_USER" >> "$tmpDIR"/petget_installed_patterns_all
#add these alias names to the installed patterns...
#ALIASES_PATTERNS=`echo -n "$PKG_ALIASES_INSTALLED" | tr -s ' ' | sed -e 's%^ %%' -e 's% $%%' | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
#echo "$ALIASES_PATTERNS" >> "$tmpDIR"/petget_installed_patterns_all
#packages may have different names, add them to installed list...
INSTALLEDALIASES=`grep --file="$tmpDIR"/petget_installed_patterns_all "$tmpDIR"/petget_pkg_name_aliases_patterns | tr ',' '\n'`
[ "$INSTALLEDALIASES" ] && echo "$INSTALLEDALIASES" >> "$tmpDIR"/petget_installed_patterns_all
#clean it up...
grep -v '^$' "$tmpDIR"/petget_installed_patterns_all > "$tmpDIR"/petget_installed_patterns_all-tmp
mv -f "$tmpDIR"/petget_installed_patterns_all-tmp "$tmpDIR"/petget_installed_patterns_all
[ "$DEBUG" ] && cat "$tmpDIR"/petget_installed_patterns_all | grep -E 'libz|zlib'
#make pkg deps into patterns...
PKGDEPS_PATTERNS=`echo -n "$DB_dependencies" | tr ',' '\n' | grep '^+' | sed -e 's%^+%%' -e 's%^%|%' -e 's%$%|%'`
echo "$PKGDEPS_PATTERNS" > "$tmpDIR"/petget_pkg_deps_patterns
[ "$DEBUG" ] && cat "$tmpDIR"/petget_pkg_deps_patterns | grep -E 'libz|zlib'
#remove installed pkgs from the list of dependencies...
MISSINGDEPS_PATTERNS=`grep --file="$tmpDIR"/petget_installed_patterns_all -v "$tmpDIR"/petget_pkg_deps_patterns | grep -v '^$'`
echo "$MISSINGDEPS_PATTERNS" > "$tmpDIR"/petget_missingpkgs_patterns #can be read by dependencies.sh, find_deps.sh.
[ "$DEBUG" ] && cat "$tmpDIR"/petget_missingpkgs_patterns | grep -E 'libz|zlib'
#notes on results:
#"$tmpDIR"/petget_missingpkgs_patterns has a list of missing dependencies, format ex:
#  |kdebase|
#  |delibs|
#  |mesa-lib|
#  |qt|
#"$tmpDIR"/petget_installed_patterns_all (read in dependencies.sh) has a list of already installed
#  packages, both builtin and user-installed. One on each line, exs:
#  |915resolution|
#  |a52dec|
#  |absvolume_puppy|
#  |alsa\-lib|
#  |cyrus\-sasl|
#  ...notice the '-' are backslashed.
echo "$0: END" >&2
###END###

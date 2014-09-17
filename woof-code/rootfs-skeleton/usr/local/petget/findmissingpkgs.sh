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
  for oneSHIFT in 1; do shift; done; }

_trap

}
# End new header
#
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
# Called from /usr/local/petget/installpreview.sh or check_deps.sh
# /tmp/petget_pkg_name_aliases_patterns is written by pkg_chooser.sh.
# Passed param is a list of dependencies (DB_dependencies field of the pkg database).
# Results format, see comment end of this script.


echo "$0:$*" >&2

DB_dependencies="$1" #in standard format of the package database, field 9.

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE
. /root/.packages/PKGS_MANAGEMENT #has DISTRO_PPM_DEVX_EXCEPTIONS, PKG_ALIASES_INSTALLED

#need patterns of all installed pkgs...
if [ ! -f /tmp/petget_installed_patterns_system ];then
 INSTALLED_PATTERNS_SYS=`cat /root/.packages/woof-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
 echo "$INSTALLED_PATTERNS_SYS" > /tmp/petget_installed_patterns_system
 #PKGS_SPECS_TABLE also has system-installed names, some of them are generic combinations of pkgs...
 INSTALLED_PATTERNS_GEN=`echo "$PKGS_SPECS_TABLE" | grep '^yes' | cut -f 2 -d '|' |  sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
 echo "$INSTALLED_PATTERNS_GEN" >> /tmp/petget_installed_patterns_system
 sort -u /tmp/petget_installed_patterns_system > /tmp/petget_installed_patterns_systemx
 mv -f /tmp/petget_installed_patterns_systemx /tmp/petget_installed_patterns_system
fi
cp -f /tmp/petget_installed_patterns_system /tmp/petget_installed_patterns_all
INSTALLED_PATTERNS_USER=`cat /root/.packages/user-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
echo "$INSTALLED_PATTERNS_USER" >> /tmp/petget_installed_patterns_all

#add these alias names to the installed patterns...
#ALIASES_PATTERNS=`echo -n "$PKG_ALIASES_INSTALLED" | tr -s ' ' | sed -e 's%^ %%' -e 's% $%%' | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`
#echo "$ALIASES_PATTERNS" >> /tmp/petget_installed_patterns_all
#packages may have different names, add them to installed list...
INSTALLEDALIASES=`grep --file=/tmp/petget_installed_patterns_all /tmp/petget_pkg_name_aliases_patterns | tr ',' '\n'`
[ "$INSTALLEDALIASES" ] && echo "$INSTALLEDALIASES" >> /tmp/petget_installed_patterns_all

#clean it up...
grep -v '^$' /tmp/petget_installed_patterns_all > /tmp/petget_installed_patterns_all-tmp
mv -f /tmp/petget_installed_patterns_all-tmp /tmp/petget_installed_patterns_all

#make pkg deps into patterns...
PKGDEPS_PATTERNS=`echo -n "$DB_dependencies" | tr ',' '\n' | grep '^+' | sed -e 's%^+%%' -e 's%^%|%' -e 's%$%|%'`
echo "$PKGDEPS_PATTERNS" > /tmp/petget_pkg_deps_patterns

#remove installed pkgs from the list of dependencies...
MISSINGDEPS_PATTERNS=`grep --file=/tmp/petget_installed_patterns_all -v /tmp/petget_pkg_deps_patterns | grep -v '^$'`
echo "$MISSINGDEPS_PATTERNS" > /tmp/petget_missingpkgs_patterns #can be read by dependencies.sh, find_deps.sh.

#notes on results:
#/tmp/petget_missingpkgs_patterns has a list of missing dependencies, format ex:
#  |kdebase|
#  |delibs|
#  |mesa-lib|
#  |qt|
#/tmp/petget_installed_patterns_all (read in dependencies.sh) has a list of already installed
#  packages, both builtin and user-installed. One on each line, exs:
#  |915resolution|
#  |a52dec|
#  |absvolume_puppy|
#  |alsa\-lib|
#  |cyrus\-sasl|
#  ...notice the '-' are backslashed.


###END###

#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/installpreview.sh or check_deps.sh
#/tmp/PetGet/petget_pkg_name_aliases_patterns is written by pkg_chooser.sh.
#passed param is a list of dependencies (DB_dependencies field of the pkg database).
#results format, see comment end of this script.
#100126 handle PKG_NAME_IGNORE variable from file PKGS_MANAGEMENT.
#100711 fix handling of PKG_NAME_ALIASES variable (defined in PKGS_MANAGEMENT file).

DB_dependencies="$1" #in standard format of the package database, field 9.

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE
. /root/.packages/PKGS_MANAGEMENT #has DISTRO_PPM_DEVX_EXCEPTIONS, PKG_ALIASES_INSTALLED

#need patterns of all installed pkgs...
#100711 /tmp/PetGet/petget_installed_patterns_system is created in pkg_chooser.sh.
cp -f /tmp/PetGet/petget_installed_patterns_system /tmp/PetGet/petget_installed_patterns_all
INSTALLED_PATTERNS_USER="`cat /root/.packages/user-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`"
#INSTALLED_PATTERNS_USER="`cat /root/.packages/user-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%-%\\\\-%g'`"
echo "$INSTALLED_PATTERNS_USER" >> /tmp/PetGet/petget_installed_patterns_all

#add these alias names to the installed patterns...
#ALIASES_PATTERNS="`echo -n "$PKG_ALIASES_INSTALLED" | tr -s ' ' | sed -e 's%^ %%' -e 's% $%%' | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`"
#echo "$ALIASES_PATTERNS" >> /tmp/PetGet/petget_installed_patterns_all
#packages may have different names, add them to installed list...
INSTALLEDALIASES="`grep --file=/tmp/PetGet/petget_installed_patterns_all /tmp/PetGet/petget_pkg_name_aliases_patterns | tr ',' '\n'`"
[ "$INSTALLEDALIASES" ] && echo "$INSTALLEDALIASES" >> /tmp/PetGet/petget_installed_patterns_all

#100126 some names to ignore, as most likely already installed...
#/tmp/PetGet/petget_pkg_name_ignore_patterns is created in pkg_choose.sh
cat /tmp/PetGet/petget_pkg_name_ignore_patterns >> /tmp/PetGet/petget_installed_patterns_all

#clean it up...
grep -v '^$' /tmp/PetGet/petget_installed_patterns_all > /tmp/PetGet/petget_installed_patterns_all-tmp
mv -f /tmp/PetGet/petget_installed_patterns_all-tmp /tmp/PetGet/petget_installed_patterns_all

#make pkg deps into patterns...
PKGDEPS_PATTERNS="`echo -n "$DB_dependencies" | tr ',' '\n' | grep '^+' | sed -e 's%^+%%' -e 's%^%|%' -e 's%$%|%'`"
echo "$PKGDEPS_PATTERNS" > /tmp/PetGet/petget_pkg_deps_patterns

#remove installed pkgs from the list of dependencies...
MISSINGDEPS_PATTERNS="`grep --file=/tmp/PetGet/petget_installed_patterns_all -v /tmp/PetGet/petget_pkg_deps_patterns | grep -v '^$'`"
echo "$MISSINGDEPS_PATTERNS" > /tmp/PetGet/petget_missingpkgs_patterns #can be read by dependencies.sh, find_deps.sh.

#notes on results:
#/tmp/PetGet/petget_missingpkgs_patterns has a list of missing dependencies, format ex:
#  |kdebase|
#  |delibs|
#  |mesa-lib|
#  |qt|
#/tmp/PetGet/petget_installed_patterns_all (read in dependencies.sh) has a list of already installed
#  packages, both builtin and user-installed. One on each line, exs:
#  |915resolution|
#  |a52dec|
#  |absvolume_puppy|
#  |alsa\-lib|
#  |cyrus\-sasl|
#  ...notice the '-' are backslashed.


###END###

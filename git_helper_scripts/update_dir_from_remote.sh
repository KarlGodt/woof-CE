#!/bin/bash

# script to update all branches in
# current git dir on local machine
# from remote git repository.
# Variables set further down.

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR" || exit 3

VERSION=0.0.2

_check_if_already_running()
{
pidof -o $$ -o %PPID "${0##*/}" && {
        echo "Already running."
        exit 1
 }
return $?
}
_check_if_already_running

_check_for_terminal()
{
local MSG
MSG="Need a contolling terminal"
tty >/dev/null || {
echo -n "Pid of X server:"
pidof X && xmessage -br red "$MSG"; exit 2; } || {
echo "$MSG"; exit 2; }
return $?
}
#_check_for_terminal

_exit()
{
RV=$1
shift
echo "$*"
exit $1
}

trap "_exit 99 \"Caught Signal\"" INT KILL TERM

_version()
{
echo "$0:Version:$VERSION"
exit 0
}

_usage()
{
local USAGE_MSG RV
RV=$1
shift
USAGE_MSG="
$0 [ PARAMETERS ]

PARAMETERS :

NONE YET

--
$*
"
echo "$USAGE_MSG"

if test "$RV" != 0; then
_exit $RV "Try again. Good Luck!"
else
exit $RV
fi
return $?
}

__getopt()
{

#POSIXLY_CORRECT=    ##
#GETOPT_COMPATIBLE=  ##

GET_OPT=`busybox getopt \
      -a -l help,version \
      -o h,V \
      -s sh \
      "$*"`
test $? = 0 || _usage 2 "Wrong option."

set - "`echo "$GET_OPT" | sed "s^' '^'\n'^g"`"

while read oneOPTION
do
test "$oneOPTION" || continue
case $oneOPTION
in
*) :;;
esac
done<<EoI
`set`
EoI
set -
return $?
}

_getopts()
{
local oneOPTION
while getopts hV oneOPTION
do
case $oneOPTION
in
h) _usage 0;;
V) _version;;
*) :;;
esac
done
return $?
}

_get_argv()
{
local oneARG
for oneARG in $*
do
case $oneARG
in
-*help|help) _usage 0;;
-*version|version) _version;;
*) :;;
esac
done
return $?
}

_get_argv $*
_getopts $*


remoteNAME=KarlGodt_ForkWoof

dir_toUPDATE="KarlGodt_ForkWoof.Pull.d/"

cd "$dir_toUPDATE" || _exit 1 "Could not cd into $dir_toUPDATE"

branchALL=`git branch` || _exit 1 "Could not run 'git branch'"

branchALL=`echo "$branchALL" | sed 's/^\*//'`


while read oneBRANCH REST
do
test "$oneBRANCH" || continue
test "$oneBRANCH" = '*' && continue
test "$REST" && oneBRANCH="$REST"
git checkout "$oneBRANCH" || break

test "$oneBRANCH" = 'mavrothal-woof-CE-master'   && { remoteNAME=puppylinux-woof-CE; oneBRANCH=master; }
test "$oneBRANCH" = 'mavrothal-woof-CE-testing'  && { remoteNAME=puppylinux-woof-CE; oneBRANCH=testing; }
test "$oneBRANCH" = 'mavrothal-woof-CE-firmware' && { remoteNAME=puppylinux-woof-CE; oneBRANCH=firmware; }
git pull $remoteNAME $oneBRANCH
remoteNAME=KarlGodt_ForkWoof
sleep 1
done<<EoI
`echo "$branchALL"`
EoI






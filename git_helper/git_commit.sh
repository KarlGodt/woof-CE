#!/bin/sh
#
# script to use git status to check for unwatched
# and changed files
# in woof-code/ directory
# and interactively ask to add and commit them
#

test -f /etc/rc.d/f4puppy5 && source /etc/rc.d/f4puppy5


_usage(){
RV=${1:-0}
shift
EXTRA_MSG=`gettext "$*"`

MSG="
$0 :

# script to use git status to check for unwatched
# and changed files
# in woof-code/ directory
# and interactively ask to add and commit them
"

MSG=`gettext "$MSG"`
test "$EXTRA_MSG" && echo "$EXTRA_MSG
"
echo "$MSG
"

exit $RV
}

case $* in
-h|*help|*usage) _usage;;
esac


_cd_program_dir || exit 1

echo -n "pwd:"; pwd; # DEBUG

_DIR_="`pwd`/../../KarlGodt_ForkWoof.Push.D"

_test_d "$_DIR_" || _exit 1 "$_DIR_ does not seem to be a directory"

cd "$_DIR_"

#git commit | sed -n '/^# Unbeobachtete Dateien:/,/^#   woof-code/ p'

#git commit | grep '^#  woof-code'
#git commit | grep '^#' | grep -o 'woof-code.*'  #DEBUG
git status | grep '^#' | grep -o 'woof-code.*'  #DEBUG

#_FILES_=`git commit | grep '^#' | grep -o 'woof-code.*'`
_FILES_=`git status | grep '^#' | grep -o 'woof-code.*'`

#echo
for _oneFILE_ in $_FILES_
do
echo
echo "$_oneFILE_"

 unset _confirm_
 while true;
 do
 read -n1 -p "Do you want to commit this file ? (y/n)" _confirm_
 echo
 case $_confirm_ in
 y) git add "$_oneFILE_"
    git commit -m "$_oneFILE_ : Added."
    break
 ;;
 n) break;;
 *) continue;;
 esac
 sleep 0.1
 done

sleep 0.1
done


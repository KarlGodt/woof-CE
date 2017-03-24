#!/bin/ash
_say_help_msg(){
	cat >&1 <<EoI
# this script lists all uncommitted added and changed files
# in git repo dir _DIR_ in woof-code subdir
# and interactively asks to add commit them
EoI
}

case $* in -h|*help) _say_help_msg; exit 0;; esac

# override DEF_COMMIT_MSG with option line
DEF_COMMIT_MSG=${DEF_COMMIT_MSG:+"$*"}
# if I had no DEF_COMMIT_MSG set, use option line
DEF_COMMIT_MSG=${DEF_COMMIT_MSG:-"$*"}
# if I had no option line and no DEF_COMMIT_MSG
DEF_COMMIT_MSG=${DEF_COMMIT_MSG:-'Added.'}

test -f /etc/rc.d/f4puppy5 && source /etc/rc.d/f4puppy5

_cd_program_dir || exit 1

pwd

_DIR_="`pwd`/../../KarlGodt_ForkWoof.Push.D"

_test_d "$_DIR_" || _exit 1 "$_DIR_ does not seem to be a directory"

cd "$_DIR_"

#git commit | sed -n '/^# Unbeobachtete Dateien:/,/^#	woof-code/ p'

#git commit | grep '^#	woof-code'
#git commit | grep '^#' | grep -o 'woof-code.*'

git status
echo
git status | grep '^#' | grep -o 'woof-code.*'
#exit

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

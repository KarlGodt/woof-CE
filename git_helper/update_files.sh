#!/bin/ash

. /etc/rc.d/PUPSTATE
. /etc/DISTRO_SPECS
. /etc/rc.d/f4puppy5

_help(){
echo "$0:"
echo "find . -type f in cd ./woof-code/rootfs-skeleton in GIT"
echo "Either adds interactively to   SYSTEM if not there."
echo " Or removes interactively from GIT    if not added to SYSTEM."
echo "diff -qs both files AND continues if zero return value."
echo "Asks to add to GIT or to SYSTEM."
echo
echo "TODO: AUTO_UPDATE_GIT variable"
exit 0
}

case $1 in ''):;;*) _help;;esac

ME_PROG=`realpath "$0"`
ME_DIR="${ME_PROG%/*}"
cd "$ME_DIR" || exit 4

# global variables:
AUTO_UPDATE_GIT=

# Am I at the right branch ?
BRANCH=Opera2-Dell755
git branch | grep '^\*' | grep $Q -Fw "$BRANCH" || exit 5


cd .././woof-code/rootfs-skeleton || exit 6
pwd

TTY=`tty`
[ "$TTY" == "not a tty" ] && exit 7

test -f "$ME_DIR"/skip_files.lst || touch "$ME_DIR"/skip_files.lst

while read oneGITF
do

test "$oneGITF" || break
_info "$oneGITF"

oneOSF=${oneGITF#*.}
_debug "$oneOSF"

test -e "$oneOSF" || {
    # REM: What to do if Files does not exist...
    echo "$oneOSF does not exist"
    #sleep 1

    echo "Shall it be added to the OS (y|n) "
    read confirmKEZ0 <$TTY
    _debugx confirmKEZ0=$confirmKEZ0

    case $confirmKEZ0 in

    # copy file into OS
    Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir $VERB -p "${oneOSF%/*}"
     cp $VERB -a "$oneGITF" "$oneOSF" || break
;;

    # ask to remove file from git repository (.gitignore and such)
    N|n|No|NO|no)
     echo "Shall it be removed out of the git repository (y|n) "
     read confirmKEZ1 <$TTY
     _debugx confirmKEZ1=$confirmKEZ1

     case $confirmKEZ1 in
     # run git rm and git commit
     Y|y|Yes|YES|yes)
        git rm "$oneGITF"                 || break
        git commit -m "$oneOSF: Removed." || break
     ;;

     # do nothing ...
     N|n|No|NO|no)
        if ! grep $Q "$oneOSF"    "$ME_DIR"/skip_files.lst; then
                echo "$oneOSF" >> "$ME_DIR"/skip_files.lst
        fi
      ;;
     *) echo UNHANDLED $confirmKEZ1;;
     esac
;;
*) echo UNHANDLED $confirmKEZ0
     ;;
    esac

    continue
}


#echo OK files are there .. comparing -ot older than ...
#test "$oneGITF" -ot "$oneOSF" || continue

 echo OK files are there .. comparing -nt newer or -ot older than ...
 test "$oneOSF" -nt "$oneGITF" || test "$oneOSF" -ot "$oneGITF" || continue

 echo OK files are there .. comparing diff ...
 test -L "$oneGITF" && _warn "File in GIT is a LINK"
 test -L "$oneOSF"  && _warn "File in OS  is a LINK"
 diff -qs "$oneGITF" "$oneOSF" && { touch "$oneGITF" "$oneOSF"; continue; }


# ignore some file types ...
case $oneGITF in
*.gz|*.xpm|*.png|*.jpg|*.svg|*.afm|*.pfb|*.ttf|*.au|*.wav|*.ogg|fonts.*|*.pcf|*.so|*.so.conf|yaf-splash*)
continue
;;
esac

diff -up "$oneGITF" "$oneOSF" >/tmp/diff.diff
geany /tmp/diff.diff &

#echo "Shall the file in OS be replaced by the git file (y|n) "
echo "Shall the file in GIT be replaced by the OS file (y|n) "
read confirmKEZ2 <$TTY
_debugx confirmKEZ2=$confirmKEZ2

__update_os__(){
    # copy file into OS
    #Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir $VERB -p "${oneOSF%/*}"
     cp $VERB -a "$oneGITF" "$oneOSF"
}

__update_git__(){
    # copy OS file into git
    #Y|y|Yes|YES|yes)
     rm $VERB "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir $VERB -p "${oneGITF%/*}"
     cp $VERB -a  "$oneOSF" "$oneGITF" || break

     # update git
     git add "$oneGITF" || break

     if test "$AUTO_UPDATE_GIT"; then
      git commit -m "$oneOSF: Replaced by the one found in the system" || break
     else
      GIT_EDITOR='geany -i' git commit
     fi

}

case $confirmKEZ2 in


    # copy OS file into git
    Y|y|Yes|YES|yes)
     rm $VERB "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir $VERB -p "${oneGITF%/*}"
     cp $VERB -a  "$oneOSF" "$oneGITF" || break

     # update git
     git add "$oneGITF" || break

     if test "$AUTO_UPDATE_GIT"; then
      git commit -m "$oneOSF: Replaced by the one found in the system" || break
     else
      GIT_EDITOR='geany -i' git commit
     fi

;;

    # else ask to replace file in the OS
    N|n|No|NO|no)

    echo "Shall the file in OS be replaced by the git file (y|n) "
    read confirmKEZ3 <$TTY
    _debugx confirmKEZ3=$confirmKEZ3

    case $confirmKEZ3 in

   Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir $VERB -p "${oneOSF%/*}"
     cp $VERB -a "$oneGITF" "$oneOSF"

    ;;

    N|n|No|NO|no) :;;
    *) echo UNHANDLED $confirmKEZ3;;
    esac
;;
*) echo UNHANDLED $confirmKEZ2
     ;;
esac



done <<EoI
`find . -type f`
EoI


#!/bin/ash

. /etc/rc.d/PUPSTATE
. /etc/DISTRO_SPECS
. /etc/rc.d/f4puppy5  # _warn

AUTO_COMMIT_MSG=${AUTO_COMMIT_MSG:-'Replaced by the one found in the system'}

_help(){
echo
echo "$0:"
echo "find . -type f in cd ./woof-code/rootfs-skeleton in GIT"
echo "Either adds interactively to   SYSTEM if not there."
echo " Or removes interactively from GIT    if not added to SYSTEM."
echo "diff -qs both files AND continues if zero return value."
echo "Asks to add to GIT or to SYSTEM."
echo
echo "Options:"
echo "-a --auto do not launch editor for commit message and use"
echo "          AUTO_COMMIT_MSG instead:"
echo "          $AUTO_COMMIT_MSG"
echo "-n --dry-run do not actually copy any files and do not add to git"
echo
exit 0
}

while [ "$1" ]; do
case $1 in ''):;;
-a|--auto)     AUTO_UPDATE_GIT=1;;
-n|--dry-run)  DRY_RUN=1;;
*) _help;;esac
shift
done

ME_PROG=`realpath "$0"`
ME_DIR="${ME_PROG%/*}"
cd "$ME_DIR" || exit 4

# global variables:
AUTO_UPDATE_GIT=${AUTO_UPDATE_GIT:-''}

# Am I at the right branch ?
#BRANCH=Fox3-Dell755
BRANCH=Fox3-GreatWallU310-KRGall
git branch | grep '^\*' | grep -Fw "$BRANCH" || exit 5


cd .././woof-code/rootfs-skeleton || exit 6
pwd # DEBUG

TTY=`tty`
[ "$TTY" == "not a tty" ] && exit 7

while read oneGITF
do

test "$oneGITF" || break
echo "$oneGITF"

oneOSF=${oneGITF#*.}
echo "$oneOSF"

test -e "$oneOSF" || {
    # REM: What to do if Files does not exist...
    echo "$oneOSF does not exist"
    #sleep 1

    echo "Shall it be added to the OS (y|n) "
    read confirmKEZ0 <$TTY
    echo confirmKEZ0=$confirmKEZ0

    case $confirmKEZ0 in

    # copy file into OS
    Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF" || break
;;

    # ask to remove file from git repository (.gitignore and such)
    N|n|No|NO|no)
     echo "Shall it be removed out of the git repository (y|n) "
     read confirmKEZ1 <$TTY
     echo confirmKEZ1=$confirmKEZ1

     case $confirmKEZ1 in
     # run git rm and git commit
     Y|y|Yes|YES|yes)
        git rm "$oneGITF"                 || break
        git commit -m "$oneOSF: Removed." || break
     ;;

     # do nothing ...
     N|n|No|NO|no) ;;
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
_debug "Omitting '$oneGITF' .."
continue
;;
esac

diff -up "$oneGITF" "$oneOSF" >/tmp/diff.diff
geany /tmp/diff.diff &

#echo "Shall the file in OS be replaced by the git file (y|n) "
echo "Shall the file in GIT be replaced by the OS file (y|n) "
read confirmKEZ2 <$TTY
echo confirmKEZ2=$confirmKEZ2 #DEBUG

__update_os__(){
    # copy file into OS
    #Y|y|Yes|YES|yes)

    if test "$DRY_RUN"; then
     :
    else
     test -d "${oneOSF%/*}" || mkdir -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF"
    fi
}

__update_git__(){
    # copy OS file into git
    #Y|y|Yes|YES|yes)

    if test "$DRY_RUN"; then
     :
    else
     rm "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir -p "${oneGITF%/*}"
     cp -v -a  "$oneOSF" "$oneGITF" || break

     # update git
     git add "$oneGITF" || break

     if test "$AUTO_UPDATE_GIT"; then
      git commit -m "$oneOSF: $AUTO_COMMIT_MSG" || break
     else
      GIT_EDITOR='geany -i' git commit
     fi
    fi
}

case $confirmKEZ2 in


    # copy OS file into git
    Y|y|Yes|YES|yes)

    if test "$DRY_RUN"; then
     :
    else
     rm -v "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir -v -p "${oneGITF%/*}"
     cp -v -a  "$oneOSF" "$oneGITF" || break

     # update git
     git add "$oneGITF" || break

     if test "$AUTO_UPDATE_GIT"; then
      git commit -m "$oneOSF: $AUTO_COMMIT_MSG" || break
     else
      GIT_EDITOR='geany -i' git commit
     fi
    fi
;;

    # else ask to replace file in the OS
    N|n|No|NO|no)

    echo "Shall the file in OS be replaced by the git file (y|n) "
    read confirmKEZ3 <$TTY
    echo confirmKEZ3=$confirmKEZ3 # DEBUG

    case $confirmKEZ3 in

   Y|y|Yes|YES|yes)

    if test "$DRY_RUN"; then
     :
    else
     test -d "${oneOSF%/*}" || mkdir -v -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF"
    fi

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

###END###

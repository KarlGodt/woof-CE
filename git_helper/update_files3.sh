#!/bin/ash

# 2018-01-10 Added -D DIRECTORY
# positional parameter recognition

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
echo "Options:"
echo "-D DIRECTORY ie -d \$PWD"
echo "to just diff the files of a directory."
echo
echo "TODO: AUTO_UPDATE_GIT variable"
exit 0
}

case $1 in ''):;;
-D*) shift; DIR="$*";;
*) _help;;esac

DIR=${DIR:-'.'}

ME_PROG=`realpath "$0"`
ME_DIR="${ME_PROG%/*}"
cd "$ME_DIR" || exit 4

# global variables:
AUTO_UPDATE_GIT=

# Am I at the right branch ?
BRANCH=Fox3-Dell755
git branch | grep '^\*' | grep -Fw "$BRANCH" || exit 5


cd .././woof-code/rootfs-skeleton || exit 6
pwd

TTY=`tty`
[ "$TTY" == "not a tty" ] && exit 7

while read oneGITF
do

test "$oneGITF" || break
echo "$oneGITF"

case $oneGITF in
./*) oneOSF=${oneGITF#*.};;
*)   oneOSF=${oneGITF#*rootfs-skeleton};;
esac

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
continue
;;
esac

diff -up "$oneGITF" "$oneOSF" >/tmp/diff.diff
geany /tmp/diff.diff &

#echo "Shall the file in OS be replaced by the git file (y|n) "
echo "Shall the file in GIT be replaced by the OS file (y|n) "
read confirmKEZ2 <$TTY
echo confirmKEZ2=$confirmKEZ2

__update_os__(){
    # copy file into OS
    #Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF"
}

__update_git__(){
    # copy OS file into git
    #Y|y|Yes|YES|yes)
     rm "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir -p "${oneGITF%/*}"
     cp -v -a  "$oneOSF" "$oneGITF" || break

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
     rm -v "$oneGITF" || break
     test -d "${oneGITF%/*}" || mkdir -v -p "${oneGITF%/*}"
     cp -v -a  "$oneOSF" "$oneGITF" || break

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
    echo confirmKEZ3=$confirmKEZ3

    case $confirmKEZ3 in

   Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir -v -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF"

    ;;

    N|n|No|NO|no) :;;
    *) echo UNHANDLED $confirmKEZ3;;
    esac
;;
*) echo UNHANDLED $confirmKEZ2
     ;;
esac



done <<EoI
`find "$DIR" -type f`
EoI





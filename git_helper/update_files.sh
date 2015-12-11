#!/bin/ash

ME_PROG=`realpath "$0"`
ME_DIR="${ME_PROG%/*}"
cd "$ME_DIR" || { echo "cannot change into '$ME_DIR' ."; exit 4; }


# Am I at the right branch ?
BRANCH=Fox3-Dell745
git branch | grep '^\*' | grep -Fw "$BRANCH" || { echo "Wrong branch."; exit 5; }


cd ../woof-code/rootfs-skeleton || { echo "Could not change into ../woof-code/rootfs-skeleton ."; exit 6; }
pwd

TTY=`tty`
[ "$TTY" == "not a tty" ] && { echo "Need controlling terminal"; exit 7; }

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
    #echo confirmKEZ0=$confirmKEZ0

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
     #echo confirmKEZ1=$confirmKEZ1

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

echo OK files are there .. comparing ...
diff -qs "$oneGITF" "$oneOSF" && continue

#break

rm $VERB -f /tmp/diff.diff
diff -up "$oneGITF" "$oneOSF" >/tmp/diff.diff
sleep 1
geany /tmp/diff.diff &

echo "Shall the file in OS be replaced by the git file (y|n) "
read confirmKEZ2 <$TTY
#echo confirmKEZ2=$confirmKEZ2

case $confirmKEZ2 in

    # copy file into OS
    Y|y|Yes|YES|yes)
     test -d "${oneOSF%/*}" || mkdir -p "${oneOSF%/*}"
     cp -v -a "$oneGITF" "$oneOSF"
;;

    # ask to replace file in git repository
    N|n|No|NO|no)

    echo "Shall the file in GIT be replaced by the OS file (y|n) "
    read confirmKEZ3 <$TTY
    #echo confirmKEZ3=$confirmKEZ3

    case $confirmKEZ3 in

    # copy OS file into git
    Y|y|Yes|YES|yes)
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

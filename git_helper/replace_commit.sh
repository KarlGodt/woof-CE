#!/bin/ash

# this script runs find in
# _cd_program_dir ../woof-code/rootfs-skeleton
# and then _test_only_scripts
#     then test -e "$sysF"
#     then readlink -f "$oneF"
#     then case $oneF in *.~*)
# to filter out files that should not interest us now
#  then stat
#  then diff
# to filter further
# then  CREATE_CHECK_FILE
# then if DRY_RUN
# then  DO_UPDATE_GIT -o DO_UPDATE_SYSTEM
# finally _force_replace_files_in_git
#      or _update_git and _update_system
# NO OPTIONS PROCESSING FOR NOW,
# VARIABLES NEED TO BE SET MANUALLY HEREIN

. /etc/rc.d/f4puppy5

# DO_UPDATE_SYSTEM set to anything to replace system files with newer git files
[ "$DO_UPDATE_SYSTEM" ] || DO_UPDATE_SYSTEM=1
# FORCE_SYSTEM_REPLACE set to anything to replace system files with the git files
[ "$FORCE_SYSTEM_REPLACE" ] || FORCE_SYSTEM_REPLACE= #TODO

# DO_UPDATE_GIT set to anything to replace git files with newer system files
[ "$DO_UPDATE_GIT" ] || DO_UPDATE_GIT=1
# FORCE_GIT_REPLACE set to anything to replace git files with system files
[ "$FORCE_GIT_REPLACE" ] || FORCE_GIT_REPLACE=

# ONLY_SCRIPTS set to anything to ommit list of non-sh files
[ "$ONLY_SCRIPTS" ] || ONLY_SCRIPTS=1

# DRY_RUN set to anything to give usual test output but continue loop before copying anything
[ "$DRY_RUN" ] || DRY_RUN=

# CREATE_CHECK_FILE set to anything to write list to CHECK_LIST_FILE
[ "$CREATE_CHECK_FILE" ] || CREATE_CHECK_FILE=
CHECK_LIST_FILE="$HOME/git_check.lst"
rm $VERB -f "$CHECK_LIST_FILE"

pwd #DEBUG
_cd_program_dir || _exit 2 "Unable to change into this directory."
pwd #DEBUG
cd ../woof-code/rootfs-skeleton || _exit 1 "Could not cd into ../woof-code/rootfs-skeleton"
pwd   #DEBUG
#exit #DEBUG
sleep 5 #DEBUG

# ONLY_SCRIPTS # returns 1 if fileextension is non-script
_test_only_scripts(){
case $oneF in
*.xpm|*.svg|*.png|*.jpg|*.gif|*.DirIcon|*.gz|*.bz2|*.xz|*.ttf|*.pfb|*.afm|*.au|*.wav|*.mp3|*.ogg)
test "$ONLY_SCRIPTS" && return 1
;;
*issue*|*MODULESCONFIG*|*PUPSTATE*|*modprobe*|*/.bash*|*/.ash*|*history*)
test "$ONLY_SCRIPTS" && return 1
;;
esac
return 0
}

_update_git(){
if test "$modS" -gt "$modF"; then
 if test "$DO_UPDATE_GIT"; then

     dirG=".${sysF%/*}"
     mkdir $VERB -p "$dirG"

     /bin/cp $VERB -a -u --remove-destination --backup=numbered "$sysF" "$dirG"/
     if test "$?" = 0 ; then
      git add "$oneF" && git commit -m "$sysF: Maintanance update through ${0##*/} ." && sleep 5
     else
      echo "Failed replacing gitfile"
      exit 9
     fi
 fi
fi
}

_force_replace_files_in_git(){

 if test "$DO_UPDATE_GIT"; then

     dirG=".${sysF%/*}"
     mkdir $VERB -p "$dirG"

     /bin/cp $VERB -a --remove-destination --backup=numbered "$sysF" "$dirG"/
     if test "$?" = 0 ; then
      git add "$oneF" && git commit -m "$sysF: Maintanance update through ${0##*/} ."
     else
      echo "Failed replacing gitfile"
      echo "Exiting."
      exit 9
     fi
 fi

}

_update_system(){
if test "$modS" -lt "$modF"; then
 if test "$DO_UPDATE_SYSTEM"; then

    dirS=`echo "${oneF%/*}" | sed 's%^\.%%'`
    mkdir $VERB -p "$dirS"

    /bin/cp $VERB -a --remove-destination --backup=numbered "$oneF" "$dirS"/
 fi

fi
}

while read oneF
do
[ "$oneF" ] || continue
#echo
#echo "$oneF"
sysF=`echo "$oneF" | sed 's%.%%'`
#echo "$sysF"

# ONLY_SCRIPTS
#case $oneF in
#*.xpm|*.svg|*.png|*.jpg|*.gif|*.DirIcon|*.gz|*.bz2|*.xz|*.ttf|*.pfb|*.afm|*.au|*.wav|*.mp3|*.ogg)
#test "$ONLY_SCRIPTS" && continue
#;;
#esac
_test_only_scripts || continue

#echo
test -e "$sysF" || { echo "$sysF does not exist"; continue; }
readlink -f "$oneF" || { echo "$oneF may be broken (relative) Link"; continue; }
case $oneF in
*.~*) echo "$oneF is backup"; continue;;
esac

#echo "$sysF"

modF=`stat -c %Y "$oneF"`
modS=`stat -c %Y "$sysF"`

echo
if test "$modS" -gt "$modF"; then
 echo "sysfile mod later than gitfile"
elif test "$modS" -lt "$modF"; then
 echo "gitfile mod later than sysfile"
else
 echo "modtime of git and sysfile are same"
 continue
fi
echo "$oneF"
echo "$sysF"


#test "$CREATE_CHECK_FILE" && {
#(
#echo "$oneF"
#echo "$sysF"
#echo "gitfile mod later than sysfile"
#echo
#) >>"$CHECK_LIST_FILE"
#}

test -d "$oneF" || { diff -qs "$oneF" "$sysF" && continue; }

if test "$modS" -gt "$modF"; then
 test -d "$sysF" || echo "would update gitfile"
elif test "$modS" -lt "$modF"; then
 test -d "$oneF" || echo "would update sysfile"
else
 #echo "modtime of git and sysfile are same"
 continue
fi

test "$CREATE_CHECK_FILE" && {
(
echo "$oneF"
echo "$sysF"
if test "$modS" -gt "$modF"; then
 echo "would update gitfile"
elif test "$modS" -lt "$modF"; then
 echo "would update sysfile"
else
 echo "both have same modtime"
fi
echo
) >>"$CHECK_LIST_FILE"
}


test "$DRY_RUN" && continue

if test "$DO_UPDATE_GIT" -o "$DO_UPDATE_SYSTEM"; then
 :
else
 echo "DO_UPDATE_GIT or DO_UPDATE_SYSTEM not set, nothing to do."
 continue
fi

#test -d "$oneF" || _update_git

if test "$FORCE_GIT_REPLACE" ; then
 test -d "$oneF" || _force_replace_files_in_git
 continue
else
 test -d "$oneF" || _update_git
fi

test -d "oneF" || _update_system

#case $oneF in
#*.xpm|*.svg|*.png|*.jpg|*.gz|*.bz2|*.xz|*.ttf|*.pfb|*.afm)
#test "ONLY_SCRIPTS" && continue
#;;
#esac

sleep 1

echo
done <<EoI
`find -type f -o -type l`
EoI

#!/bin/ash

. /etc/rc.d/f4puppy5

DO_UPDATE_SYSTEM=
DO_UPDATE_GIT=1
FORCE_GIT_REPLACE=
ONLY_SCRIPTS=1
DRY_RUN=
CREATE_CHECK_FILE=
CHECK_LIST_FILE="$HOME/git_check.lst"
rm -f "$CHECK_LIST_FILE"

cd woof-code/rootfs-skeleton || _exit 1 "Could not cd into woof-code/rootfs-skeleton"


while read oneF
do
[ "$oneF" ] || continue
#echo
#echo "$oneF"
sysF=`echo "$oneF" | sed 's%.%%'`
#echo "$sysF"

case $oneF in
*.xpm|*.svg|*.png|*.jpg|*.gif|*.DirIcon|*.gz|*.bz2|*.xz|*.ttf|*.pfb|*.afm|*.au|*.wav|*.mp3|*.ogg)
test "$ONLY_SCRIPTS" && continue
;;
esac
#echo
test -e "$sysF" || { echo "$sysF does not exist"; continue; }
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
 echo "would update gitfile"
elif test "$modS" -lt "$modF"; then
 echo "would update sysfile"
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

_update_git(){
if test "$modS" -gt "$modF"; then
 if test "$DO_UPDATE_GIT"; then

	 dirG=".${sysF%/*}"
	 mkdir -p "$dirG"

	 /bin/cp -a --remove-destination --backup=numbered "$sysF" "$dirG"/
     if test "$?" = 0 ; then
      git add "$oneF" && git commit -m "$sysF: Maintanance update through ${0##*/} ."
     else
      echo "Failed replacing gitfile"
      exit 9
     fi
 fi
fi
}
#test -d "$oneF" || _update_git

_force_replace_files_in_git(){

 if test "$DO_UPDATE_GIT"; then

	 dirG=".${sysF%/*}"
	 mkdir -p "$dirG"

	 /bin/cp -a --remove-destination --backup=numbered "$sysF" "$dirG"/
     if test "$?" = 0 ; then
      git add "$oneF" && git commit -m "$sysF: Maintanance update through ${0##*/} ."
     else
      echo "Failed replacing gitfile"
      exit 9
     fi
 fi

}

if test "$FORCE_GIT_REPLACE" ; then
 _force_replace_files_in_git
else
 _update_git
fi

_update_system(){
if test "$modS" -lt "$modF"; then
 if test "$DO_UPDATE_SYSTEM"; then

    dirS=`echo "${oneF%/*}" | sed 's%^\.%%'`
    mkdir -p "$dirS"

    #/bin/cp -a --remove-destination --backup=numbered "$oneF" "$dirS"/
 fi

fi
}
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

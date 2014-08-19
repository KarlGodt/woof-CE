#!/bin/sh

_error(){
    _exit_=$1; shift
    echo "$*"
    exit $_exit_
}

_error_cont(){
    _exit_=$1; shift
    echo "$*"
    return $_exit_
}

CURRENT_DIR=`pwd`
cd "$CURRENT_DIR"

#DIRS=`find  -type d`
DIRS=`find woof-code/rootfs-skeleton -type d`


while read ONE_DIR; do
#echo "ONE_DIR='$ONE_DIR'"
test "$ONE_DIR" || continue

#ONE_DIR_IN_SYSTEM=`echo "$ONE_DIR" | sed 's!^\.*/woof-code/rootfs-skeleton!!'`
ONE_DIR_IN_SYSTEM=`echo "$ONE_DIR" | sed 's!^woof-code/rootfs-skeleton!!'`
#echo "ONE_DIR_IN_SYSTEM='$ONE_DIR_IN_SYSTEM'"
test -d "$ONE_DIR_IN_SYSTEM" || continue

 cd "$CURRENT_DIR/$ONE_DIR" || _error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

 FILES=`ls -1v`

 while read ONE_FILE; do
 #echo "ONE_FILE='$ONE_FILE'"
 test "$ONE_FILE" || continue

 test -f "$ONE_DIR_IN_SYSTEM/$ONE_FILE" || continue
 test -L "$ONE_DIR_IN_SYSTEM/$ONE_FILE" && continue

 case $ONE_FILE in
 *.gz|*.xpm|*.afm|*.pfb|*.ttf|*.au|*.wav|*.ogg|*.jpg|fonts.*|*.pcf|*.png|*.so|*.so.conf|*.svg|yaf-splash)
 echo "Skipping '$ONE_FILE'"; continue;;
 esac

 [ -e "$ONE_DIR_IN_SYSTEM/$ONE_FILE" ] && {

     cd "$CURRENT_DIR/$ONE_DIR" || _error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

     diff -q "$ONE_DIR_IN_SYSTEM/$ONE_FILE" ./"$ONE_FILE" && continue #returns 1 if differ

     MODIFIED1=`stat -c %Y "$ONE_DIR_IN_SYSTEM/$ONE_FILE"`
     MODIFIED2=`stat -c %Y ./"$ONE_FILE"`

     if test "$MODIFIED2" -ge "$MODIFIED1"; then
     echo "'$ONE_FILE' in WOOF directory newer - replacing the one in system ..."
     cp -a --remove-destination ./"$ONE_FILE" "$ONE_DIR_IN_SYSTEM/"
     continue
     else
     cp -a --remove-destination "$ONE_DIR_IN_SYSTEM/$ONE_FILE" .
     fi

     sleep 1

     cd "$CURRENT_DIR" || _error 1 "Could not cd into '$CURRENT_DIR'"

     git add "$ONE_DIR/$ONE_FILE" || continue

     git commit -m "$ONE_DIR_IN_SYSTEM/$ONE_FILE : Replaced
by the one found currently in the system." || _error_cont 1 "git commit failed."
     sleep 1

     cd "$CURRENT_DIR/$ONE_DIR" || _error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

    } || { echo "$ONE_DIR_IN_SYSTEM/$ONE_FILE : No such so."; }

 done <<EOI
`echo "$FILES"`
EOI


done <<EOH
`echo "$DIRS"`
EOH

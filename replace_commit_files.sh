#!/bin/sh

error(){
    exit=$1; shift
    echo "$*"
    exit $exit
}

error_cont(){
    exit=$1; shift
    echo "$*"
    return $exit
}

PATH=/usr/SVC/bin:$PATH

which git || error "Git not in PATH"

CURRENT_DIR=`pwd`
cd "$CURRENT_DIR"

DIRS=`find -type d -not -name ".git"`

while read ONE_DIR; do
echo "ONE_DIR='$ONE_DIR'"
test "$ONE_DIR" || continue

ONE_DIR_IN_SYSTEM=`echo "$ONE_DIR" | sed 's!^\.*/woof-code/rootfs-skeleton!!'`
echo "ONE_DIR_IN_SYSTEM='$ONE_DIR_IN_SYSTEM'"
test -d "$ONE_DIR_IN_SYSTEM" || continue

 cd "$CURRENT_DIR/$ONE_DIR" || error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

 FILES=`ls -1v`

 while read ONE_FILE; do
 echo "ONE_FILE='$ONE_FILE'"
 test "$ONE_FILE" || continue

 test -f "$ONE_DIR_IN_SYSTEM/$ONE_FILE" || continue

 case $ONE_FILE in
 *.gz|*.xpm|*.afm|*.pfb|*.ttf|*.au|*.wav|*.ogg|*.jpg|fonts.*|*.pcf|*.png|*.so|*.so.conf|*.svg|yaf-splash)
 echo "Skipping '$ONE_FILE'"; continue;;
 esac

 [ -e "$ONE_DIR_IN_SYSTEM/$ONE_FILE" ] && {

     cd "$CURRENT_DIR/$ONE_DIR" || error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

     diff -q "$ONE_DIR_IN_SYSTEM/$ONE_FILE" ./"$ONE_FILE" && continue #returns 1 if differ

    modSYSfile=`stat -c %Y "$ONE_DIR_IN_SYSTEM/$ONE_FILE"`
    modGITfile=`stat -c %Y ./"$ONE_FILE"`

    if [ "$modSYSfile" -ge "$modGITfile" ]; then
     cp -a --remove-destination "$ONE_DIR_IN_SYSTEM/$ONE_FILE" .
     sleep 1
    else
     cp -a --remove-destination ./"$ONE_FILE" "$ONE_DIR_IN_SYSTEM"/
     continue
    fi

     cd "$CURRENT_DIR" || error 1 "Could not cd into '$CURRENT_DIR'"

     git add "$ONE_DIR/$ONE_FILE" || continue

     git commit -m "$ONE_DIR_IN_SYSTEM/$ONE_FILE : Replaced
by the one found currently in the system." || error_cont 1 "git commit failed."
     sleep 1

     cd "$CURRENT_DIR/$ONE_DIR" || error 1 "Could not cd into '$CURRENT_DIR/$ONE_DIR'"

    } || { echo "$ONE_DIR_IN_SYSTEM/$ONE_FILE : No such so."; }

 done <<EOI
`echo "$FILES"`
EOI


done <<EOH
`echo "$DIRS"`
EOH

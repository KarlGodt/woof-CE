#!/bin/bash

# cf_copy_book.sh :
# Script to identify readables on the ground
# either by use_skill literacy or
# by the 'examine' command,
# read the readables by the 'apply' command,
# mark another readable in inventory,
# attempt to rename the readable in inventory,
# write the text from the readable on the ground
# into the marked readable.
# Increases the inscription skill and
# in case of unpickable readables, the character
# can keep the messages, without the need to
# write them down manually.

VERSION=1.0 # 2018-03-25 initial working version

LOGGING=1

BOOK=scroll # main variable ( tome, book, scroll, catalog, etc )

MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

cd "$MY_DIR"

. $HOME/cf/s/cf_funcs_common.sh
. $HOME/cf/s/cf_funcs_items.sh
. $HOME/cf/s/cf_funcs_skills.sh

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to write book and sign messages"
_draw 7  "into some BOOK in inventory."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 7  "BOOK variable is currently set to:"
_draw 7  "$BOOK as default."
_draw 6  "Syntax:"
_draw 7  "script $0 <options>"
_draw 8  "Options:"
_draw 2  "-B WORD : Book WORD to use to write into:"
_draw 2  "f.ex. tome, book, scroll, catalog, ..."
_draw 11 "-V   :Print version information."
_draw 10 "-d   :Print debugging to msgpane."
_draw 10 "-L   :Turn on logging."

exit 0
}

_do_parameters(){
_debug "_do_parameters:$*"
_log   "_do_parameters:$*"

# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in
*help)    _say_help 0;;
*version) _say_version 0;;
--?*)  _exit 3 "No other long options than help and version recognized.";;
--*)   _exit 3 "Unhandled first parameter '$1' .";;
-?*) :;;
[0-9]*) NUMBER=$1
        test "${NUMBER//[[:digit:]]/}" && _exit 3 "NUMBER '$1' is not an integer digit."
        shift;;
*) _exit 3 "Unknown first parameter '$1' .";;
esac

while getopts B:LdVhabcdefgijklmnopqrstuvwxyzACDEFGHIJKMNOPQRSTUWXYZ oneOPT
do
case $oneOPT in
B) BOOK="$OPTARG";;
L) LOGGING=$((LOGGING+1));;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

_set_global_variables "$*"
_do_parameters "$*"
_say_start_msg "$*"

_get_book_title_skill_literacy(){
_debug "_get_book_title_skill_literacy:$*"
_log   "_get_book_title_skill_literacy:$*"

unset BOOK_TITLE

_watch $DRAWINFO
_is 1 1 use_skill literacy
usleep 1000

while :; do
 unset REPLY
 read -t $TMOUT
 _debug "$REPLY"
 _log   "_get_book_title_skill_literacy:$REPLY"

  case $REPLY in
  '') break 1;;
  *learn*nothing*more*) break 1;;

  *identify*)
    case $REPLY in
     *drawinfo*)    BOOK_TITLE=`echo "$REPLY" | cut -f6- -d' '`;;
     *drawextinfo*) BOOK_TITLE=`echo "$REPLY" | cut -f8- -d' '`;;
    esac
  break 1
  ;;

  *) :;;
  esac

usleep 1000
done
_unwatch $DRAWINFO

test "$BOOK_TITLE"
}

_get_book_title_examine(){
_debug  "_get_book_title_examine:$*"
_log    "_get_book_title_examine:$*"

unset BOOK_TITLE

_watch $DRAWINFO
_is 1 1 examine
usleep 1000

while :; do
 unset REPLY
 read -t $TMOUT
 _debug "$REPLY"
 _log   "_get_book_title_examine:$REPLY"

  case $REPLY in
  '') break 1;;
  *learn*nothing*more*) break 1;;
  *That*is*)   BOOK_TITLE="${REPLY##*That is }";;
  *Those*are*) BOOK_TITLE="${REPLY##*Those are }";;
  *) :;;
  esac

usleep 1000
done
_unwatch $DRAWINFO

test "$BOOK_TITLE"
}

_get_book_text_apply(){
_debug "_get_book_text_apply:$*"
_log   "_get_book_text_apply:$*"

_watch $DRAWINFO
_is 1 1 apply
usleep 1000

while :; do
 unset REPLY
 read -t $TMOUT
 _debug "$REPLY"
 _log   "_get_book_text_apply:$REPLY"

  case $REPLY in
  '') break 1;;
  *)
    case $REPLY in
     *drawinfo*)  REPLY=`echo "$REPLY" | cut -f4- -d' '`
                  BOOK_TEXT="$BOOK_TEXT
$REPLY";;
    *drawextinfo*) REPLY=`echo "$REPLY" | cut -f6- -d' '`
                   BOOK_TEXT="$BOOK_TEXT
$REPLY";;
     *)           BOOK_TEXT="$BOOK_TEXT
$REPLY";;
    esac

  esac

usleep 1000
done
_unwatch $DRAWINFO
}

_write_copy(){
if test "$BOOK_TITLE" -o "$BOOK_TEXT"; then
_mark_item $BOOK || return $?

 BOOK_TITLE=`echo "$BOOK_TITLE" | sed 'sV[[:punct:]]VVg'`
 BOOK_TITLE=`echo $BOOK_TITLE | cut -c 1-31`
 if test "$BOOK_TITLE"; then
 _is 1 1 rename "<$BOOK>" to "<$BOOK_TITLE>"
 fi
 if test "$BOOK_TEXT"; then
 #_is 1 1 use_skill inscription $BOOK_TEXT
 while read -r line; do
 _is 1 1 use_skill inscription $line
 done <<EoI
-------------------
`echo "$BOOK_TEXT"`
EoI
 fi
else false
fi
}


_draw 3 "1 OK"
while :; do

_draw 3 "2 OK"
 _check_have_item_in_inventory "$BOOK" || break
_draw 3 "3 OK"
 _check_skill_available "literacy" || break
_draw 3 "4 OK"

if _check_skill_available "inscription"; then
 _draw 3 "5 OK"
 unset BOOK_TITLE BOOK_TEXT
 _get_book_title_skill_literacy || _get_book_title_examine
 _get_book_text_apply
 _write_copy
fi
_draw 3 "6 END"
break
done

_say_end_msg

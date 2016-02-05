#!/bin/ash

PROG=`readlink -f "$0"`
CURR_DIR="${PROG%/*}"
cd "$CURR_DIR"  || exit 3
( ./bin/xosview || ./bin/xosview -font '-*' ) 2>/dev/null &

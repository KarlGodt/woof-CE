#!/bin/sh

PROG=`readlink -e "$0"`
CURR_DIR="${PROG%/*}"
cd "$CURR_DIR"
./bin/xosview 2>/dev/null

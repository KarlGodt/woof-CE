#!/bin/bash

echo "$0: $*"
echo "$0: $@"
shift;shift
echo "$0: $*"
echo "$0: $@"
$*
#if [ $? -eq 0 ]; then
#   FAIL=0
#else
#   FAIL=1
#fi
#
#[ "$INSTALLWATCH_BACKUP_PATH" ] && rm -rf ${INSTALLWATCH_BACKUP_PATH}/no-backup
#
# exit $FAIL
#

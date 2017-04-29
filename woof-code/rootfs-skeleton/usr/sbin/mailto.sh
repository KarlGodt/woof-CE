#!/bin/sh

if test "`which mozmail`"; then
 exec mozmail "$@"
else
exec sylpheed --compose "$@" &
fi

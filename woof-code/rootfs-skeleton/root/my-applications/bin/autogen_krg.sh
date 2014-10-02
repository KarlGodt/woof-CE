#!/bin/sh
####### bootstrap scim-1.4.9 ###################
#set -x

# 1
#aclocal -I m4

# 2
#autoheader

# 3
#libtoolize -c --automake # --ltdl #1.4.10

# 4
#automake --add-missing --copy --include-deps

# 5
#autoconf
### @end 1
################################################


prefix=/usr/local/bin
#prefix=/usr/bin

# 1
#aclocal-1.9.6-orig
$prefix/acloocal

# 3
$prefix/libtoolize

# 2
$prefix/autoheader

# 5
$prefix/autoconf

# 4
#automake-1.9.6-orig --add-missing
$prefix/automake --add-missing

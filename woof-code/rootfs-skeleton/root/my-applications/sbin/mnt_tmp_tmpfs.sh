#!/bin/bash


mkdir /tmp_new
cp -a /tmp/* /tmp_new
cp -a /tmp/.[a-zA-Z0-9]* /tmp_new
mount -t tmpfs none /tmp
cp -a /tmp_new/* /tmp
cp -a /tmp_new/.[a-zA-Z0-9]* /tmp
rm -r /tmp_new

#Mount options for tmpfs
#       The following parameters accept a suffix k, m  or  g  for  Ki,  Mi,  Gi
#       (binary kilo, mega and giga) and can be changed on remount.
#
#       size=nbytes
#              Override  default  maximum  size of the filesystem.  The size is
#              given in bytes, and rounded down to entire pages.   The  default
#              is half of the memory.
#
#       nr_blocks=
#              Set number of blocks.
#
#       nr_inodes=
#              Set number of inodes.
#
#       mode=  Set initial permissions of the root directory.
#
#


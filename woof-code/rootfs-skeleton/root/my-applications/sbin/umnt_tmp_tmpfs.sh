#!/bin/bash


mkdir /tmp_new
cp -a /tmp/* /tmp_new
cp -a /tmp/.[a-zA-Z0-9]* /tmp_new
umount -t tmpfs /tmp
cp -u /tmp_new/* /tmp
cp -u /tmp_new/.[a-zA-Z0-9]* /tmp
rm -r /tmp_new

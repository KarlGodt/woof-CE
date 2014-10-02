#!/bin/bash

# wrapper for short date
P="$1"
[ -z "$P" ] && P='s'

case $P in
s) date +%Y_%m_%d ;;
o) date +%d%b%Y ;;

esac

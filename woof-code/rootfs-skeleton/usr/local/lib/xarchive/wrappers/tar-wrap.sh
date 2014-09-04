#! /bin/bash
# tar-wrap.sh - bash tar wrapper for xarchive frontend
# Copyright (C) 2005 Lee Bigelow <ligelowbee@yahoo.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
echo >>/tmp/xarchive_errs.log
echo $0 >>/tmp/xarchive_errs.log
echo "$@" >>/tmp/xarchive_errs.log
# set up exit status variables
E_UNSUPPORTED=65

# Supported file extentions for tar
TAR_EXTS="tar"
GZIP_EXTS="tar.gz tgz"
BZIP2_EXTS="tar.bz tbz tar.bz2 tbz2"
COMPRESS_EXTS="tar.z tar.Z"
XZ_EXTS="tar.xz txz"
LZO_EXTS="tar.lzo tar.lzop"
LZA_EXTS="tar.lza tar.lzma tar.lz tar.lzm"
EXT_ALL="$TAR_EXTS $GZIP_EXTS $BZIP2_EXTS $COMPRESS_EXTS $XZ_EXTS $LZO_EXTS $LZA_EXTS"
##+++2012-04-03

# Setup awk program
AWK_PROGS="mawk gawk awk"
AWK_PROG=""
for awkprog in $AWK_PROGS; do
    if [ "$(which $awkprog)" ]; then
        AWK_PROG="$awkprog"
        break
    fi
done

# Program to wrap
TAR_PROG="tar"

# setup variables opt and archive.
# the shifting will leave the files passed as
# all the remaining args "$@"
opt="$1"
echo "opt='$opt'" >>/tmp/xarchive_errs.log
shift 1
archive="$1"
echo "archive='$archive'" >>/tmp/xarchive_errs.log
shift 1

# set up compression variables for our compression functions.
# translate archive name to lower case for pattern matching.
# use compressor -c option to output to stdout and direct it where we want
lc_archive="$(echo $archive|tr '[[:upper:]]' '[[:lower:]]')"
echo "lc_archive='$lc_archive'" >>/tmp/xarchive_errs.log
for ext in $GZIP_EXTS; do
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        DECOMPRESS="gzip -dc"
        COMPRESS="gzip -c"
        TAR_COMPRESS_OPT="--use-compress-prog=gzip"
    fi
done
for ext in $BZIP2_EXTS; do
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        DECOMPRESS="bzip2 -dc"
        COMPRESS="bzip2 -c"
        TAR_COMPRESS_OPT="--use-compress-prog=bzip2"
    fi
done
for ext in $COMPRESS_EXTS; do
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        DECOMPRESS="uncompress -dc"
        COMPRESS="compress -c"
        TAR_COMPRESS_OPT="--use-compress-prog=compress"
    fi
done

##+++2012-04-03
for ext in $XZ_EXTS; do echo $ext >>/tmp/xarchive_errs.log
    expr "$lc_archive" : ".*\."$ext"$" >>/tmp/xarchive_errs.log
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        echo "greater '0'" >>/tmp/xarchive_errs.log
        DECOMPRESS="xz -dc" #-d, --decompress    force decompression
                           #-c, --stdout        write to standard output and don't delete input files
        COMPRESS="xz -zc"  #-z, --compress      force compression
        TAR_COMPRESS_OPT="--use-compress-prog=xz"
        else
        echo "NOT greater '0'" >>/tmp/xarchive_errs.log
    fi
done
##+++2012-04-03
##+++2012-04-22
for ext in $LZO_EXTS; do echo $ext >>/tmp/xarchive_errs.log
    expr "$lc_archive" : ".*\."$ext"$" >>/tmp/xarchive_errs.log
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        echo "greater '0'" >>/tmp/xarchive_errs.log
        DECOMPRESS="lzop -dc" #-d, --decompress    force decompression
                           #-c, --stdout        write to standard output and don't delete input files
        COMPRESS="lzop -zc"  #-z, --compress      force compression
        TAR_COMPRESS_OPT="--use-compress-prog=lzop"
        else
        echo "NOT greater '0'" >>/tmp/xarchive_errs.log
    fi
done
for ext in $LZA_EXTS; do echo $ext >>/tmp/xarchive_errs.log
    expr "$lc_archive" : ".*\."$ext"$" >>/tmp/xarchive_errs.log
    if [ $(expr "$lc_archive" : ".*\."$ext"$") -gt 0 ]; then
        echo "greater '0'" >>/tmp/xarchive_errs.log
        DECOMPRESS="lzma -dc" #-d, --decompress    force decompression
                           #-c, --stdout        write to standard output and don't delete input files
        COMPRESS="lzma -zc"  #-z, --compress      force compression
        TAR_COMPRESS_OPT="--use-compress-prog=lzma"
        else
        echo "NOT greater '0'" >>/tmp/xarchive_errs.log
    fi
done
##+++2012-04-22
# Command line options for prog functions
# open and extract can use tar's cmd line option
# add, new, and remove need to decompress the tar first
# do their thing, than recompress the tar.
OPEN_OPTS="$TAR_COMPRESS_OPT -tvf"
EXTRACT_OPTS="$TAR_COMPRESS_OPT -xf"
ADD_OPTS="-rf"
NEW_OPTS="-cf"
REMOVE_OPTS="--delete -f"

# Compression functions
decompress_func()
{
    if [ "$DECOMPRESS" ]; then
        tmpname="$(mktemp -t tartmp.XXXXXX)"
        if [ -f "$archive" ]; then
            $DECOMPRESS "$archive" > "$tmpname"
        fi
        # store old name for when we recompress
        oldarch="$archive"
        # change working file to decompressed tmp
        archive="$tmpname"
    fi
}

compress_func()
{
    if [ "$COMPRESS" ] && [ "$oldarch" ]; then
        [ -f "$oldarch" ] && rm "$oldarch"
        if $COMPRESS "$archive" > "$oldarch"; then
            rm "$archive"
        fi
    fi
}

# the option switches
case "$opt" in
    -i) # info: output supported extentions for progs that exist
        if [ ! "$AWK_PROG" ]; then
            echo "none of the awk programs $AWK_PROGS found" >>/tmp/xarchive_errs.log
            echo "extentions $EXTS ignored" >>/tmp/xarchive_errs.log
        elif [ "$(which $TAR_PROG)" ]; then
            for ext in $TAR_EXTS; do
                printf "%s;" $ext
            done
            for ext in $GZIP_EXTS; do
                if [ "$(which gzip)" ]; then
                    printf "%s;" $ext
                else
                    echo "gzip not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            for ext in $BZIP2_EXTS; do
                if [ "$(which bzip2)" ]; then
                    printf "%s;" $ext
                else
                    echo "bzip2 not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            for ext in $COMPRESS_EXTS; do
                #if [ "$(which compress)" ] && [ "$(which uncompress)" ]; then
                if [ "$(which compress)" ] || [ "$(which uncompress)" ]; then
                    printf "%s;" $ext
                else
                    echo "compress and/or uncompress not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            ##+++2012-04-03
            for ext in $XZ_EXTS; do
                if [ "$(which xz)" ]; then
                    printf "%s;" $ext
                else
                    echo "xz not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            ##+++2012-04-03
            ##+++2012-04-22
            for ext in $LZO_EXTS; do
                if [ "$(which lzop)" ]; then
                    printf "%s;" $ext
                else
                    echo "lzop not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            for ext in $LZA_EXTS; do
                if [ "$(which lzma)" ]; then
                    printf "%s;" $ext
                else
                    echo "lzma not found" >>/tmp/xarchive_errs.log
                    echo "extention $ext ignored" >>/tmp/xarchive_errs.log
                fi
            done
            ##+++2012-04-22
        else
            echo "command $TAR_PROG not found" >>/tmp/xarchive_errs.log
            echo "extentions $TAR_EXTS ignored" >>/tmp/xarchive_errs.log
        fi
        printf "\n"
        exit
        ;;

    -o) # open: mangle output of tar cmd for xarchive
        # format of tar output:
# lrwxrwxrwx USR/GRP       0 2005-05-12 00:32:03 file -> /path/to/link
# -rw-r--r-- USR/GRP    6622 2005-04-22 12:29:14 file
# 1          2          3    4          5        6
        $TAR_PROG $OPEN_OPTS "$archive" | $AWK_PROG '
        {
          attr=$1
          split($2,ids,"/") #split up the 2nd field to get uid/gid
          uid=ids[1]
          gid=ids[2]
          size=$3
          date=$4
          time=$5

          #this method works with filenames that start with a space (evil!)
          #split line a time and a space
          split($0,linesplit, $5 " ")
          #then split the second item (name&link) at the space arrow space
          split(linesplit[2], nlsplit, " -> ")

          name=nlsplit[1]
          link=nlsplit[2]

          if (! link) {link="-"} #if there was no link set it to a dash

          printf "%s;%s;%s;%s;%s;%s;%s;%s\n",name,size,attr,uid,gid,date,time,link
        }'
        exit
        ;;

    -a) # add to archive passed files
        # we only want to add the file's basename, not
        # the full path so...
        decompress_func
        while [ "$1" ]; do
            cd "$(dirname "$1")"
            $TAR_PROG $ADD_OPTS "$archive" "$(basename "$1")"
            wrapper_status=$?
            shift 1
        done
        compress_func
        exit $wrapper_status
        ;;

    -n) # new: create new archive with passed files
        # create will only be passed the first file, the
        # rest will be "added" to the new archive
        decompress_func
        cd "$(dirname "$1")"
        $TAR_PROG $NEW_OPTS "$archive" "$(basename "$1")"
        wrapper_status=$?
        compress_func
        exit $wrapper_status
        ;;

    -r) # remove: from archive passed files
        decompress_func
        $TAR_PROG $REMOVE_OPTS "$archive" "$@"
        wrapper_status=$?
        compress_func
        exit $wrapper_status
        ;;

    -e) # extract: from archive passed files
        # xarchive will put is the right extract dir
        # so we just have to extract.
        $TAR_PROG $EXTRACT_OPTS "$archive" "$@"
        exit
        ;;

     *) echo "error, option $opt not supported" >>/tmp/xarchive_errs.log
        echo "use one of these:" >>/tmp/xarchive_errs.log
        echo "-i                #info" >>/tmp/xarchive_errs.log
        echo "-o archive        #open" >>/tmp/xarchive_errs.log
        echo "-a archive files  #add" >>/tmp/xarchive_errs.log
        echo "-n archive file   #new" >>/tmp/xarchive_errs.log
        echo "-r archive files  #remove" >>/tmp/xarchive_errs.log
        echo "-e archive files  #extract" >>/tmp/xarchive_errs.log
        exit
esac

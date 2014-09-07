#! /bin/bash
# Based on the improved zip-wrap.sh by 2010 Alexander .S.T. Ross, which is based on zip-wrap.sh by 2005 Lee Bigelow <ligelowbee@yahoo.com> 

#--------------------------------------------------------------------------------
# Copyright (C) 2010 Alexander .S.T. Ross
# Get Alexander .S.T. Ross (abushcrafter) Email Here: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>

    #This program is free software: you can redistribute it and/or modify
    #it under the terms of the GNU General Public License as published by
    #the Free Software Foundation, either version 3 of the License, or
    #(at your option) any later version.

    #This program is distributed in the hope that it will be useful,
    #but WITHOUT ANY WARRANTY; without even the implied warranty of
    #MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    #GNU General Public License for more details.

    #You should have received a copy of the GNU General Public License
    #along with this program.  If not, see <http://www.gnu.org/licenses/>.

#--------------------------------------------------------------------------------
# uu-wrap.sh - bash uudecode and uuencode wrapper for xarchive.

#ChangeLog ----------------------------------------------------------------------
#	2010-09-23  Alexander .S.T. Ross (abushcrafter) Email: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>
#		* 0.0.1: 

echo >>/tmp/xarchive_errs.log

# set up exit status variables
E_UNSUPPORTED=65

# Supported file extentions for zip 
EXTS="uu"

# Programs to wrap
ZIP_PROG="uuencode"
UNZIP_PROG="uudecode"
ZIPINFO_PROG=""

# Setup awk program
AWK_PROGS="mawk gawk awk"
AWK_PROG=""
for awkprog in $AWK_PROGS; do
    if [ "$(which $awkprog)" ]; then
        AWK_PROG="$awkprog"
        break
    fi
done

# Setup xterm program to use
XTERM_PROGS="xterm rxvt xvt wterm aterm Eterm"
XTERM_PROG=""
for xtermprog in $XTERM_PROGS; do
    if [ "$(which $xtermprog)" ]; then
        XTERM_PROG="$xtermprog"
        break
    fi
done

# setup variables opt and archive.
# the shifting will leave the files passed as
# all the remaining args: "$@"
opt="$1"
echo "options $opt" >>/tmp/xarchive_errs.log
shift 1
archive="$1"
echo "archive $archive" >>/tmp/xarchive_errs.log
shift 1

# Command line options for prog functions

# for zip, use recursive when adding files
NEW_OPTS=""
ADD_OPTS=""
REMOVE_OPTS=""

# for zipinfo, short list, no header, no tail
OPEN_OPTS=""

# for unzip, don't overwrite existing files, just skip the confilct.
EXTRACT_OPTS=""
PASS_EXTRACT_OPTS=""

# the option switches
case "$opt" in
    -i) # info: output supported extentions for progs that exist
        if [ ! "$AWK_PROG" ]; then
            echo none of the awk programs $AWK_PROGS found >>/tmp/xarchive_errs.log
            echo extentions $EXTS ignored >>/tmp/xarchive_errs.log
        elif [ "$(which $UNZIP_PROG)" -a "$(which $ZIPINFO_PROG)" ]; then
            for ext in $EXTS; do
                printf "%s;" $ext
            done
            if [ ! "$(which $ZIP_PROG)" ]; then
                echo warning: $ZIP_PROG not found, extract only >>/tmp/xarchive_errs.log
            fi
        else
            echo commands $UNZIP_PROG  and $ZIPINFO_PROG not found >>/tmp/xarchive_errs.log 
            echo extentions $EXTS ignored >>/tmp/xarchive_errs.log
        fi
        printf "\n"
        exit
        ;;

    -o) # open: mangle output of zipinfo cmd for xarchive 
        # format of zipinfo -T -s-h- output:
        # -rw-r--r--  2.3 unx    11512 tx defN YYYYMMDD.HHMMSS file.txt 
        # 1           2   3      4     5  6    7               8
        $ZIPINFO_PROG $OPEN_OPTS "$archive" | $AWK_PROG -v uuid=${UID} '
        {
          attr=$1; size=$4
          
          year=substr($7,1,4)
          month=substr($7,5,2)
          day=substr($7,7,2)
          date=year "-" month "-" day

          hours=substr($7,10,2)
          mins=substr($7,12,2)
          secs=substr($7,14,2)
          time=hours ":" mins ":" secs

          uid=uuid; gid=uuid; link="-"
          #split line at the time and a space, second item is our name
          split($0, linesplit, ($7 " "))
          name=linesplit[2]
          printf "%s;%s;%s;%s;%s;%s;%s;%s\n",name,size,attr,uid,gid,date,time,link
        }'            
        exit
        ;;

    -a) # add:  to archive passed files
        # we only want to add the file's basename, not
        # the full path so...
        while [ "$1" ]; do
            cd "$(dirname "$1")"
            $ZIP_PROG $ADD_OPTS "$archive" "$(basename "$1")"
            wrapper_status=$?
            shift 1
        done
        exit $wrapper_status
        ;;

    -n) # new: create new archive with passed files 
        # create will only be passed the first file, the
        # rest will be "added" to the new archive
        cd "$(dirname "$1")"
        $ZIP_PROG $NEW_OPTS "$archive" "$(basename "$1")"
        exit
        ;;

    -r) # remove: from archive passed files 
        $ZIP_PROG $REMOVE_OPTS "$archive" "$@"
        exit
        ;;

    -e) # extract: from archive passed files 
        # xarchive will put is the right extract dir
        # so we just have to extract.
        $UNZIP_PROG $EXTRACT_OPTS "$archive" "$@"
        if [ "$?" -ne "0" ] && [ "$XTERM_PROG" ]; then
            echo Probably password protected,
            echo Opening an x-terminal...
            $XTERM_PROG -e $UNZIP_PROG $PASS_EXTRACT_OPTS "$archive" "$@"
        fi
        exit
        ;;

     *) echo "error, option $opt not supported"
        echo "use one of these:" 
        echo "-i                #info" 
        echo "-o archive        #open" 
        echo "-a archive files  #add" 
        echo "-n archive file   #new" 
        echo "-r archive files  #remove" 
        echo "-e archive files  #extract" 
        exit
esac

#! /bin/bash
# Based on the improved zip-wrap.sh by 2010 Alexander .S.T. Ross, which is based on ace-wrap.sh by 2005 Lee Bigelow <ligelowbee@yahoo.com> 

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
# zoo-wrap.sh - bash zoo wrapper for xarchive.

#ChangeLog ----------------------------------------------------------------------
#	2010-09-23  Alexander .S.T. Ross (abushcrafter) Email: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>
#		* 0.0.1: 
echo >>/tmp/xarchive_errs.log


E_UNSUPPORTED=65

# Supported file extentions for ace 
EXTS="zoo"

# Program to wrap
ACE_PROG="zoo"

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
# all the remaining args "$@"
opt="$1"
echo "options $opt" >>/tmp/xarchive_errs.log
shift 1
archive="$1"
echo "archive $archive" >>/tmp/xarchive_errs.log
shift 1

# Command line options for prog functions
# disable comments when opening
OPEN_OPTS="-list"
ADD_OPTS="-add"
NEW_OPTS="-update"
REMOVE_OPTS="-delete"
EXTRACT_OPTS="-extract"

# the option switches
case "$opt" in
    -i) # info: output supported extentions for progs that exist
        if [ "$(which $ACE_PROG)" ]; then
            for ext in $EXTS; do
                printf "%s;" $ext
            done
        else
            echo command $ACE_PROG not found >>/tmp/xarchive_errs.log 
            echo extentions $EXTS ignored >>/tmp/xarchive_errs.log 
        fi
        printf "\n"
        exit
        ;;

    -o) # open: mangle output of ace cmd for xarchive 
        # format of ace output:
        # Date    ³Time ³Packed     ³Size     ³Ratio³File
        # 17.09.02³00:32³     394116³   414817³  95%³ OggDS0993.exe 
	# 1                   2         3        4    5
	$ACE_PROG $OPEN_OPTS "$archive" | $AWK_PROG -v uuid=${UID} '
        #only process lines starting with two numbers and a dot
        /^[0-9][0-9]\./ {
          date=substr($1,1,8)
          time=substr($1,10,5)
          #need to strip the funky little 3 off the end of size
          size=substr($3,1,(length($3)-1))
          
          #split line at ratio and a space, second item is our name
          split($0, linesplit, ($4 " "))
          name=linesplit[2]
          
          uid=uuid; gid=uuid; link="-"; attr="-"
          printf "%s;%s;%s;%s;%s;%s;%s;%s\n",name,size,attr,uid,gid,date,time,link
        }'
	exit
        ;;

    -a) # add:  to archive passed files
        # we only want to add the file's basename, not
        # the full path so...
        # ONY HAVE UNACE, no adding...
        # while [ "$1" ]; do
        #     cd "$(dirname "$1")"
        #     $ACE_PROG $ADD_OPTS "$archive" "$(basename "$1")"
        #     shift 1
        # done
        exit $E_UNSUPPORTED 
        ;;

    -n) # new: create new archive with passed files 
        # create will only be passed the first file, the
        # rest will be "added" to the new archive
        # ONY HAVE UNACE, no creating...
        # cd "$(dirname "$1")"
        # $ACE_PROG $NEW_OPTS "$archive" "$(basename "$1")"
        exit $E_UNSUPPORTED 
        ;;

    -r) # remove: from archive passed files 
        # ONY HAVE UNACE, no removing...
        # $ACE_PROG $REMOVE_OPTS "$archive" "$@"
        exit $E_UNSUPPORTED 
        ;;

    -e) # extract: from archive passed files 
        # xarchive will put is the right extract dir
        # so we just have to extract.
        $XTERM_PROG -e $ACE_PROG $EXTRACT_OPTS "$archive"
        exit
        ;;

    -v) # view: from archive passed files 
        exit $E_UNSUPPORTED
        ;;

     *) echo "error, option $opt not supported"
        echo "use one of these:" 
        echo "-i                #info" 
        echo "-o archive        #open" 
        echo "-a archive files  #add" 
        echo "-n archive file   #new" 
        echo "-r archive files  #remove" 
        echo "-e archive files  #extract" 
        echo "-v archive file   #view"  
        exit
esac

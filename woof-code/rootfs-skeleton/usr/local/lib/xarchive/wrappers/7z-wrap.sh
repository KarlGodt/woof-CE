#! /bin/bash
# Based on 7za-wrap.sh by 2005 Michael Shigorin <mike@altlinux.org>
# and p7zip mcextfs (C) 2004 Sergiy Niskorodov (sgh ukrpost net)

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
# 7z-wrap.sh - bash 7z wrapper for xarchive frontend.

#ChangeLog ----------------------------------------------------------------------
#2010-06-13  Alexander .S.T. Ross (abushcrafter) Email: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>
#		* 0.0.1: First Version.
#		* 0.0.2: Added a few more formats.
#		* 0.0.3: Tidyed up comments.
#		* 0.0.4: Removed support for z gz bz bz2 because I could not open tar.gz files any more. I think "tar-wrap.sh" can deal them.

#2010-09-23  Alexander .S.T. Ross (abushcrafter) Email: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>
#		* 0.0.5: In version 0.0.4 I failed to remove support for z. So I have now done it.

#2010-12-06  Alexander .S.T. Ross (abushcrafter) Email: <http://www.google.com/recaptcha/mailhide/d?k=01uNeUuXxeNm9FA3Zciuoqzw==&c=nVfKeb7kjqZVVIQanqJwEC2DP5zrALkSERTopYvj_pU=>
#		* 0.0.6: Added support for "lha".

echo >>/tmp/xarchive_errs.log

# set up exit status variables
E_UNSUPPORTED=65

# Supported file extentions for 7z
EXTS="gnm 7z cab chm cpio dmg hfs iso lzh lha msi nsis udf wim xar exe swm chw hxs"

# Programs to wrap
P7Z_PROG="7z"

# Setup awk program to use
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
NEW_OPTS="a -ms=off"
ADD_OPTS="a -ms=off"
REMOVE_OPTS="d"
OPEN_OPTS="l"
EXTRACT_OPTS="x -y -p-"
PASS_EXTRACT_OPTS="x -y"

# the option switches
case "$opt" in
    -i) # info: output supported extentions for progs that exist
        if [ ! "$AWK_PROG" ]; then
            echo none of the awk programs $AWK_PROGS found >>/tmp/xarchive_errs.log
            echo extentions $EXTS ignored >>/tmp/xarchive_errs.log
        elif [ "$(which $P7Z_PROG)" ]; then
            for ext in $EXTS; do
                printf "%s;" $ext
            done
        else
            echo command $P7Z_PROG not found >>/tmp/xarchive_errs.log 
            echo extentions $EXTS ignored >>/tmp/xarchive_errs.log
        fi
        printf "\n"
        exit
        ;;

    -o) # open: mangle output of 7za cmd for xarchive 
        # format of 7za output:
	# ------------------- ----- ------------ ------------  ------------
	# 1992-04-12 11:39:46 ....A          356               ANKETA.FRG
        
	$P7Z_PROG $OPEN_OPTS "$archive" | $AWK_PROG -v uuid=${UID-0} '
	BEGIN { flag=0; }
	/^-------/ { flag++; if (flag > 1) exit 0; next }
	{
		if (flag == 0) next

		year=substr($1, 1, 4)
		month=substr($1, 6, 2)
		day=substr($1, 9, 2)
		time=substr($2, 1, 5)

		if (index($3, "D") != 0) {attr="drwxr-xr-x"}
		else if (index($3, ".") != 0) {attr="-rw-r--r--"}

		size=$4

		$0=substr($0, 54)
		if (NF > 1) {name=$0}
		else {name=$1}
		gsub(/\\/, "/", name)

		printf "%s;%d;%s;%d;%d;%d-%02d-%02d;%s;-\n", name, size, attr, uid, 0, year, month, day, time
	}'
	exit
	;;

    -a) # add:  to archive passed files
        # we only want to add the file's basename, not
        # the full path so...
        while [ "$1" ]; do
            cd "$(dirname "$1")"
            $P7Z_PROG $ADD_OPTS "$archive" "$(basename "$1")"
            wrapper_status=$?
            shift 1
        done
        exit $wrapper_status
        ;;

    -n) # new: create new archive with passed files 
        # create will only be passed the first file, the
        # rest will be "added" to the new archive
        cd "$(dirname "$1")"
        $P7Z_PROG $NEW_OPTS "$archive" "$(basename "$1")"
        exit
        ;;

    -r) # remove: from archive passed files 
    	wrapper_status=0
    	while [ "$1" ]; do
		$P7Z_PROG $OPEN_OPTS "$archive" 2>/dev/null \
		| grep -q "[.][/]" >&/dev/null && EXFNAME=*./"$1" || EXFNAME="$1"
		$P7Z_PROG $REMOVE_OPTS "$archive" "$EXFNAME" 2>&1 \
		| grep -q E_NOTIMPL &> /dev/null && {
			echo -e "Function not implemented: 7z cannot delete files from solid archive." >&2
			wrapper_status=$E_UNSUPPORTED
		}
		shift 1;
	done
        exit $wrapper_status
        ;;

    -e) # extract: from archive passed files 
        # xarchive will put is the right extract dir
        # so we just have to extract.
        $P7Z_PROG $EXTRACT_OPTS "$archive" "$@"
        if [ "$?" -ne "0" ] && [ "$XTERM_PROG" ]; then
            echo Probably password protected,
            echo Opening an x-terminal...
            $XTERM_PROG -e $P7Z_PROG $PASS_EXTRACT_OPTS "$archive" "$@"
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

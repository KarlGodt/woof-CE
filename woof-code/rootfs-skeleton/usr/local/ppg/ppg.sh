#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_ppg.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/ppg/ppg.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in 1; do shift; done; }

_trap

}
# End new header
#

#       Puppy Podcast Grabber v0.9.9
#       Brad Coulthard <Coulthard@ieee.org>
# 
#		Feedback is great! email me.
#
#       This script is my own work but I did use some commands and 
#       ideas from both PodGet and Bash Podder.
#
#		http://sourceforge.net/projects/podget/
#		http://linc.homeunix.org:8080/scripts/bashpodder/
#
#		This program is for Puppy Linux www.puppylinux.com
#		If you would like to use it for another disto go for it.
#		Please give me credit for my work.
#
#      This program is free software; you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation; either version 2 of the License, or
#      (at your option) any later version.
#
#      This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#      along with this program; if not, write to the Free Software
#      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#



echo "---------------------------------"
echo "---   Puppy Podcast Grabber   ---"
echo "---------------------------------"
echo

cd $(dirname $0)

maindir="/usr/local/ppg/"

serverlist="${maindir}serverlist.txt"

gonefile="./.gone"

# change this to where you would like the files to be saved
outputdir="/root/my-documents/Podcasts"
if [ ! -e "${outputdir}" ]; then
	mkdir "${outputdir}"
fi

if [ ! -e "${maindir}/.done" ]; then
	echo " " >> "${maindir}/.done"
fi


if [ ! -e "${maindir}/.gone" ]; then
	echo " " >> "${maindir}/.gone"
fi







# how long ( in s ) to hang for a bad RSS feed
# (not working as of now)
rsstimeout=8


# This is a file that keeps track of the files downloaded
# so you don't have to keep them 
donelist="${maindir}.done"

# When the script gets less buggy this will go away
# Just a place to keep info on what the script is doing (for me)
debuglog="${maindir}.debuglog.txt"
if [ -f "${debuglog}" ]; then
	rm -f "${debuglog}"
fi

# How many Podcasts to download for a new feed
intdownload=2


# Main loop
while read feed_url feed_keep "feed_name" ; do
	# If the line in the serverlist file is a comment or blank goto next
	if   [[ $(expr index "# " "$feed_url") > 0 ]] && [[ $(expr index "# " "$feed_url") < 2 ]] || [[ $feed_url == "" ]] ; then
		echo "edited out line in "${serverlist}" that was not a podcast" >>"${debuglog}"
		continue
	fi
	
	#echo "----------------------------------------"
	echo "-- Updating $feed_name"
	echo


 
	# Get filelist from RSS feed (Bash Podder) 
	indexfile=$(xsltproc parse_enclosure.xsl $feed_url 2> /dev/null || wget -q $feed_url -O - | tr '\r' '\n' | tr \' \" | sed -n 	's/.*url="\([^"]*\)".*/\1/p') 
		#echo $indexfile
		#read
		
		
		keep_count=0
	for url in $indexfile; do
			
			#keep_count is the number of files downloaded so far
			let "keep_count = keep_count + 1"
			#echo $keep_count
			#sleep 1
			
			if [ "$keep_count" -gt "$intdownload" ]; then
				continue 2 # Back out to main while loop
			fi
			#echo $keep_count
			sleep 1
			
			# Check in the donelist file to see if file has been downloaded yet
			donetest=`fgrep "$url" "$donelist"`
			if [ "X$donetest" != "X" ]; then
				
				#echo;echo "  -- No new Podcasts moveing on .."
				continue # Not a new file goto next podcast 
			fi
			# If the dir for the podcast files is not there create it
			if [ ! -e "$outputdir/$feed_name/" ]; then
				mkdir "$outputdir/$feed_name/"
			fi
			
			# Get the Podcast file name ie something.mp3 ...
			filename=$(echo $url | sed -e 's/.*\/\([^\/]\+\)/\1/' -e 's/%20/ /g')
			echo "  -- Downloading $filename";echo
			
			#axel -n 2 -a -o "$outputdir/$feed_name/$(echo $url | sed -e 's/.*\/\([^\/]\+\)/\1/' -e 's/%20/ /g')" "$url"
			
			
			# Lets get the file
			wget -q -c -nH --progress=bar:force -P "$outputdir/$feed_name/" "$url" | tr '\r' '\n' 
			
			# adds current s sence 1970 to days to keep ( in s ) so when `date +%s` is this
			# time ppg will ice the file... 
			let "ds1970=`date +%s`+($feed_keep*86400)"
			
			# Rember we downloaded it so we dont re download
			echo $url $ds1970 "${outputdir}/${feed_name}/${filename}">>$donelist
			
			if [ "$(echo $filename | grep mp3)" != "" ]; then
			# Rename in case name is screwed up
			FILENAME2=$(echo $filename | cut -d "." -f 1)
	        mv "${outputdir}/${feed_name}/${filename}" "${outputdir}/${feed_name}/${FILENAME2}.mp3"
			# Set id3 tag 
			id3tag --artist="${feed_name}" "${outputdir}/${feed_name}/${FILENAME2}.mp3"
			fi
	done

done < $serverlist




#Time to clean house



while read dlurl dltime dlfile; do
	#echo "$dlfile dltime = $dltime current time = `date +%s`"
	cdate=`date +%s`
	#echo "${dltime}    ${cdate}"
	if [ "${dltime}" -lt "${cdate}" ] ; then
		dtest=`grep "$dlfile" "$gonefile" `
		if [ "X${dtest}" == "X" ] ; then
			rm "$dlfile"
			echo "Removed $dlfile"
			echo "$dlfile" >>"$gonefile"
		fi
	fi
	
	continue
done <"$donelist"
			
			



























# Very End of this file 'usr/local/ppg/ppg.sh' #
###END###

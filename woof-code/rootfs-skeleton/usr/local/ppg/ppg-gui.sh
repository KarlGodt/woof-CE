#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_ppg-gui.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/ppg/ppg-gui.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

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





#-------------------------------------------------------------------
# This is just in case you need to install ppg to somwhere else or 
# somthing.  You should be able to change anything here and it will 
# be the only place you need to change it
#-------------------------------------------------------------------



cd /usr/local/ppg
maindir=/usr/local/ppg/  # where all files should be
serverlistname=serverlist.txt  # the list of RSS feeds 
serverlistdir=$maindir # the dir where the list file is located
serverlist=$serverlistdir$serverlistname

#-----------------------------------
# Main menu ( not like the c main ). 
#-----------------------------------

main ()
{
Xdialog --no-tags --title "Puppy Podcast Grabber" --menu "" 20 45 15 \
1 "=======  HELP!!  =======" 2 "*  Check For New Podcast" 3 "==  VIEW          Podcast Feeds" 4 "==  ADD          A Podcast Feed" 5 "==  REMOVE    A Podcast Feed" 6 "==  EDIT          A Podcast Feed" 7 "==  EDIT          by Hand ( Caution )" 8 "=+  Quit"
}


#-----------------------------------------------
# Lists all podcast feeds from serverlist file.  Then alows the user to select one.
# Used in "edit" and "delete" menu options.
#-----------------------------------------------
listpod ()
{
plist=$(count=1
while read test_url test_keep test_name; do
	echo -n "$count"
	echo -n " \"$test_name\" "
	let "count=$count+1"
done <"${serverlistdir}${serverlistname}")

eval "Xdialog --no-tags --title \"Puppy Podcast Grabber\" --menu \"Select A Podcast\" 20 45 15 $plist"
}


listpodlong ()
{
plist=$(
count=1
while read test_url test_keep test_name; do
	let "noff=25-${#test_name}"
	noffsp=$(noff=12
count02=1
while [ $count02 -lt $noff ];do
	echo -n " "
	let "count02=count02+1"
done)
	echo -n "$count"
	echo -n " \"$test_name$noffsp $test_keep  $test_url\" "
	let "count=$count+1"
done <"${serverlistdir}${serverlistname}"
)
#echo "Xdialog --no-tags --title \"Puppy Podcast Grabber\" --menu \"Select A File\" 20 45 15 $plist"
#read
eval "Xdialog --no-tags --title \"Puppy Podcast Grabber\" --menu \"Current Podcasts\" 20 80 15 $plist"
}


## 
	if [ "$menucommand" == "1" ]; then
		t=$(listpodlong 2>&1)
	fi
menucommand="2"
while [ "$menucommand" != "" ]; do
	menucommand=$(main 2>&1)

	echo $menucommand




	#-----------------------------------------------
	# view RSS feeds See above function "listpod"
	#-----------------------------------------------
	if [ "$menucommand" == "3" ]; then
		t=$(listpodlong 2>&1)
	fi



	# Add a new RSS feed
	if [ "$menucommand" == "4" ]; then
		name=""; url="";days="7"
		ret=$(Xdialog --separator "|" --3inputsbox "Edit Podcast" 20 100 "NAME" "$name" "URL" "$url" "Days" "$days" 2>&1)
		if [ "$ret" != "" ]; then
			newname=$(echo $ret | cut -d"|" -f1)
			newurl=$(echo $ret | cut -d"|" -f2)
			newday=$(echo $ret | cut -d"|" -f3)
			echo "$newurl $newday $newname" >> $serverlist
		fi
	fi




	#------------------------------------------------------------------------------
	# Edit RSS feed info.. How long to keep files, URL and your name for the feed
	#------------------------------------------------------------------------------
	if [ "$menucommand" == "6" ]; then
		mc=$(listpod 2>&1)
		count=1
		while read test_url test_keep test_name; do
			if [ "$count" = "$mc" ]; then
				name="$test_name"
				url=$test_url
				days=$test_keep
				
			fi
			let "count=$count+1"
		done <"${serverlistdir}${serverlistname}"
		if [ "X$name" != "X" ]; then
			ret=$(Xdialog --separator "|" --3inputsbox "Edit Podcast" 20 100 "NAME" "$name" "URL" "$url" "Days" "$days" 2>&1)
			if [ "$ret" != "" ]; then
				newname=$(echo $ret | cut -d"|" -f1)
				newurl=$(echo $ret | cut -d"|" -f2)
				newday=$(echo $ret | cut -d"|" -f3)
				while read test_url test_keep test_name; do
					if [ "$test_name" = "$name" ]; then
						echo "$newurl $newday $newname" >>"${serverlistdir}.${serverlistname}.tmp" 
					else
						echo "$test_url $test_keep $test_name" >>"${serverlistdir}.${serverlistname}.tmp" 
					fi
				done <"${serverlistdir}${serverlistname}"
			rm -f $serverlist
			cat "${serverlistdir}.${serverlistname}.tmp" >$serverlist
			rm -f "${serverlistdir}.${serverlistname}.tmp"
			fi
		fi
	fi





	#-------------------------------------------------
	#Removes an RSS feed from the serverlist file
	#------------------------------------------------
	if [ "$menucommand" == "5" ]; then
		mc=$(listpod 2>&1)
		count=1
		while read test_url test_keep test_name; do
			if [ "$count" = "$mc" ]; then
				name="$test_name"
				url=$test_url
				days=$test_keep
				
			fi
			let "count=$count+1"
		done <"${serverlistdir}${serverlistname}"
		if [ "X$name" != "X" ]; then
		
				while read test_url test_keep test_name; do
					if [ "$test_name" = "$name" ]; then
						echo "$newurl $newday $newname" >>/dev/null
					else
						echo "$test_url $test_keep $test_name" >>"${serverlistdir}.${serverlistname}.tmp" 
					fi
				done <"${serverlistdir}${serverlistname}"
			rm -f $serverlist
			cat "${serverlistdir}.${serverlistname}.tmp" >$serverlist
			rm -f "${serverlistdir}.${serverlistname}.tmp"
			fi
		fi
	
	
	
	
	#--------------------------------------
	#Edit the serverlist yourself
	#--------------------------------------
	if [ "$menucommand" == "7" ]; then
		defaulttexteditor "$serverlist"
	fi




	#-------------------------------------
	# Get the files (Podcasts)
	#-------------------------------------

	if [ "$menucommand" == "2" ]; then
		rxvt -title "Puppy Podcast Grabber" -sl 1000 -e "./ppg.sh"
	fi
	
	
	
	#------------------------------------
	# Help !
	#------------------------------------
	if [ "$menucommand" == "1" ]; then
		defaultbrowser $maindir/readme.html &
	fi




	#-----------------------------------
	# Quit
	#-----------------------------------
	if [ "$menucommand" == "8" ]; then
		exit
	fi






done# Very End of this file 'usr/local/ppg/ppg-gui.sh' #
###END###

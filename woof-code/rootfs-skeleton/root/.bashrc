. /etc/bash_completion.d/bashrc

#v1.0.5 need to override TERM setting in /etc/profile...
#export TERM=xterm
# ...v2.13 removed.

#export HISTFILESIZE=2000
#export HISTCONTROL=ignoredups
#...v2.13 removed.


#------------------------------LICENSE-----------------------------------------
#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation version 2.
#
#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. <http://www.gnu.org/licenses/>.
#------------------------------

Rs(){
[ ! "$1" ] && echo "No directory/file given" && return
DIR="$1"
. /etc/DISTRO_SPECS
DISTROFOLDER=`echo "$DISTRO_NAME" "$DISTRO_VERSION" | tr ' ' '_'`
NAME_DEV_FUNC(){
#if [ -d /proc/ide ] ; then
#DEVNAME='hdb'
#else
#DEVNAME='sda'
#fi
#. /etc/rc.d/PUPSTATE
DEVNAME=`rdev | sed 's#\/dev/##; s:/::g' | tr -d '[[:blank:]]' | cut -b 1-3`
}
NAME_DEV_FUNC
FILTER_ROOTFS_FUNC(){
if [ "$DIR" = "/" ] ; then
#for i in /bin /boot /dev /etc /lib /proc /root /sbin /sys /var ; do
SR=`find / -maxdepth 1 -type d -o -type f -o -type l | sort`
SR=`echo "$SR" | grep -v -x -E '/|/mnt.*|/sys|/proc'` ###sed 's#/mnt##g'`
sleep 10s
for i in $SR ; do
echo
echo -e "Rsyncing \e[35m$i\e[39m ... "
date
rsync -urlR --devices --progress $i /mnt/${DEVNAME}12/MacPup_O2/
sleep 1s
echo
date
echo -e "\e[32m ... done \e[39m"
done
sleep 4s
fi
}

MAIN_FUNC(){
if [ -z "`mount | grep "^/dev/${DEVNAME}12"`" ] ; then

if [ ! -d /mnt/${DEVNAME}12 ] ; then
mkdir /mnt/${DEVNAME}12
fi

mount /dev/${DEVNAME}12 /mnt/${DEVNAME}12
rox /mnt/${DEVNAME}12/MacPup_O2/ &

if [ "$DIR" = "/" ] ; then
FILTER_ROOTFS_FUNC
else
rsync -url --devices --exclude=/mnt/ "$DIR" /mnt/${DEVNAME}12/MacPup_O2"`dirname $DIR`"
sleep 4s
fi

rox /mnt/${DEVNAME}12/MacPup_O2/"`dirname $DIR`"
umount /dev/${DEVNAME}12

else

if [ -n "`ls /mnt/${DEVNAME}12/*/* 2>/dev/null`" ] ; then
rox /mnt/${DEVNAME}12/MacPup_O2/ &

if [ "$DIR" = "/" ] ; then
FILTER_ROOTFS_FUNC
else
rsync -url --devices --exclude=/mnt/ "$DIR" /mnt/${DEVNAME}12/MacPup_O2"`dirname $DIR`"
fi

else

echo "ERROR"
fi
fi
}
MAIN_FUNC
}




addgroupguibabox() { #uses main_dialog() -> #addgroup [-g GID] [user_name] group_name
DESCRIPTION="addgroup is a busybox builtin that allows you to manage groups on your system."
CBTT1="-S"
CBV1="Create a system group"
EBV1="user"
EBTT1="Enter the group"
NL1="F"
CBTT2="-g"
CBV2="Use a group ID"
EBV2="GID"
EBTT2="Enter the group ID"
MAX="2"
BBCOMMAND=addgroup
`main_dialogbabox`
}

backupbabox(){
cp $1 ${1}-`date +%Y%m%d%H%M`~
}

blockadsbabox() { #tweaks /etc/hosts to ban certain sites
[ ! -f /etc/hosts.usr ] && touch /etc/hosts && cp -f /etc/hosts /etc/hosts.usr #back up original
for x in `Xdialog --stdout --checklist "Choose your ad blocking service(s)" 0 0 6 1 "mvps.org" off 2 "systcl.org" off 3 "technobeta.com" off 4 "yoyo.org" off 5 "turn off adblocking" ON 6 "manually edit" off |tr "/" " " |tr '\"' ' '`; do
   case $x in
   1)wget -c -4 -t 0 -O /tmp/adlist1 'http://www.mvps.org/winhelp2002/hosts.txt';;
   2)wget -c -4 -t 0 -O /tmp/adlist2 'http://sysctl.org/cameleon/hosts';;
   3)wget -c -4 -t 0 -O /tmp/adlist3 'http://www.technobeta.com/download/urlfilter.ini';;
   4)wget -c -4 -t 0 -O /tmp/adlist4 'http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext';;
   5)ln -sf /etc/hosts.usr /etc/hosts && exit;;
   6)[ -z $DISPLAY ] && $DIALOG --editbox /etc/hosts 0 0 && exit || defaulttexteditor /etc/hosts && exit;;#dialog has no editbox so try vi which is cli and in busybox
   *)echo $x;;
   esac
done
touch /tmp/adlist{1,2,3,4} #in case they weren't downloaded
cat /etc/hosts.usr /tmp/adlist{1,2,3,4} |sed 's/^[ \t]*//' |sed 's/\t/ /g' |sed 's/  / /g' |grep ^[1-9] |dos2unix -u |sort |uniq > /etc/hosts.adblock
ln -sf /etc/hosts.adblock /etc/hosts
rm -f /tmp/adlist{1,2,3,4} #need to remove or unwanted lists will be added
#todo add whitelist
}

brokenlinksbabox() { #find broken links in given input dir or pwd if not given
[ $1 ] && DIR=$1 || DIR=`pwd`
file `find $DIR -type l` |grep broken
}

dirtreebabox() { #show a visualization of directories and files
for x in `ls $1`; do [ -d $1/$x ] &&  echo "$2\`-{"$x && dirtree $1/$x "$2   "; done
}

fixflashbabox() { #mask your flash version as 10.1 rXXXXXX
FLASHLOC=/usr/lib/mozilla/plugins/libflashplayer.so
NEWVER="10.1 r"
VER=`strings $FLASHLOC | grep -e "^Shockwave Flash [.\d+]*" | sed -e "s/Shockwave Flash //g"` 
while [ "${#NEWVER}" -lt "${#VER}" ]
do
NEWVER=${NEWVER}9
done
sed -i "s/$VER/$NEWVER/g" $FLASHLOC
Xdialog --no-buttons --infobox "flash fixed - upgrade faked" 0 0 5000
}

getflashbabox() { #install latest flash
cd /usr/lib/mozilla/plugins && wget -o - http://fpdownload.macromedia.com/get/flashplayer/current/install_flash_player_10_linux.tar.gz |tar -xz
}

getflash9babox() { #flash9 is smaller, fewer deps and still updated
cd /usr/lib/mozilla/plugins && wget -o - http://download.macromedia.com/pub/flashplayer/installers/current/9/install_flash_player_9.tar.gz |tar -xz	
}

getinputbabox() { #DIALOG box to return user input to stdout
	setDIALOG
	$DIALOG --stdout --inputbox "Enter your $@ input and select OK." 0 0
}

googlebabox() { #searches google for $@ or if blank uses $DIALOG
[ $@ == "" ] && QUERY=`getinput search` || QUERY=$@
defaultbrowser http://www.google.com/search?q=$QUERY
}

gtkdialog_menubabox() { #Set up an external menu for your gtkdialog gui
#Sigmund Berglund, 2010 version 0.3

ITEMS=""
ICONS=""
HEIGHT=20
echo -n > /tmp/OUTPUT

#parameters
while [ $# != 0 ]; do
	I=1
	while [ $I -le `echo $# | wc -c` ]; do
		case $1 in
		-h|--help)
			echo 'Usage: gtkdialog_menu [OPTION] "stock-icon1,menuitem1" "stock-icon2,menuitem2" ...
example: gtkdialog_menu -m middle "gtk-open,Open file" "gtk-save,Save file"
Options
  -h         Show this information
  -m CLICK   Activate menu by clicking mousebutton
             This uses $BUTTON from main gtkdialog gui
                left
                middle
                right (default)'
            exit
            ;;
		-m) #left-, mid- or right-click
			export MOUSE="$2"
			shift
			;;
		*)
			[ ! "$1" ] && break
			ICON=`echo "$1" | cut -d',' -f1`
			LABEL=`echo "$1" | cut -d',' -f2`
			if [ "$ICON" = "seperator" ]; then
				ICONS="$ICONS"'<text height-request="2"><label>""</label></text>'
				ITEMS="$ITEMS"'<entry height-request="2"></entry>'
			else
				ITEMS="$ITEMS"'<button height-request="20" xalign="0" can-focus="no" relief="2"><label>'"$LABEL"'</label><action>echo '"$LABEL"' > /tmp/OUTPUT</action><action>EXIT:exit</action></button>'
				ICONS="$ICONS"'<pixmap height-request="20" icon_size="1"><input file stock="'"$ICON"'"></input></pixmap>'
			fi
			HEIGHT=$((HEIGHT+20))
			;;
		esac
		shift
		I=$[$I+1]
	done
done

#check if left-click or right-click
case $MOUSE in
	left)	[ ! $BUTTON = 1 ] && exit;;
	middle)	[ ! $BUTTON = 2 ] && exit;;
	*)		[ ! $BUTTON = 3 ] && exit;;
esac


#show menu
export gtkdialog_menu='
<window title="menu" decorated="false"  height-request="'$HEIGHT'" skip_taskbar_hint="true" window_position="2">
 <hbox>
  <vbox>
   '$ICONS'
  </vbox>
  <vbox>
   '$ITEMS'
  </vbox>
 </hbox>
 <action signal="focus-out-event">EXIT:exit</action>
</window>'
gtkdialog3 -p gtkdialog_menu > /dev/null
cat /tmp/OUTPUT #send output to stdout
}


helpbabox() { #usage: bashbox help [function]
PATT=`echo "$1" | sed 's#babox##g ; s#$#babox#'` 
##grep "$PATT() { #" /usr/share/bashbox/bbfxns.sh #list fxn(s)
##grep "$PATT() { #" /root/.bashrc
##grep "$1() { #" /root/.bashrc
grep "$1" /root/.bashrc | grep '() { #'
}

launcherbabox() { #gtkdialog basic launcher program like gexec + dropdown menu
for x in `ls /usr/share/applications/*.desktop`; do I=$I"<item>""`grep "^Exec=" $x |cut -d = -f 2`""</item>"; done
export D="<vbox><entry editable=\"true\"><variable>E</variable></entry>
<combobox><variable>C</variable>"$I"</combobox><button ok></button></vbox>"
eval `gtkdialog3 --program=D` && [ "$E" == "" ] && $C || $E
}

logstdoutbabox() { #usage: logstdout logfile.log command arguments (records normal output)
F=$1
shift
$@
}

logstderrbabox() { #usage: logstderr logfile.log command arguments (records error output)
F=$1
shift
$@ 2>$F
}

logallbabox() { #usage: logall logfile.log command arguments (records error & normal output)
F=$1
shift
$@ 2>&1 |tee $F #using tee instead of just ">" so the output is not silenced
}

longhelpbabox(){ #usage: bashbox longhelp
grep "babox()" /usr/share/bashbox/bbfxns.sh #}list fxns
}

main_dialogbabox() { #parses template of vars to gen and eval a dialog then return the results
HDR="<window title=\"$BBCOMMAND\" icon-name=\"gtk-index\"> <frame $BBCOMMAND GUI>"
NA="<hbox><button><label>$BBCOMMAND Not Yet Implemented</label><action>$BROWSER /usr/share/doc/bbgui.htm & </action></button></hbox>"
FTR="<hbox><button ok></button><button><input file icon=\"gtk-quit\"></input><label>QUIT</label><action type=\"exit\">EXIT_NOW</action></button></hbox></frame></window>"

echo $HDR >/dev/shm/MAIN_DIALOG
[ "$DESCRIPTION" != "" ] && echo "<text><label>$DESCRIPTION</label></text>" >>/dev/shm/MAIN_DIALOG
[ "$ICON" != "" ] && echo "<pixmap icon_size=\"6\"><input file stock=\"$ICON\"></input></pixmap>" >>/dev/shm/MAIN_DIALOG
LNNO=1
#could do while $CB$EB$... !=""  :would eliminate annoying MAX parameter
until [ $LNNO -gt $MAX ]
do
	#you can't do ${VAR$NUMBER} and get the value of $VAR1 with NUMBER=1 so...
	
	#to handle multiple items in one hbox
	NEWLINE=\${NL$LNNO} && NEWLINE=`eval echo $NEWLINE`
	[ "$SAMELINE" != "F" ] && echo "<hbox>" >>/dev/shm/MAIN_DIALOG

	#checkboxes
	CBTOOLTIP=\${CBTT$LNNO} && CBTOOLTIP=`eval echo $CBTOOLTIP`
	CBOX=\${CBV$LNNO} && CBOX=`eval echo $CBOX`
	#CBDEFAULT not implemented yet
	[ "$CBOX" != "" ] && echo "<checkbox tooltip-text=\"$CBTOOLTIP\"><label>$CBOX</label><variable>CBOX"$LNNO"</variable></checkbox>" >>/dev/shm/MAIN_DIALOG
	
	#radiobuttons
	RADIOTOOLTIP=\${RBTT$LNNO} && RADIOTOOLTIP=`eval echo $RADIOTOOLTIP`
	RADIO=\${RBV$LNNO} && RADIO=`eval echo $RADIO`
	#RBDEFAULT
	[ "$RADIO" != "" ] && echo "<radiobutton tooltip-text=\"$RADIOTOOLTIP\"><label>$RADIO</label><variable>RB"$LNNO"</variable></radiobutton>" >>/dev/shm/MAIN_DIALOG

	#entry boxes
	ENTRY=\${EBV$LNNO} && ENTRY=`eval echo $ENTRY` && [ "$ENTRY" != "" ] && ENTRY="<default>$ENTRY</default>"
	ENTRYTOOLTIP=\${EBTT$LNNO} && ENTRYTOOLTIP=`eval echo $ENTRYTOOLTIP`
	[ "$ENTRYTOOLTIP" != "" ] && echo "<entry editable=\"true\" tooltip-text=\"$ENTRYTOOLTIP\"><variable>ENTRY"$LNNO"</variable>$ENTRY</entry>" >>/dev/shm/MAIN_DIALOG

	#directory selector
	DIR==\${D$LNNO} && DIR=`eval echo $DIR` && [ "$DIR" != "" ] && DIR="<default>$DIR</default>"
	DIRTOOLTIP=\${DTT$LNNO} && DIRTOOLTIP=`eval echo $DIRTOOLTIP`
	[ "$DIRTOOLTIP" != "" ] && echo "<entry editable=\"true\" accept=\"directory\"  tooltip-text=\"$DIRTOOLTIP\"><variable>DIR"$LNNO"</variable>$DIR</entry><button><input file stock=\"gtk-open\"></input><variable>FILE_BROWSE_DIRECTORY</variable><action type=\"fileselect\">DIR"$LNNO"</action></button>" >>/dev/shm/MAIN_DIALOG

	#file selector
	FILE=\${F$LNNO} && FILE=`eval echo $FILE` && [ "$FILE" != "" ] && FILE="<default>$FILE</default>"
	FILETOOLTIP=\${FTT$LNNO} && FILETOOLTIP=`eval echo $FILETOOLTIP`
	[ "$FILETOOLTIP" != "" ] && echo "<entry editable=\"true\" accept=\"filename\"  tooltip-text=\"$FILETOOLTIP\"><variable>FILE"$LNNO"</variable>$FILE</entry><button><input file stock=\"gtk-file\"></input><variable>FILE_BROWSE_FILENAME</variable><visible>enabled</visible><action type=\"fileselect\">FILE"$LNNO"</action></button>" >>/dev/shm/MAIN_DIALOG

	#combobox
	COMBO=\${C$LNNO} && COMBO=`eval echo $COMBO`
	COMBOTOOLTIP=\${CTT$LNNO} && COMBOTOOLTIP=`eval echo $COMBOTOOLTIP`
	if [ "$COMBO" != "" ]; then
	for ONE in $COMBO
	do
	ITEMS="${ITEMS}<item>${ONE}</item>"
	done
	[ "$COMBO" != "" ] && echo "<combobox tooltip-text=\"$COMBOTOOLTIP\"><variable>COMBO"$LNNO"</variable>"$ITEMS"</combobox>" >>/dev/shm/MAIN_DIALOG
	fi
	
	#to handle multiple items in one hbox
	[ "$NEWLINE" != "F" ] && echo "</hbox>" >>/dev/shm/MAIN_DIALOG
	SAMELINE=$NEWLINE
	
	#HAD TO DO IT THIS WAY BECAUSE VARIABLES WEREN'T RECOGNIZED
	let LNNO+=1
done
echo $FTR >>/dev/shm/MAIN_DIALOG

export DLG=`cat /dev/shm/MAIN_DIALOG`
CHOOSER2=`gtkdialog3 --program=DLG --center`
eval "$CHOOSER2"

LNNO=1
#could do while $CB$EB$... !=""  :would eliminate annoying LNNO & MAX parameter
until [ $LNNO -gt $MAX ]
do
	#CHECKBOXES
	CBOX=\${CBOX$LNNO} && CBOX=`eval echo $CBOX`
	CBTT=\${CBTT$LNNO} && CBTT=`eval echo $CBTT`
	[ "$CBOX" == "true" ] && BBCOMMAND=$BBCOMMAND" "$CBTT
	#RADIOBUTTONS
	RB=\${RB$LNNO} && RB=`eval echo $RB`
	RBTT=\${RBTT$LNNO} && RBTT=`eval echo $RBTT`
	[ "$RB" == "true" ] && BBCOMMAND=$BBCOMMAND" "$RBTT
	#ENTRYBOXES
	EB=\${ENTRY$LNNO} && EB=`eval echo $EB` && [ "$EB" != "" ] && BBCOMMAND=$BBCOMMAND" "$EB
	#DIRECTORIES
	DIR=\${DIR$LNNO} && DIR=`eval echo $DIR` && [ "$DIR" != "" ] && BBCOMMAND=$BBCOMMAND" "$DIR
	#FILES
	FILE=\${FILE$LNNO} && FILE=`eval echo $FILE` && [ "$FILE" != "" ] && BBCOMMAND=$BBCOMMAND" "$FILE
	#COMBOBOXES
	COMBO=\${COMBO$LNNO} && COMBO=`eval echo $COMBO` && [ "$COMBO" != "" ] && BBCOMMAND=$BBCOMMAND" "$COMBO
	let LNNO+=1
done

echo $BBCOMMAND #echo allows calling function to exec if called as `main_dialogbobox` or ???
}

maindialogtemplatebabox() { #example of how to use main_dialog
ICON="gtk-properties"
DESCRIPTION="This is just an example of how it works"
CBTT1="THIS PARAMETER GETS PASSED TO THE MAIN PROGRAM"
CBV1="USER INFO FOR PARAMETER THAT GETS PASSED TO THE MAIN PROGRAM"
#NL1="F" #THIS WILL PUT *1 AND *2 ON THE SAME LINE
EBV2="DEFAULT ENTRY"
EBTT2="TELL THEM WHAT YOU WANT TO ENTER HERE"
NL2="F"
D3="/root"
DTT3="TELL THE USER WHAT TYPE OF DIR YOU ARE LOOKING FOR"
F4="/bin/busybox"
FTT4="TELL THE USER WHAT TYPE OF DIR YOU ARE LOOKING FOR"
NL4="F"
C5="THIS IS A LIST OF CHOICES"
CTT5="A LITTLE DESCRIPTION ABOUT YOUR CHOICES"
NL5="F"
RBV6="A"
RBTT6="-A"
NL6="F"
RBV7="B"
RBTT7="-B"
NL7="F"
RBV8="C"
RBTT8="-C"
NL8="F"
RBV9="D"
RBTT="-D"
MAX="9" #only necessary because my bash skills and time are limited
main_dialogbaboxbabox #surround with ` to execute the command or it just gets echoed
}

#partview2(){ #TODO convert Barry's to use faster percentbar()}

percentbarbabox() { #usage: "$0" XX% name=filename fgcolor=XXX bgcolor=XXX height=XXX width=XXX [vertical]
FILENAME=barimage
FGCOLOR=\#000
BGCOLOR=None
PERCENT=50
WIDTH=100
HEIGHT=24
BARSTRING=""
q=0 #should have used for loops
y=0 #not while loops - oops
#get values from input
for x in $@; do
case $x in
   width*)WIDTH=`echo $x |cut -d = -f 2`;;
   height*)HEIGHT=`echo $x |cut -d = -f 2`;;
   fg*)FGCOLOR=`echo $x |cut -d = -f 2`
      [ "$FGCOLOR" != "None" ] && FGCOLOR=\#$FGCOLOR;;
   bg*)BGCOLOR=`echo $x |cut -d = -f 2`
      [ "$BGCOLOR" != "None" ] && BGCOLOR=\#$BGCOLOR;;
   name*)FILENAME=`echo $x |cut -d = -f 2`;;
   *%)PERCENT=`echo $x |cut -d % -f 1`;;
   vert*)VERTICAL="true";;
   *)   echo "usage "$0" XX% name=filename fgcolor=XXX bgcolor=XXX height=XXX width=XXX [vertical]
      colors can be 3 or 6 digit hexadecimal or None ... default is horizontal bars" && exit
      ;;
esac
done


#write header to file
echo '/* XPM */' >${FILENAME}.xpm
echo 'static char *'$FILENAME'_xpm[] = {' >>${FILENAME}.xpm
echo '"'$WIDTH $HEIGHT '2 1",' >>${FILENAME}.xpm
echo '"0 c '$BGCOLOR'",' >>${FILENAME}.xpm
echo '"1 c '$FGCOLOR'",' >>${FILENAME}.xpm

if [ "$VERTICAL" == "true" ];then #vertical bars
BARTOP=$(($HEIGHT*$PERCENT/100))
#generate each line of the image
   while [ "$q" -lt $HEIGHT ]; do
   q=$(($q + 1))
      if [ "$q" -lt $BARTOP ];then
         while [ "$z" -lt $WIDTH ]; do
            BARSTRING=${BARSTRING}0
            z=$(($z + 1))
         done
      else
         while [ "$z" -lt $WIDTH ]; do
            BARSTRING=${BARSTRING}1
            z=$(($z + 1))
         done
      fi
   echo '"'$BARSTRING'"' >>${FILENAME}.xpm
   BARSTRING=""
   z=0
   done
else #horizontal bars
#generate one line of the image
   BARMAX=$(($WIDTH*$PERCENT/100))
   while [ "$q" -lt $BARMAX ]; do
      q=$(($q + 1))
      BARSTRING=${BARSTRING}1
   done
   while [ "$q" -le $WIDTH ]; do
      BARSTRING=${BARSTRING}0
      q=$(($q + 1))
   done
#write a line for each pixel of height
   while [ "$y" -le $HEIGHT ]; do
   echo '"'$BARSTRING'"' >>${FILENAME}.xpm
      y=$(($y + 1))
   done
fi

echo '};' >>${FILENAME}.xpm
}

pgetbabox() { #download $1 to HOME/my-documents with axel
cd ${HOME}/my-documents
rxvt -name pget +sb -bg orange -geometry 80x2 -e axel -S 3 $1
}

pickdatebabox() { #choose a date - optional input: $1="text" $2=day $3=month $4=year
setDIALOG
$DIALOG --stdout --calendar "Please select a date $1" 0 0 $2 $3 $4
}

picktimebabox() { #output a time - optional input: $1="text" $2=hours $3=minutes $4=seconds
setDIALOG
$DIALOG --stdout --timebox "Please select a time $1" 0 0 $2 $3 $4
}

pickfilebabox() { #DIALOG box to return a user chosen file to stdout
	setDIALOG
	$DIALOG --stdout --fselect "Please choose your $@ file." 0 0
}

pickXcolorbabox() { #DIALOG box to return a user chosen X color to stdout
	setXCOLORS
	Xdialog --stdout --combobox "Please choose color $@" 0 0 $XCOLORS
}

play_aubabox() { #just sends $@ to /dev/audio
cat $@ > /dev/audio
}

play_wavbabox() { #just sends $@ to /dev/dsp
cat $@ > /dev/dsp
}

reset_mixersbabox() { #from /usr/sbin/alsaconf... was called from rc.local0.
 amixer -s -q <<EOF
set Master 75% unmute
set Master -12dB
set 'Master Mono' 75% unmute
set 'Master Mono' -12dB
set Front 75% unmute
set Front -12dB
set PCM 90% unmute
set PCM 0dB
mixer Synth 90% unmute
mixer Synth 0dB
mixer CD 90% unmute
mixer CD 0dB
#mute mic
set Mic 0% mute
#ESS 1969 chipset has 2 PCM channels
set PCM,1 90% unmute
set PCM,1 0dB
#Trident/YMFPCI/emu10k1
set Wave 100% unmute
set Music 100% unmute
set AC97 100% unmute
#CS4237B chipset:
set 'Master Digital' 75% unmute
#Envy24 chips with analog outs
set DAC 90% unmute
set DAC -12dB
set DAC,0 90% unmute
set DAC,0 -12dB
set DAC,1 90% unmute
set DAC,1 -12dB
#some notebooks use headphone instead of master
set Headphone 75% unmute
set Headphone -12dB
set Playback 100% unmute
#turn off digital switches
set "SB Live Analog/Digital Output Jack" off
set "Audigy Analog/Digital Output Jack" off
EOF
}

setDIALOGbabox() { #sets $DIALOG to Xdialog if in X or dialog if in console
	[ -n "$DISPLAY" ] && [ `which Xdialog` ] && DIALOG="Xdialog" || DIALOG=dialog
}

setjwmbgbabox() { #TODO tweaks ... include $HOME/.jwmbg in the jwmrc template
setDIALOG
JWMBG="<JWM><Desktops count=\"2\"><Desktop>"
case `$DIALOG --stdout --radiolist "
Setting background/wallpaper on your jwm-desktop.
What type of background do you want to use?
" 0 0 8 1 Cancel on 2 SolidColor 0 3 ColorGradient 0 4 StretchedImage 0 5 TiledImage 0 6 ExternalCommand 0 7 None 0` in
	1)return 0;;
	2)JWMBG=$JWMBG"<Background type=\"solid\">"`pickXcolor`"</Background>";;
	3)JWMBG=$JWMBG"<Background type=\"gradient\">"`pickXcolor 1`":"`pickXcolor 2`"</Background>";;
	4)JWMBG=$JWMBG"<Background type=\"image\">"`pickfile image`"</Background>";;
	5)JWMBG=$JWMBG"<Background type=\"tile\">"`pickfile image`"</Background>";;
	6)JWMBG=$JWMBG"<Background type=\"command\">"`pickfile executable`"</Background>";;
	*);;
esac
JWMBG=$JWMBG"</Desktops></JWM>"
echo $JWMBG >${HOME}/.jwmbg
#$DIALOG --infobox "$JWMBG" 0 0 #debug
}

#setjwm* not yet implemented
#setjwmbindings(){ #TODO complete see existing utils}
#setjwmdrives(){ #TODO complete see pupngo to implement }
#setjwmicons(){ #TODO complete see forum thread to implement }
#setjwmstyle(){ #TODO complete see existing utils to implement }
#setjwmtray(){ #TODO complete see $HOME/.jwmrc-tray to implement }

setXCOLORSbabox() { #sets $XCOLORS from ...rgb.txt
	export XCOLORS=`cut -s -f3,4 /usr/X11R7/lib/X11/rgb.txt |grep -v " "|grep -v "rey" |sed "s/\t//" |sort|uniq` 
}

silentbabox() { #run a command with no output #usage: silent command arguments
$@ 2>&1 >/dev/null
}

silentlogbabox() { #usage: silentlog logfile.log command arguments (records only normal output)
F=$1
shift
$@ > $F #using > instead of just tee so the output is silenced
}

silentlogallbabox() { #usage: silentlogall logfile.log command arguments (records error & normal output)
F=$1
shift
$@ 2>&1 > $F #using > instead of just tee so the output is silenced
}

silentlogerrbabox() { #usage: silentlogerr logfile.log command arguments (records only error output)
F=$1
shift
$@ 2> $F #using > instead of just tee so the output is silenced
}

test_program_with_LANGbabox() { #$1=LANG followed by command to test
REAL_LANG=$LANG
export LANG=$1
shift #removes $1 from $@
$@
export LANG=$REAL_LANG
}

tolowerbabox() { #change input $@ to lower case
echo "$@" | tr [:upper:] [:lower:]
}

toupperbabox() { #change input $@ to upper case
echo "$@" | tr [:lower:] [:upper:]
}

treebabox() { #show a cli visualization of directories and files
for x in `ls $1`; do [ -d $1/$x ] &&  echo "$2\`-{"$x && tree $1/$x "$2   " || echo "$2\`-<"$x; done
}

tweetbabox() { #send a tweet $1 is username $2 is password "$3" is the tweet (must be in quotes)
U=$1;P=$2
shift 2
T=$@
#i=0
#while (( i++ < ${#MyString} ) & ( $i < 160 ))
#do
#   T=$T$(expr substr "$MyString" $i 1)
#done
#curl -u $U:$P -d status="$T" http://twitter.com/statuses/update.xml -o /dev/null
#[ "${#T}" -gt "160"] && tweet $U $P "`echo $@ |sed "s/$T//g"`"
[ "${#T}" -lt "160" ] && curl -u $U:$P -d status="$T" http://twitter.com/statuses/update.xml -o /dev/null || echo "tweets must be < 160 characters"
}

webcam2avibabox() { #capture your webcam to HOME/webcam.avi - requires ffmpeg & rxvt
rxvt +sb -bg orange -geometry 80x2 -e ffmpeg -y -f oss -i /dev/audio -f video4linux2 -s qvga -i /dev/video0 ${HOME}/webcam.avi
}

workingbabox(){ #vert pos, horz pos, message
#!/bin/sh
POS="\E[$1;$2H"
V=$1;H=$2
shift 2
echo $#
clear
echo -e $POS"|    {$@}    |"
sleep .5
clear
echo -e $POS"|   { $@ }   |"
sleep .5
clear
echo -e $POS"|  {  $@  }  |"
sleep .5
clear
echo -e $POS"| {   $@   } |"
sleep .5
clear
echo -e $POS"|{    $@    }|"
sleep 1
clear
echo -e $POS"| {   $@   } |"
sleep 1
clear
echo -e $POS"|  {  $@  }  |"
sleep 1
clear
echo -e $POS"|   { $@ }   |"
sleep 1
echo $#
working $V $H $@	
}

X2avibabox() { #capture your desktop to HOME/x11-session.avi - ffmpeg needs x11grab
rxvt +sb -bg orange -geometry 80x2 -e ffmpeg -f oss -i /dev/audio -f x11grab -s 1200x800 -r 5 -i :0.0 ${HOME}/x11-session.avi
}

Xsetvolumebabox() { #set volume with slider
VOLUME=`amixer get Master | grep 'Mono:' | cut -d '%' -f 1 | cut -d '[' -f 2`
VOLUME=`Xdialog --stdout --under-mouse --title "VolumeControl" --buttons-style text --icon /usr/share/mini-icons/audio-volume-high.png \
--ok-label Set --cancel-label Advanced --rangebox "Master Volume" 9 30 0 100 $VOLUME`
[ $? -eq 1 ] && rxvt +sb -geometry 90x20 -e alsamixer || amixer set Master $VOLUME"%"
#aplay sound.wav here?
}

Xshowimagebabox() { #quick view of image
Xdialog --icon $1 --no-buttons --msgbox "" 0 0
}


#these are full programs in testing for now so not in the alphabetical listing yet
#the "internal" functions have no space in (){ so they won't get a symlink
#I may use this fact to know which fxns to automatically export

#begin pprocess
box_okbabox(){ # $1=title $2=TXT1 $3=TXT2 $4=IMG $5=FRAME
[ -z "$5" ] && echo "not enough values to box_ok" && exit 1
export ok_box="
<window title=\"$1\" icon-name=\"gtk-execute\">
 <vbox>
  <frame $5>
   <pixmap icon_size=\"6\"><input file stock=\"gtk-$4\"></input></pixmap>
   <text use-markup=\"true\"><label>\"$2\"</label></text>
   <text><label>\"$3\"</label></text>
  </frame>
  <hbox>
   <button can-default=\"true\" has-default=\"true\" use-stock=\"true\">
    <input file icon=\"gtk-apply\"></input>
    <label>Ok</label>
   </button>
  </hbox>
 </vbox>
</window>"
gtkdialog3 --program=ok_box --center
}

pprocess_funcbabox(){ #functions for pprocess
case $1 in
-action)
	if [ ! "$ACTION" ]; then
		TXT1="$LOC131" 
		box_okbabox Pprocess "$TXT1" "$TXT1" dialog-error Pprocess_Error
	fi
	case $ACTION in
		"$LOC101") kill -9 `echo "$LIST" | awk '{print $1}'`;;
		"$LOC104 - $LOC105") renice -10 `echo "$LIST" | awk '{print $1}'`;; #high
		"$LOC104 - $LOC106") renice 0 `echo "$LIST" | awk '{print $1}'`;; #normal
		"$LOC104 - $LOC107") renice 10 `echo "$LIST" | awk '{print $1}'`;; #low
		*)	#send signal
			KILL_SIGNAL="`echo "$ACTION" | cut -d ' ' -f 3`"
			TMP="-`echo "$KILL_SIGNAL" | cut -d " " -f 1`"
			if [  $TMP = "-0" ]; then TMP=""; fi
			kill $TMP `echo "$LIST" | awk '{print $1}'`
	esac
	;;
-set_filter)
	echo "$FILTER_STRING" > /tmp/pprocess-filter
	;;
-filter_short)
	echo "PID         CMD" > /tmp/pprocess-ps_source
	ps -a | awk '{print $4 "\t" $1}' |sort |grep -v CMD |grep -v awk |grep -v ps-FULL |grep -v grep |grep -v sort| awk '{print $2 "\t" $1}' >> /tmp/pprocess-ps_source
	FILTER_STRING=($(<"/tmp/pprocess-filter"))
	grep -i "$FILTER_STRING" /tmp/pprocess-ps_source > /tmp/pprocess-ps
	;;
-filter_long)
	ps -u > /tmp/pprocess-ps_source
	FILTER_STRING=($(<"/tmp/pprocess-filter"))
	grep -i "$FILTER_STRING" /tmp/pprocess-ps_source > /tmp/pprocess-ps
	;;
-filter)
	ps > /tmp/pprocess-ps_source
	FILTER_STRING=($(<"/tmp/pprocess-filter"))
	grep -i "$FILTER_STRING" /tmp/pprocess-ps_source > /tmp/pprocess-ps
	;;
-logfile)
	if [ $LOG_FILE = top ]; then
		rxvt -name pburn -bg black -fg green -geometry 80x20 -title "Pprocess - Running processes" -e top
	fi
	Xdialog --title "Pprocess" --screen-center --fixed-font --no-ok --cancel-label "$LOC_CANCEL" --tailbox $LOG_FILE 500x500
	;;

esac
}

pprocess_locals_en_USbabox(){ #english translation for pprocess
set -a

export LOC_OK="Ok" \
LOC_CANCEL="Cancel" \
LOC_ERROR="Error" \
\
LOC100="Process manager" \
LOC101="End process (kill)" \
LOC102="Processes" \
LOC103="Messages" \
LOC104="CPU priority" \
LOC105="High" \
LOC106="Normal" \
LOC107="Low" \
LOC108="Filter" \
LOC109="Action" \
LOC111="Send signal" \
LOC112="Running processes" \
LOC113="Kernel messages" \
LOC114="Graphic server" \
LOC115="Kernel boot" \
LOC116="Puppy boot" \
LOC118="Power off" \
LOC119="Restart system" \
LOC120="Double-click to watch messages" \
\
LOC131="No action defined" \
\
LOC200="Use filter to show only wanted processes. \
Keep field blank to show all processes." \
LOC201="What should happen to the process 
when click on it."
}

pprocess_locals_de_DEbabox(){ #german translation for pprocess
export LOC_OK="Ok" \
LOC_CANCEL="Abbruch" \
LOC_ERROR="Fehler" \
LOC100="Prozess-Manager" \
LOC104="CPU-Priorität" \
LOC105="Hoch" \
LOC106="Normal" \
LOC107="Niedrig" \
LOC108="Filter" \
LOC109="Aktion" \
LOC110="tut nichts" \
LOC111="Sende Signal" \
LOC117="Anschauen" \
LOC118="System abschalten (Power off)" \
LOC131="Keine Aktion definiert" \
LOC200="Benutze Filter, um gewünschte Prozesse anzuzeigen.
Feld leer lassen, um alle zu zeigen." \
LOC201="Was soll mit dem Prozess geschehen, der angeklickt wurde?"
}

pprocess_locals_fr_FRbabox(){ #french translation for pprocess
export LOC_OK="Ok" \
LOC_CANCEL="Annuler" \
LOC_ERROR="Erreur" \
LOC100="Gestionnaire des processus" \
LOC101="Terminer le processus (tuer)" \
LOC102="Processus" \
LOC103="Messages" \
LOC104="Priorité du CPU" \
LOC105="Haute" \
LOC106="Normale" \
LOC107="Basse" \
LOC108="Filter" \
LOC109="Action" \
LOC111="Envoyer le signal" \
LOC112="Processus en cours" \
LOC113="Messages du noyau" \
LOC114="Serveur graphique" \
LOC115="Démarrage du noyau" \
LOC116="Démarrage de Puppy" \
LOC118="Eteindre" \
LOC119="Relancer le système" \
LOC120="Double-cliquer pour voir les messages" \
LOC131="Aucune action définie"
}

pprocess_locals_nb_NObabox(){
export LOC_OK="Ok" \
LOC_CANCEL="Avbryt" \
LOC_ERROR="Feilmelding" \
LOC100="Prosess-håndtering" \
LOC104="CPU prioritet" \
LOC105="Høy" \
LOC106="Normal" \
LOC107="Lav" \
LOC108="Filter" \
LOC109="Handling" \
LOC111="Send signal" \
LOC117="Overvåk system-logg" \
LOC118="Slå av PC" \
LOC131="Ingen handling er definert" \
LOC200="Bruk filter for å vise ønsket prosess.
Et tomt felt viser alle prosesser." \
LOC201="Hva skal skje når du klikker på en prosess med musen."
}

pprocessbabox() { #process manager
#Copyright 2007,2008,2009,2010 Sigmund Berglund
export -f pprocess_funcbabox box_okbabox pprocess_locals_en_USbabox

case $1 in
	-a)FILTER=-filter_short;;
	-u)FILTER=-filter_long;;
	*)FILTER=-filter;;
esac


VERSION=2.2.T

#parameters
while [ $# != 0 ]; do
	I=1
	while [ $I -le `echo $# | wc -c` ]; do #check -xft
		if [ `echo $1 | grep s` ]; then SHUTDOWN=true; fi
		if [ `echo $1 | grep h` ]; then
			echo 'Options
  -s          Show Shutdown/Reboot button
  -h          show this help message.'
  			exit
		fi
		shift
		I=$[$I+1]
	done
done

#set language
pprocess_locals_en_USbabox #always run to fill gaps in translation
pprocess_locals_"$LANG"babox 2> /dev/null

#use monofont in <tree>
echo 'style "specialmono"
{
  font_name="Mono 12"
}
widget "*mono" style "specialmono"
class "GtkTree*" style "specialmono"' > /tmp/gtkrc_mono

export GTK2_RC_FILES=/tmp/gtkrc_mono:/root/.gtkrc-2.0 
#---

echo -n > /tmp/pprocess-filter

pprocess_funcbabox $FILTER

S='
<window title="Pprocess '$VERSION' - '$LOC100'" icon-name="gtk-execute" default_height="450" default_width="700">
<hbox>
 <tree headers_visible="false" rules_hint="true" hover-selection="true">
  <label>hei</label>
  <variable>LIST</variable>
  <input>cat /tmp/pprocess-ps</input>
  <action signal="button-press-event">pprocess_funcbabox -action</action>
  <action signal="button-press-event">pprocess_funcbabox '$FILTER'</action>
  <action signal="button-press-event">refresh:LIST</action>
 </tree>
 <notebook labels="'$LOC102'|'$LOC103'">
  <frame>
   <vbox tooltip-text="'$LOC200'">
     <entry activates-default="true">
      <variable>FILTER_STRING</variable>
      <default>Search text</default>
      <width>100</width><height>25</height>
      <action signal="key-release-event">pprocess_funcbabox -set_filter</action>
     </entry>
    <hbox>
     <button relief="2" can-default="true" has-default="true" use-stock="true" height-request="1" width-request="1">
      <action>pprocess_funcbabox '$FILTER'</action>
      <action>refresh:LIST</action>
     </button>
    </hbox>
    <progressbar height-request="2">
     <input>while [ A ]; do pprocess_funcbabox '$FILTER'; echo; echo 100; sleep 4; done</input>
     <action>refresh:LIST</action>
    </progressbar>
   </vbox>
   <tree tooltip-text="'$LOC201'" headers_visible="false">
    <label>a</label>
    <variable>ACTION</variable>
    <height>100</height><width>270></width>
    <item stock="gtk-cancel">'$LOC101'</item>
    <item stock="gtk-nothing">""</item> 
    <item stock="gtk-go-up">'$LOC104' - '$LOC105'</item> 
    <item stock="gtk-remove">'$LOC104' - '$LOC106'</item> 
    <item stock="gtk-go-down">'$LOC104' - '$LOC107'</item> 
    <item stock="gtk-nothing">""</item> 
    <item stock="gtk-nothing">'$LOC111' 1 - Hangup</item> 
    <item stock="gtk-nothing">'$LOC111' 2 - Interrupt</item> 
    <item stock="gtk-nothing">'$LOC111' 3 - Quit</item> 
    <item stock="gtk-nothing">'$LOC111' 9 - Kill</item> 
    <item stock="gtk-nothing">'$LOC111' 14 - Alarm</item> 
    <item stock="gtk-nothing">'$LOC111' 15 - Terminate</item> 
    <item stock="gtk-nothing">'$LOC111' 18 - Continue</item> 
    <item stock="gtk-nothing">'$LOC111' 19 - Stop</item>
   </tree>'
  [ "$SHUTDOWN" = "true" ] && S=$S'
  <vbox>
  <hbox homogeneous="true"><hbox>
   <pixmap icon_size="5"><input file stock="gtk-refresh"></input></pixmap>
   <button width-request="180">
    <label>" '$LOC119' "</label>
    <action>reboot</action>
   </button>
   <pixmap icon_size="5"><input file stock="gtk-refresh"></input></pixmap>
  </hbox></hbox>
  <hbox homogeneous="true"><hbox>
   <pixmap icon_size="5"><input file stock="gtk-stop"></input></pixmap>
   <button width-request="180">
    <label>" '$LOC118' "</label>
    <action>wmpoweroff</action>
   </button>
   <pixmap icon_size="5"><input file stock="gtk-stop"></input></pixmap>
  </hbox></hbox>
  </vbox>'
   S=$S'</frame>
  <frame>
   <text><label>'$LOC120'</label></text>
   <text><label>""</label></text>
   <tree rules_hint="true" headers_visible="false" exported_column="1">
    <variable>LOG_FILE</variable>
    <label>a|b</label>
    <item>'$LOC112'|top</item>
    <item>'$LOC113'|/var/log/messages</item>
    <item>'$LOC114'|/var/log/Xorg.0.log</item>
    <item>'$LOC115'|/tmp/bootkernel.log</item>
    <item>'$LOC116'|/tmp/bootsysinit.log</item>
    <action>pprocess_funcbabox -logfile</action>
   </tree>
   </frame>  
  </notebook>
</hbox>
</window>'
export PPROCESS="`echo "$S" | sed 's/##.*//'`" #I use double hash (##) for comments. --> as #FF0000
echo "$PPROCESS" > /root/gtk #Zigbert, why is this here? -Technosaurus

gtkdialog3 -p PPROCESS
}
#end pprocesss

#begin from ffconvert
errmsgbabox() { 
  #echo $0 $@ >&2
  [ "$XPID" != "" ] && kill $XPID >/dev/null 2>&1
  MARK="error"
  TIMEOUT=0
  BUTTONS="<hbox>$EXTRABUTTON<button ok></button></hbox>"
  case "$1" in
   error)  MARK="error";shift;;
   warning) MARK="warning";shift;;
   info) MARK="info";shift;;
   yesno) MARK="question";shift
		[ "$YESLABEL" ] || YESLABEL=$(gettext "Yes")
		[ "$NOLABEL" ] || NOLABEL=$(gettext "No")
		[ "$YESSYMBOL" ] || YESSYMBOL="gtk-yes"
		[ "$NOSYMBOL" ] || NOSYMBOL="gtk-no"
		BUTTONS="<hbox>
    <button><label>$YESLABEL</label><input file stock=\"$YESSYMBOL\"></input><action>EXIT:Yes</action></button>
    $EXTRABUTTON
	<button><label>$NOLABEL</label><input file stock=\"$NOSYMBOL\"></input><action>EXIT:No</action></button></hbox>"
		;;
   timeout) MARK="info";shift
            if echo "$1" | grep -q '^[0-9][0-9]*$'; then
              TIMEOUT=$1; shift
            else
              TIMEOUT=10
            fi
            [ $TIMEOUT -lt 5 ] && BUTTONS=""
            ;;
  esac
  ERRMSG="$*"
  [ "$ERRMSG" = "" ] && ERRMSG=$(gettext "An error occured")
  DIALOG="<window title=\"$TITLE\" $TITLEICON><vbox>
    <hbox>
    <pixmap  icon_size=\"5\"><input file stock=\"gtk-dialog-$MARK\"></input></pixmap>
    <text><input>echo -e -n \"$ERRMSG\"</input></text>
    </hbox>
	$BUTTONS
	</vbox></window>"
  if [ $TIMEOUT -eq 0 ]; then
   gtkdialog3 -p DIALOG
   return
  else
   gtkdialog3 -p DIALOG  >/dev/null &
   XPID=$!
   for I in $(seq 1 $TIMEOUT);do
     # 28feb10 to see exact PID
     ps | grep -qw "^[[:blank:]]*$XPID" || break
     sleep 1
   done
   [ "$XPID" != "" ] && kill $XPID && XPID=""
  fi
}

user_presetsbabox() {
 [ -d "$USERPRESETDIR" ] && (cd "$USERPRESETDIR";ls|tr '_ ' '@')
}

waitsplashbabox(){
  [ "$XPID" != "" ] && kill $XPID >/dev/null 2>&1
  XPID=""
  #LANG=$LANGORG	# recover lang environment
  [ "$1" = "start" -o "$1" = "progress" ] || return
  PBAR=""
  if [ "$1" = "progress" ]; then
    PBAR="<progressbar>
      <input>while [ -f $COUNTFILE ]; do tail -n 1 $COUNTFILE; sleep 1; done</input>
     </progressbar>"
  fi
  shift	# remove $1
  S=$(gettext "Wait a moment ...")
  [ "$*" ] && S="$*\\n$S"
  DIALOG="<window title=\"$TITLE\" $TITLEICON><vbox>
  <hbox>
  <pixmap><input file>$ICONS/mini-clock.xpm</input></pixmap>
  <text><input>echo -e -n \"$S\"</input></text>
  </hbox>
  $PBAR
  </vbox></window>"
  gtkdialog3 -p DIALOG  >/dev/null &
  XPID=$!
  #LANG=C	# to be faster
}

make_dialog2babox() {
  IMVISIBLE="<visible>disabled</visible>"
  [ -e "$SOURCEFILE" ] && IMVISIBLE="" 
 # user presets
 USERPRESETS=$(user_presetsbabox)
 echo "<window title=\"$CREDIT\" icon-name=\"gtk-convert\">
<vbox>
  <hbox>
	<text><label>$(gettext 'Source file')</label></text>
      <entry tooltip-text=\"$(gettext 'Type or drag the source video file here.')\" editable=\"true\" accept=\"filename\">
        <variable>FILE1</variable>
        $(make_default \"$SOURCEFILE\")
        <action>enable:INFO_BUTTON</action>
        <action>enable:PLAY_BUTTON</action>
        <action>enable:CONVERT_BUTTON</action>
      </entry>
      <button tooltip-text=\"$(gettext 'Browse and select the source video file.')\">
        <input file stock=\"gtk-open\"></input>
        <variable>FILE_BROWSE_FILENAME</variable>
		<action type=\"fileselect\">FILE1</action>
      </button>
      <button tooltip-text=\"$(gettext 'Property of the source video file.')\" >
        <label>$(gettext 'Info.')</label><input file stock=\"gtk-info\"></input>
        <variable>INFO_BUTTON</variable>$IMVISIBLE
        <action>[ -f \"\$FILE1\" ] && ($MAKETHUMB gtkdialog3 -p INFO_DIALOG >/dev/null &)</action>
      </button>
      <button tooltip-text=\"$(gettext 'Play back the source video file.')\" >
        <label>$(gettext 'Play')</label><input file stock=\"gtk-media-play\"></input>
        <variable>PLAY_BUTTON</variable>$IMVISIBLE
        <action>[ \"\$FILE1\" ] && $PLAYER \$FILE1 &>/dev/null &</action>
      </button>
   </hbox>
   <hbox>
   <checkbox tooltip-text=\"$(gettext 'Tik if you want to convert all files with same extention in the same directory.')\" >
   <variable>WHOLEDIR1</variable>
   <label>$(gettext 'All files in the same directory')</label>
   $(make_defaultbabox \"$DEFWHOLEDIR\")
   </checkbox>
   <checkbox tooltip-text=\"$(gettext 'Tik to overwrite the destination files if they are exist.')\" >
   <variable>OVERWRITE1</variable>
   <label>$(gettext 'Overwrite files')</label>
   $(make_defaultbabox \"$DEFOVERWRITE\")
   </checkbox>
  <checkbox tooltip-text=\"$(gettext 'Tik if you want the convert job to be run background.')\" >
   <variable>BACKGROUND1</variable>
   <label>$(gettext 'Background job')</label>
   $(make_defaultbabox \"$DEFBACKGROUND\")
   </checkbox>
   </hbox>
   <hbox>
	<text><label>$(gettext 'Dest. dir.')</label></text>
      <entry tooltip-text=\"$(gettext 'Type or select the destination directory here.')\" editable=\"true\" accept=\"directory\">
        <variable>DIR1</variable>
		$(make_defaultbabox \"$DEFDIR\")
      </entry>
      <button tooltip-text=\"$(gettext 'Browse and select the destination directory.')\">
        <input file stock=\"gtk-directory\"></input>
        <variable>FILE_BROWSE_DIRECTORY</variable>
        <action type=\"fileselect\">DIR1</action>
      </button>
   </hbox>
   <hbox>
      <text><label>$(gettext 'Preset')</label></text>
      <combobox tooltip-text=\"$(gettext 'Select preset options.')\"  width-request=\"320\">
        <variable>PRESET1</variable>
        $(make_combobabox $DEFPRESET $USERPRESETS $PRESETS)
      </combobox>
      <button tooltip-text=\"$(gettext 'Load preset options.')\">
        <input file stock=\"gtk-apply\"></input>
        <label>$(gettext 'Load')</label>
        <variable>PRESET_BUTTON</variable>
		<action>EXIT:Preset</action>
      </button>
      <button tooltip-text=\"$(gettext 'Save preset options.')\">
        <input file stock=\"gtk-save-as\"></input>
        <label>$(gettext 'Save')</label>
        <variable>SAVE_BUTTON</variable>
		<action>EXIT:Save</action>
      </button></hbox>

<hbox>"
if [ "$VDISABLE" = "" ]; then
  echo "<frame $(gettext 'Video')>
<hbox>
<text><label>$(gettext 'Codec')</label></text>
<combobox>
<variable>VCODEC1</variable>
$(make_combobabox - $DEFVCODEC $COPY $NONE $H264 mpeg4 $VCODECS)
$VVISIBLE
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Quality')</label></text>
<combobox>
<variable>QUALITY1</variable>
$(make_combobabox - $DEFQUALITY $SAME $NOSPEC  $(seq 2 1 31))
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Bitrate') (kbps)</label></text>
<combobox>
<variable>VBITRATE1</variable>
$(make_combobabox - $DEFVBITRATE 200 500 1000 1150 $(seq 1500 500 8000) $(seq 10000 2000 20000))
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Screen size')</label></text>
<combobox>
<variable>SCREEN1</variable>
$(make_combobabox - $DEFSCREEN $SAME 128x96 160x120 176x144 320x200 320x240 320x480 352x240 352x288 352x360 352x480 352x576 640x350 640x480 704x576 720x360 720x480 720x576 800x600 852x480 1024x768 1280x720 1280x1024 1366x768 1600x1024 1600x1200 1920x1080 1920x1200 2048x1536 2560x1600 2560x2048 3200x2048 3840x2400 5120x4096 6400x4096 7680x4800)
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Aspect')</label></text>
<combobox>
<variable>ASPECT1</variable>
$(make_combo - $DEFASPECT $NOSPEC 4:3 16:9 'crop@4:3@-->@16:9' 'crop@16:9@-->@4:3' 'zoom@4:3@-->@4:3')
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Frame rate')(fps)</label></text>
<combobox>
<variable>FRAMERATE1</variable>
$(make_combobabox - $DEFFRAMERATE $SAME 15 24 25 29.97 30 59.94)
</combobox>
</hbox>
<hbox>
	<text><label>$(gettext 'Adv. options')</label></text>
      <entry tooltip-text=\"$(gettext 'Type additional options for video codec here.')\" editable=\"true\">
        <variable>VOPTIONS1</variable>
        $(make_defaultbabox $DEFVOPTIONS)
      </entry>
   </hbox>
</frame>"
fi
echo "<vbox>
<frame $(gettext 'Audio')>"
if [ "$ADISABLE" = "" ]; then
  echo "<hbox>
<text><label>$(gettext 'Codec')</label></text>
<combobox>
<variable>ACODEC1</variable>
$(make_combobabox - $DEFACODEC $COPY $NONE $AAC $MP3 mp2 $ACODECS)
$AVISIBLE
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Bitrate')(kbps)</label></text>
<combobox>
<variable>ABITRATE1</variable>
$(make_combobabox $DEFABITRATE 64 96 128 192 224 256 384 448)
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Sampling')(Hz)</label></text>
<combobox>
<variable>SAMPLING1</variable>
$(make_combobabox $DEFSAMPLING $SAME 44100 48000)
</combobox>
</hbox>
<hbox>
	<text><label>$(gettext 'Channels')</label></text>
      <combobox tooltip-text=\"$(gettext 'Select the number of audio channel.')\" editable=\"true\">
        <variable>CHANNEL1</variable>
        $(make_combobabox $DEFCHANNEL $SAME $MONO $STEREO)
      </combobox>
   </hbox>
   <hbox>
	<text><label>$(gettext 'Adv. options')</label></text>
      <entry tooltip-text=\"$(gettext 'Type additional options for audio codec here.')\" editable=\"true\">
        <variable>AOPTIONS1</variable>
        $(make_defaultbabox $DEFAOPTIONS)
      </entry>
   </hbox>"
else
  echo "<text><input>echo -en \"$(gettext 'No audio stream')\"</input></text>"
fi
echo "</frame>
<hbox><text><label>$(gettext 'File format')</label></text>
<combobox tooltip-text=\"$(gettext 'Select the target file format.')\" >
<variable>FORMAT1</variable>
$(make_combobabox - $DEFFORMAT avi mpeg mp3 mp4 $FORMATS)
</combobox>
</hbox>
<hbox>
<text><label>$(gettext 'Processing')</label></text>
<combobox tooltip-text=\"$(gettext '1-pass for quick, 2-pass for slow but high quality.')\">
<variable>PASS1</variable>
$(make_combobabox - $DEFPASS 2-pass 1-pass)
</combobox>
</hbox>
</vbox>
</hbox>

<hbox>
    <button>
        <label>$(gettext 'Convert')</label><input file stock=\"gtk-convert\"></input>
        <variable>CONVERT_BUTTON</variable>$IMVISIBLE
        <action>EXIT:OK</action>
    </button>
    <button tooltip-text=\"$(gettext 'Browse the ffmpeg document on the internet.')\">
        <input file stock=\"gtk-help\"></input>
		<action>$BROWSER $ONLINEDOC &>/dev/null &</action>
    </button>
    <button><label>$(gettext 'Quit')</label><input file stock=\"gtk-quit\"></input><action>EXIT:Abort</action></button>
</hbox>
</vbox>
</window>"
}

make_combobabox() {
	LANG=C	# for speed up
  ADDNULL=""
  [ "$1" = '-' ] && ADDNULL="yes" && shift
  CHOICE=""
  LIST="$@"
  [ "$ADDNULL" = "" ] || echo "$@" | grep -q "$NULL" || LIST="$@ $NULL"
for ONEITEM in $LIST;do
  NEWITEM=$(echo $ONEITEM|tr '@' ' ')
  echo "$CHOICE" | grep -q "<item>$NEWITEM</item>" && continue
  CHOICE="$CHOICE
  <item>$NEWITEM</item>"
done
  echo "$CHOICE"
}

make_defaultbabox() {
	P="$@";# echo $P >&2
	[ "$P" != "" -a "$P" != '""'  ] || return
	echo -n "<default>$P</default>"
}

load_presetbabox() {
    # load preset
    PRESETLINE=""
    if [ "$PRESET1" ]; then
      F=$(echo "$PRESET1"| tr '@ /' '_')
      for D in "$USERPRESETDIR" "$PRESETDIR"; do
         [ -f "$D/$F" ] && PRESETLINE=$(grep -v '^#' $D/$F| head -n 1) && break
      done
      if [ "$PRESETLINE" = "" -a -f  "$PRESETFILE" ]; then
         PRESETLINE=$(grep "^$PRESET1[, ]" "$PRESETFILE"| cut -d',' -f2)
      fi
    fi
    if [ "$PRESETLINE" ]; then
       opt2defvarbabox $PRESETLINE
       DEFPRESET=$(echo "$PRESET1"| tr ' ' '@')
       return 0
    else
      errmsgbabox $(gettext 'No preset found.')
      return 1
    fi
}
# save new preset
save_presetbabox() {
      NEWPRESET=$(echo "$PRESET1"| tr '_ ' '@')
      USERPRESETS=$(user_presetsbabox) 
      [ "$USERPRESETS" ] && echo "$USERPRESETS"| grep -qx "$NEWPRESET" && DUPE="yes" || DUPE=""
      NEWPRESET=$(echo "$NEWPRESET"|tr '@_' ' ')
      MSG=$(gettext 'Save as the new preset?')
      [ "$DUPE" ] && MSG=$(gettext 'Same name already exists.\nReplace the preset?')
      MAIN_DIALOG="<window title=\"$CREDIT\" icon-name=\"gtk-save-as\"><vbox>
    <hbox>
    <text><label>$(gettext 'Preset name')</label></text>
    <entry tooltip-text=\"$(gettext 'Type new preset name to save.')\">
    <variable>NEWPRESET1</variable>
    $(make_default \"$NEWPRESET\")
    </entry>
    </hbox>
    <text><input>echo -en \"$MSG\"</input></text>
    <hbox>
    <button ok></button>
    <button cancel></button>
    </hbox>
    </vbox></window>"
    eval $(gtkdialog3)
    [ "$EXIT" = "OK" ] || return
    var2optbabox
    F=$(echo "$NEWPRESET1"| tr '@ /' '_')
    PRESET1=$(echo "$F"| tr '_' ' ')
    if [ "$USERPRESETDIR" ]; then
      mkdir -p "$USERPRESETDIR"
      F="$USERPRESETDIR/$F"
    fi
    echo -n "$OPTSAVE" > $F
}

source_propertybabox() {
  SRCINFO=$(ffmpeg -i "$FILE1" 2>&1 |grep -E '(#|Duration)')
  VSTREAM=$(echo "$SRCINFO"|grep 'Stream .*Video')
  ASTREAM=$(echo "$SRCINFO"|grep 'Stream .*Audio')
  #echo "$VSTREAM" >&2
  #echo "$ASTREAM" >&2
  if [ "$VSTREAM" = "" -a "$ASTREAM" = "" ]; then
    [ "$1" = "skip" ] || errmsgbabox $(printf "$(gettext 'No video nor audio stream in %s.')" "$FILE1")
    return 1
  fi
  [ "$VSTREAM" ] && NOVIDEO="" || NOVIDEO="true"
  [ "$ASTREAM" ] && NOAUDIO="" || NOAUDIO="true"
  #[ "$NOVIDEO" ] && DEFVCODEC="$NONE" && VCODEC1="$NONE"
  #[ "$NOAUDIO" ] && DEFACODEC="$NONE" && ACODEC1="$NONE"
  return 0
}

target2defvarbabox() {
 	case "$1" in
	*vcd) DEFFORMAT=mpeg
	    DEFVCODEC=mpeg1video
	    DEFVBITRATE=1150
	    DEFACODEC=mp2
	    DEFABITRATE=224
	    DEFSAMPLING=44100
	    CHANNEL=2
	    DEFSCREEN=352x240
	    DEFFRAMERATE=29.97
		;;
	*dvd)  DEFFORMAT=mpeg
	    DEFVCODEC=mpeg2video
	    DEFVBITRATE=6000
	    DEFACODEC=ac3
	    DEFABITRATE=448
	    DEFSAMPLING=48000
	    CHANNEL=2
	    DEFSCREEN=720x480
	    DEFFRAMERATE=29.97
		;;
	esac 
	case "$1" in
	pal-vcd) DEFSCREEN=352x288
	    DEFFRAMERATE=25
		;;
	pal-dvd) DEFSCREEN=720x576
	    DEFFRAMERATE=25
		;;
	esac
  case "$CHANNEL" in
  1) DEFCHANNEL=$MONO;;
  2) DEFCHANNEL=$STEREO;;
  *) DEFCHANNEL=$CHANNEL;;
  esac
}

opt2defvarbabox() {
  [ $# -gt 0 ] || return
  DEFVOPTIONS=""
  DEFAOPTIONS=""
  VAFLAG="V"
  VDISABLE=""
  ADISABLE=""
  #[ "$VDISABLE" ] && VAFLAG="A"
  #[ "$ADISABLE" ] && VAFLAG="V"
  while [ $# -gt 0 ]; do
    case "$1" in
    -f) shift; DEFFORMAT=$1;;
    -target) shift; target2defvar "$1";;
    -vcodec) shift; DEFVCODEC=$1;;
    -acodec) shift; DEFACODEC=$1;;
    -vn) VAFALG="A";DEFVCODEC=$NONE;VDISABLE="true";;
    -an) VAFLAG="V";DEFACODEC=$NONE;ADISABLE="true";;
    -qscale) shift; DEFQUALITY=$1;;
    -sameq) DEFQUALITY=$SAME;;
    -b) shift; DEFVBITRATE=$(echo "$1"|tr -dc '0-9');;
    -s) shift; DEFSCREEN=$1;;
    -r) shift; DEFFRAMERATE=$(echo "$1"|tr -dc '0-9.');;
    -ab) shift; DEFABITRATE=$(echo "$1"|tr -dc '0-9');;
    -ar) shift; DEFSAMPLING=$(echo "$1"|tr -dc '0-9');;
    -ac) shift; CHANNEL=$1;;
    -aspect)  shift;DEFASPECT=$(echo "$1"|tr -dc '0-9.:');;
    -aframes|-aq|-alang|-atag|-absf) DEFAOPTIONS="$DEFAOPTIONS $1 $2";shift;;
    -newaudio) DEFAOPTIONS="$DEFAOPTIONS $1";;
    *) [ "$VAFLAG" = "V" ] && DEFVOPTIONS="$DEFVOPTIONS $1" ||  DEFAOPTIONS="$DEFAOPTIONS $1"
		;;
    esac
    shift
  done
  case "$CHANNEL" in
  1) DEFCHANNEL=$MONO;;
  2) DEFCHANNEL=$STEREO;;
  *) DEFCHANNEL=$CHANNEL;;
  esac
}

var2optbabox() {
PASS=$(echo $PASS1 |tr -dc '1-2')
if [ "$NOAUDIO" != "" ]; then
  AOPTIONS="-an"
else
 case "$ACODEC1" in
 "$COPY") AOPTIONS="-acodec copy";;
 "$NONE") AOPTIONS="-an";;
 *) AB=$(echo $ABITRATE1 |tr -dc '0-9.')
	[ "$AB" ] && AB="-ab ${AB}k"
	AR=$(echo "$SAMPLING1"| tr -dc '0-9.k')
	[ "$AR" ] && AR="-ar $AR"
	[ "$SAMPLING1" = "$COPY" ] && AR=""
	case $(echo "$CHANNEL1"|tr ' ' '@') in
	$MONO) AC="-ac 1";;
	$STEREO) AC="-ac 2";;
	*) AC=$(echo "$CHANNEL1"| tr -dc '0-9')
	  [ "$AC" ] && AC="-ac $AC"
		;;
	esac
	[ "$CHANNEL" ] && AC="-ac $CHANNEL"
	[ "$CHANNEL" = "$COPY" ] && AC=""
	AOPTIONS="-acodec $ACODEC1 $AB $AR $AC $AOPTIONS1"
	;;
 esac
fi
#echo "NOVIDEO=$NOVIDEO">&2
if [ "$NOVIDEO" != "" ]; then
  PASS=1
  VOPTFINAL="-vn"
else
 case "$VCODEC1" in
 "$COPY") PASS=1; VOPTFINAL="-vcodec copy";;
 "$NONE") PASS=1; VOPTFINAL="-vn";;
 *)  VB=$(echo $VBITRATE1 |tr -cd '[0-9.]')
	[ "$VB" ] && VB="-b ${VB}k"
	Q=$(echo $QUALITY1|tr -cd '[0-9.]')
	if [ "$Q" ]; then
		Q="-qscale  $Q"
	else
		[ "$VB" ] || Q="-sameq"
	fi
	S=$(echo $SCREEN1|tr 'X' 'x'|tr -cd '[0-9x]')
	# aspect and cropping
	CROP=""
	ASPECT=$ASPECT1
	if echo $ASPECT| grep -qw 'crop' ; then
	  ASPECT=$(echo $ASPECT|rev|cut -d' ' -f1|rev)
	  SSIZE=$(echo $VSTREAM|cut -d',' -f3)
	  SSIZE=$(echo $SSIZE| cut -d' ' -f1)
	  SX=$(echo $SSIZE| cut -d'x' -f1)
	  SY=$(echo $SSIZE| cut -d'x' -f2)
	  if [ "$ASPECT" = "16:9" ]; then
	    N=$(($SY / 16 * 2))
	    CROP="-croptop $N -cropbottom $N"
	    N=$(($N * 2))
	    [ "$S" = "" ] && S="${SX}x$(($SY - $N))"
	  else
	    N=$(($SX / 16 * 2))
	    CROP="-cropleft $N -cropright $N"
	    N=$(($N * 2))
	    [ "$S" = "" ] && S="$(($SX - $N))x$Y"
	  fi
	elif echo $ASPECT| grep -qw 'zoom' ; then
	  ASPECT=$(echo $ASPECT|rev|cut -d' ' -f1|rev)
	  SSIZE=$(echo $VSTREAM|cut -d',' -f3)
	  SSIZE=$(echo $SSIZE| cut -d' ' -f1)
	  SX=$(echo $SSIZE| cut -d'x' -f1)
	  SY=$(echo $SSIZE| cut -d'x' -f2)
	  N=$(($SY / 16 * 2))
	  CROP="-croptop $N -cropbottom $N"
	  NY=$(($N * 2))
	  N=$(($SX / 16 * 2))
	  CROP="$CROP -cropleft $N -cropright $N"
	  NX=$(($N * 2))
	  [ "$S" = "" ] && S="$(($SX - $NX))x$(($SY - $NY))"
	fi
	[ "$S" ] && S="-s $S"
	A=$(echo $ASPECT|tr -cd '[0-9.:]')
	[ "$A" ] && A="-aspect $A"
	#
	R=$(echo $FRAMERATE1|tr -cd '[0-9.]')
	[ "$R" ] && R="-r $R"
    [ "$VCODEC1" = "libx264" ] &&  ADDOPTIONS="$ADDOPTIONS $X264OPTIONS"
	for D in $HOME/.ffmpeg /usr/share/ffmpeg ; do
		FOUND="yes"
		[ -f $D/$VCODEC1-$DEFVPREFIRST.ffpreset ] && break
		FOUND=""
	done
	[ "$FOUND" ] && VPREFIRST="-vpre $DEFVPREFIRST" || VPREFIRST=""
	for D in $HOME/.ffmpeg /usr/share/ffmpeg ; do
		FOUND="yes"
		[ -f $D/$VCODEC1-$DEFVPREFINAL.ffpreset ] && break
		FOUND=""
	done
	[ "$FOUND" ] && VPREFINAL="-vpre $DEFVPREFINAL" || VPREFINAL=""
	VOPT="$Q $VB $S $A $R $VOPTIONS1"
	VOPTFIRST="$CROP -vcodec $VCODEC1 $VPREFIRST $ADDOPTIONS $VOPT"
	VOPTFINAL="$CROP -vcodec $VCODEC1 $VPREFINAL $ADDOPTIONS $VOPT"
	VOPTIONS="$CROP -vcodec $VCODEC1 $VOPT"
 	;;
 esac
fi
OPTFIRST="-i \"$FILE1\" -y -f $FORMAT1 $VOPTFIRST -an /dev/null "
OPTFINAL="-i \"$FILE1\" -y -f $FORMAT1 $VOPTFINAL $AOPTIONS \"$DESTFILE\""
OPTSAVE="-f $FORMAT1 $VOPTIONS $AOPTIONS"
}

var2defbabox() {
#THUMBNAILSIZE="128x96"
DEFDIR="$DIR1"
DEFBACKGROUND="$BACKGROUND1"
DEFPRESET=$(echo "$PRESET1"| tr ' ' '@')
DEFFORMAT="$FORMAT1"
DEFVCODEC="$VCODEC1"
#DEFVPREFIRST="$DEFVPREFIRST"
#DEFVPREFINAL="$DEFVPREFINAL"
#ADDOPTIONS="$ADDOPTIONS"
#X264OPTIONS="$X264OPTIONS"
DEFQUALITY="$QUALITY1"
DEFVBITRATE="$VBITRATE1"
DEFSCREEN="$SCREEN1"
DEFASPECT="$ASPECT1"
DEFFRAMERATE="$FRAMERATE1"
DEFVOPTIONS="$VOPTIONS1"
DEFACODEC="$ACODEC1"
DEFABITRATE="$ABITRATE1"
DEFSAMPLEING="$SAMPLING1"
DEFCHANNEL="$CHANNEL1"
DEFAOPTIONS="$AOPTIONS1"
DEFPASS="$PASS1"
}
# save conf
save_confbabox() {
  mkdir -p $(dirname "$CONFFILE")
  cat <<EOF > "$CONFFILE"
#THUMBNAILSIZE="128x96"
#DEFWHOLEDIR="$WHOLEDIR1"
#DEFOVERWRITE="$OVERWRITE1"
DEFBACKGROUND="$BACKGROUND1"
DEFDIR="$DIR1"
DEFPRESET="$PRESET1"
DEFFORMAT="$FORMAT1"
DEFVCODEC="$VCODEC1"
#DEFVPREFIRST="$DEFVPREFIRST"
#DEFVPREFINAL="$DEFVPREFINAL"
#ADDOPTIONS="$ADDOPTIONS"
#X264OPTIONS="$X264OPTIONS"
DEFQUALITY="$QUALITY1"
DEFVBITRATE="$VBITRATE1"
DEFSCREEN="$SCREEN1"
DEFASPECT="$ASPECT1"
DEFFRAMERATE="$FRAMERATE1"
DEFVOPTIONS="$VOPTIONS1"
DEFACODEC="$ACODEC1"
DEFABITRATE="$ABITRATE1"
DEFSAMPLING="$SAMPLING1"
DEFCHANNEL="$CHANNEL1"
DEFAOPTIONS="$AOPTIONS1"
DEFPASS="$PASS1"
EOF
}

keep_entrybabox() {
  SOURCEFILE="$FILE1"
  DEFDIR="$DIR1"
  DEFWHOLEDIR="$WHOLEDIR1"
  DEFOVERWRITE="$OVERWRITE1"
}

cleanup1babox() {
 [ "$CPID" != "" ] && kill $CPID && CPID=""
 rm -fR "$WORKDIR"
 rm -f "$CMDFILE" "$TMPFILE" "$STATUSFILE" "$LOGFILE" "$THUMBNAIL"
}

cleanupbabox() {
  cleanup1babox
  rm -f "$COUNTFILE"
 for I in "$XPID" "$CPID" "$MPID"; do
   [ "$I" != "" ] && kill $I
 done 
  rm -f "$COUNTFILE" "$STATUSFILE" "$REPFILE" "$WORKLOG"
  [ -d  "$MYTMPDIR" ] && [ "$(ls "$MYTMPDIR" 2>/dev/null)" = "" ] && rmdir "$MYTMPDIR"
}

abortbabox() {
 cleanupbabox
 exit 1
} 

ffconvertbabox() { # FFConvert - a frontend of ffmpeg
# 20 Jul 2010 by shinobar <shino@pos.to>
# 28 Jul 2010 check ffmpeg suports for each codec, crop and zoom, libvovis instead of ovis
# 10 Oct 2010 progress bar, allow both 'orvis' or 'liborvis' as the codec name

VERSION="1.1"
CREDIT="FFConvert v.$VERSION"
TITLE=$CREDIT
MYNAME=$(basename $0)
export TEXTDOMAIN=ffconvert	#$MYNAME
export OUTPUT_CHARSET=UTF-8 
export DIALOG
ICONS="/usr/local/lib/X11/mini-icons"

waitsplashbabox start $(printf "$(gettext 'Launching %s')" "$CREDIT")

SOURCEFILE=""
[ "$1" ] && [ -f "$1" ] && SOURCEFILE="$1"
# additional options
DEFVPREFIRST="fastfirstpass"
DEFVPREFINAL="hq"
ADDOPTIONS=""
X264OPTIONS="-threads 0"
MYTMPDIR="/tmp/$MYNAME"
CONFFILE="$HOME/.config/ffconvert/ffconvert.rc"
DATADIR="/usr/share"
PRESETFILE="$DATADIR/ffconvert/preset"
PRESETDIR="$DATADIR/ffconvert/preset.d"
USERPRESETDIR="$HOME/.config/ffconvert/presets"
ONLINEDOC="http://ffmpeg.org/ffmpeg-doc.html"
TEXTVIEWER="defaulttextviewer"
TERMINAL=""
for P in urxvt rxvt; do
  which "$P" &>/dev/null && TERMINAL=$P && break
done 
#PLAYER="defaultmediaplayer"
for P in defaultmediaplayer ffplay mplayer gxine; do
  which "$P" &>/dev/null && PLAYER=$P && break
done
#which ffplay &>/dev/null && PLAYER="ffplay"
if [ "$BROWSER" = "" ];then
  for P in defaultbrowser defaulthtmlviewer firefox google-chrome seamonkey gtkmoz; do
    which "$P" &>/dev/null && BROWSER=$P && break
  done
fi
export XPID
export CPID
export MPID

waitsplashbabox start $(printf "$(gettext 'Launching %s')" "$CREDIT")

# check ffmpeg ability
FALL=$(ffmpeg -formats 2>/dev/null)
N1=$(echo "$FALL"|cat -n| grep 'Codecs:'|cut -f1| tr -dc '[0-9]')
N2=$(echo "$FALL"|cat -n| grep 'Supported file protocols:'|cut -f1| tr -dc [0-9])
if [ "$N1" ]; then
  FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]*E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
  if [ "$N2" ]; then
    CODECS=$(echo "$FALL"| head -n $(($N2 - 1))|tail -n $(($N2 - $N1)))
  fi
else
  FORMATS=$(echo "$FALL"| grep '^[ D]*E'|sed -e 's/^[ A-Z]*[ ]*//' |cut -d ' ' -f1)
  CODECS=$(ffmpeg -codecs 2>/dev/null)
fi
VCODECS=$(echo "$CODECS"|grep '^[ D]*EV'|sed -e 's/^[ A-Z]*[ ]*//' |cut -d ' ' -f1)
ACODECS=$(echo "$CODECS"|grep '^[ D]*EA'|sed -e 's/^[ A-Z]*[ ]*//' |cut -d ' ' -f1)
#echo "$FORMATS" >&2
#echo "$CODECS" >&2
H264=$(echo "$VCODECS" | grep 'libx264')
AAC=$(echo "$ACODECS" | grep 'libfaac')
MP3=$(echo "$ACODECS" | grep 'libmp3lame')
CUSTOM=$(gettext 'Custom'|tr ' ' '@')
COPY=$(gettext 'Copy'|tr ' ' '@')
NONE=$(gettext 'None'|tr ' ' '@')
SAME=$(gettext 'Same as source'|tr ' ' '@')
NOSPEC=$(gettext 'Not specify'|tr ' ' '@')
MONO=$(gettext 'mono')
STEREO=$(gettext 'stereo')
#[ "$DEFDIR" ] && DEFAULTDIR="<default>$DEFDIR</default>" || DEFAULTDIR=""
#[ "$DEFOPTIONS" ] && DEFAULTOPTIONS="<default>$DEFOPTIONS</default>" || DEFAULTOPTIONS=""
DEFBACKGROUND="false"
# load conf
[ -f "$CONFFILE" ] && source "$CONFFILE"
DEFPRESET=$(echo "$DEFPRESET"|tr '_ ' '@')
[ "$DEFPRESET" ] || DEFPRESET="@"
DEFVCODEC=$(echo "$DEFVCODEC"|tr ' ' '@')
DEFQUALITY=$(echo "$DEFQUALITY"|tr ' ' '@')
DEFVBITRATE=$(echo "$DEFVBITRATE"|tr ' ' '@')
DEFSCREEN=$(echo "$DEFSCREEN"|tr ' ' '@')
DEFASPECT=$(echo "$DEFASPECT"|tr ' ' '@')
DEFFRAMERATE=$(echo "$DEFFRAMERATE"|tr ' ' '@')
DEFACODEC=$(echo "$DEFACODEC"|tr ' ' '@')
DEFSAMPLEING=$(echo "$DEFSAMPLEING"|tr ' ' '@')
DEFCHANNEL=$(echo "$DEFCHANNEL"|tr ' ' '@')
[ "$DEFBACKGROUND" = "true" ] || DEFBACKGROUND="false"

EXTRABUTTON=""
#THUMBNAILSIZE="128x96"	### enable thumbnail
THUMBNAILPOS=10
THUMBNAIL="/tmp/${MYNAME}-thumbnail.png"
MAKETHUMB="ffmpeg -i \$FILE1 -vcodec png -s $THUMBNAILSIZE -ss $THUMBNAILPOS -dframes 1 -an $THUMBNAIL &>/dev/null;"
SHOWTHUMB="<pixmap><input file>$THUMBNAIL</input></pixmap>"
if [ "$THUMBNAILSIZE" = "" ]; then
  MAKETHUMB=""
  SHOWTHUMB=""
fi
export INFO_DIALOG="<window title=\"$TITLE $(gettext 'Source')\"><vbox>
$SHOWTHUMB
<text><input>ffmpeg -i  \"\$FILE1\" 2>&1 |grep -E '(#|Duration)' || echo \$(printf \"\$(gettext 'No video nor audio stream in %s.')\" \"\$FILE1\")</input></text>
<hbox><button ok></button></hbox></vbox></window>"


# presets
[ -d "$PRESETDIR" ] && PRESETS=$(cd "$PRESETDIR";ls|tr '_ ' '@') || PRESETS=""
PRESETS2=$(cat "$PRESETFILE"| cut -d',' -f1|tr ' ' '@')
if [ "$PRESETS2" ]; then
  PRESETS="$PRESETS
$PRESETS2"
fi
USERPRESETS=""
#[ -d "$USERPRESETDIR" ] && USERPRESETS=$(cd "$USERPRESETDIR";ls|tr '_ ' '@') || USERPRESETS=""
#[ "$DEFPRESET" ] || DEFPRESET="@"
#PRESETCOMBO=$(make_combo $DEFPRESET $USERPRESETS $PRESETS)


#echo "$MAIN_DIALOG" >&2
#waitsplash stop
# phase 1
export MAIN_DIALOG	#="$DIALOG1"
while true; do
  MAIN_DIALOG=$(make_dialog2)
  waitsplash stop
  eval $(gtkdialog3)
  [ "$VDISABLE"  = "" ] || VCODEC1="$NONE"
  [ "$ADISABLE"  = "" ] || ACODEC1="$NONE"
  rm -f $THUMBNAIL $LOGFILE
  [ "$INFOPID" ] && XPID=$(cat $INFOPID 2>/dev/null)
  [ "$XPID" ] && kill $XPID
  XPID=""
  if [ "$EXIT" = "Preset" ]; then
    waitsplashbabox start
    keep_entrybabox
    load_presetbabox
    continue
  fi
  if [ "$EXIT" = "Save" ]; then
    keep_entrybabox
    save_presetbabox
    var2defbabox
    continue
  fi
  [ "$EXIT" = "OK" ] || exit
  # validity check
  # codec
  MSG=$(gettext "Your FFmpeg does not support the codec:")
  VCODEC="$VCODEC1"
  ACODEC="$ACODEC1"
  if [ "$VCODEC1" != "$NONE" -a "$VCODEC1" != "$COPY" ]; then
    VCODEC=$(echo "$VCODECS" | grep -w "$VCODEC1")
    if [ "$VCODEC" = "" ] ; then
      case $VCODEC1 in
        lib*) VCODEC=$(echo $VCODEC1| sed -e 's/^lib//') ;;
        *) VCODEC="lib$VCODEC1";;
      esac
      VCODEC=$(echo "$VCODECS" | grep -w "$VCODEC")
    fi
    [ "$VCODEC" != "" ] || MSG="$MSG '$VCODEC1'"
  fi
  if [ "$ACODEC1" != "$NONE" -a "$ACODEC1" != "$COPY" ]; then
    ACODEC=$(echo "$ACODECS" | grep -w "$ACODEC1")
    if [ "$ACODEC" = "" ]; then
     case $ACODEC1 in
        lib*) ACODEC=$(echo $ACODEC1| sed -e 's/^lib//') ;;
        *) ACODEC="lib$ACODEC1";;
      esac
      ACODEC=$(echo "$ACODECS" | grep -w "$ACODEC")
    fi
    [ "$ACODEC" != "" ] || MSG="$MSG '$ACODEC1'"
  fi
  if [ "$VCODEC" = "" -o "$ACODEC" = "" ]; then
    errmsgbabox $MSG
    continue
  fi
  # source
  WHOLEDIR="$WHOLEDIR1"
  if [ -d "$FILE1" ]; then
    MSG=$(printf "$(gettext '%s is a directory.')" "$FILE1")
    MSG="$MSG\\n$(gettext 'Convert all files in this directory?')"
    eval $(errmsgbabox yesno "$MSG")
    echo $EXIT
    [ "$EXIT" = "Yes" ] || continue
    WHOLEDIR="true"
    SRCDIR="$FILE1"
    SOURCES=$(cd "$SRCDIR";ls|tr ' ' '/')
  elif [ ! -f "$FILE1" ]; then
   if [ "$FILE1" ]; then
     errmsgbabox $(printf "$(gettext '%s not found.')" "$FILE1")
   else
     errmsgbabox $(gettext 'Souce file not specified.')
   fi
   continue
  else
    VSTREAM=""
    ASTREEM=""
    NOVIDEO=""
    NOAUDIO=""
    source_property || continue 
    [ "$NOVIDEO" ] && DEFVCODEC="$NONE" && VCODEC1="$NONE"
    [ "$NOAUDIO" ] && DEFACODEC="$NONE" && ACODEC1="$NONE"
    SRCDIR=$(dirname "$FILE1")
    B=$(basename "$FILE1")
    E=$(echo "$B"| cut -d'.' -f2)
    SOURCES=$(echo "$B"|tr ' ' '/')
   # look up whole directory
   if [ "$WHOLEDIR1" = "true" ]; then
     echo "cd \"$SRCDIR\";ls \"*.$E\""
     SOURCES=$(cd "$SRCDIR";ls *.$E | grep -v "$B"|tr ' ' '/')
     SOURCES="$B
$SOURCES"
   fi
  fi
  # destination
  DESTDIR="$DIR1"
  if [ ! -d "$DIR1" ]; then
   if [ "$DIR1" ]; then
     if [ -f "$DIR1" ]; then
       errmsgbabox $(printf "%s is not a directory." "$DIR1")
     else
		ERRMSG=$(printf "%s not exists." "$DIR1")
		ERRMSG="$ERRMSG\\n$(gettext 'Create new directory?')"
		eval $(errmsgbabox yesno $ERRMSG)
		[ "$EXIT" = "Yes" ] || continue
		mkdir -p "$DIR1"
		break
     fi
   else
     DESTDIR="$SRCDIR"
     break
     #errmsgbabox $(gettext 'Destination directory not specified.')
   fi
   continue
  fi
  break
done
# save conf
save_conf
# extention
EXT1=$FORMAT1
case $FORMAT1 in
  mpeg|dvd|svcd|vcd) EXT1="mpg";;
  ipod) EXT1="mp4";;
  ogg) EXT1="ogv"
     [ "$VCODEC1" = "$NONE" ] && EXT1="oga"
  ;;
esac
#echo $SOURCES>&2
# convert loop
NFILES=$(echo "$SOURCES"| wc -l)
REST=$NFILES
NCONV=0
MYROOT=$(basename "$FILE1"| cut -d'.' -f1|tr ' ' '_')
mkdir -p "$MYTMPDIR"
COUNTFILE="$MYTMPDIR/$MYROOT-count"
STATUSFILE="$MYTMPDIR/$MYROOT-status"
REPFILE="$MYTMPDIR/$MYROOT-reply"
WORKLOG="$MYTMPDIR/$MYROOT-ffmpeg.log"
INTERVAL=2
echo 0 >"$COUNTFILE"
printf "$(gettext '%s files rest')" $REST >"$STATUSFILE"
rm -f "$REPFILE"
FORGROUND=""
[ $NFILES -le 1 -o "$BACKGROUND1" != "true" ] && [ "$TERMINAL" != "" ] && FORGROUND="yes" 
trap abort 1 2 3 15 
MSG1=$(printf "$(gettext 'Start converting %s into %s')" "$FILE1" "$DESTDIR")
LOGBUTTON=""
if [ "$FORGROUND" = "" -a "$TERMINAL" != "" ]; then
  LOGBUTTON="<button tooltip-text=\"$(gettext 'Open a terminal to see the log.')\"><input file stock=\"gtk-justify-center\"></input><label>$(gettext 'Open log window')</label>
<action>$TERMINAL -bg orange -fg black -geometry 80x14  -e tail -f \"$WORKLOG\" &</action></button>"
fi
export DIALOG="<window title=\"$CREDIT\" icon-name=\"gtk-convert\"><vbox>
<text><input>date; echo \"${MSG1}...\"</input></text>
<progressbar>
      <input>while [ -f $COUNTFILE ]; do tail -n 1 $COUNTFILE; sleep $INTERVAL; done</input>
</progressbar>
<hbox>
$LOGBUTTON
<button cancel></button>
</hbox>
</vbox></window>"
gtkdialog3 -p DIALOG>$REPFILE &
MPID=$!
CPID=""
for ITEM in $SOURCES; do
 BASE1=$(echo $ITEM|tr '/' ' ')
 SRCFILE="$BASE1"
 [ "$SRCDIR" ] && SRCFILE="$SRCDIR/$BASE1"
 FILE1="$SRCFILE"
 # source validity
 SKIP=""
 [ $NFILES -gt 1 ] && SKIP="skip"
  NOVIDEO=""
  NOAUDIO=""
  source_property $SKIP
  FLAG=$?
  #echo ":$NOVIDEO:$NOAUDIO:">&2
  #[ "$NOVIDEO" ] && DEFVCODEC="$NONE" && VCODEC1="$NONE"
  #[ "$NOAUDIO" ] && DEFACODEC="$NONE" && ACODEC1="$NONE"
  REST=$(expr $REST - 1)
  [ $FLAG -eq 0 ] || continue
 
 # destination
 ROOT1=$(echo "$BASE1"| cut -d'.' -f1)
 DESTFILE="$DESTDIR/$ROOT1.$EXT1"
 [ "$SRCFILE" = "$DESTFILE" ] && DESTFILE="$DESTDIR/${ROOT1}_cvt.$EXT1"
 #echo "$DESTFILE" >&2
 if [ -s "$DESTFILE" ]; then
   if [ "$OVERWRITE1" != "true" -a $NFILES -gt 1 ]; then
    continue
   fi
   if [ $NFILES -eq 1 ]; then
     EXTRABUTTON=""
     ERRMSG=$(printf "$(gettext '%s already exists.')" "$DESTFILE")
     ERRMSG="$ERRMSG\\n$(gettext 'Replace it?')"
     YESLABEL="$(gettext 'Replace')"
     NOLABEL="$(gettext 'Quit')"
     NOSYMBOL="gtk-quit"
   eval $(errmsgbabox yesno $ERRMSG)
   [ "$EXIT" = "Yes" ] || abort
   fi
 fi
 printf "$(gettext 'Processing %s...')" "$SRCFILE" >"$STATUSFILE"
 # make options
 var2optbabox
 # prepair work space
 ROOT2=$(echo "$ROOT1"|tr ' ' '_')
 WORKDIR="$DESTDIR/ffconvert_tmp_$ROOT2"
 CMDFILE="$MYTMPDIR/$ROOT2.sh"
 TMPFILE="$MYTMPDIR/$ROOT2.tmp"
 ERRLOG="$DESTDIR/ffconvert_${ROOT2}_error.log"
 [ -s "$COUNTFILE" ] && [ $(cat "$COUNTFILE") -lt 1 ] && expr 50 / $NFILES > "$COUNTFILE"
 # generate command
 echo '#!/bin/sh' > "$CMDFILE"
 if [ "$PASS" = "2" ]; then
  mkdir -p "$WORKDIR"
  echo "cd \"$WORKDIR\"
ffmpeg -pass 1 $OPTFIRST && ffmpeg -pass 2 $OPTFINAL" >> "$CMDFILE"
 else
 echo "ffmpeg $OPTFINAL" >> "$CMDFILE"
 fi
 echo "STATUS=\$?
echo -n \$STATUS > \"$TMPFILE\"" >> "$CMDFILE"
 chmod +x "$CMDFILE"
 if [ "$FORGROUND" != "" ]; then
   echo "[ \"\$STATUS\" = \"0\" ] && exit
cat \"$CMDFILE\" | grep '^ffmpeg'
echo -n $(gettext 'Press [ENTER] to exit :')
read REP"  >> "$CMDFILE"
   #cat "$CMDFILE" >&2	# for debugging
   $TERMINAL -bg orange -fg black -geometry 80x14 -e "$CMDFILE"
 else
   "$CMDFILE" >"$WORKLOG" 2>&1 &
   CPID=$!
   ABORT=""
   RUNNING="yes"
   while [ "$RUNNING" != "" ]; do
	[ -s "$REPFILE" ] && grep -q 'EXIT=.*Cancel' "$REPFILE" && ABORT="yes" && break
	sleep $INTERVAL
	ps | grep -qw "^[[:blank:]]*$CPID" || RUNNING=""
  done
  [ "$RUNNING" != "" ] && kill $CPID
  CPID=""
 fi
   STATUS=$(cat "$TMPFILE")
   #rm -f "$TMPFILE"
 #REST=$(expr $REST - 1)
 if [ "$STATUS" != "0" ]; then
  rm -f "$DESTFILE"
  cat "$WORKLOG" "$CMDFILE" > "$ERRLOG"
  #rm -fR "$WORKDIR"
  MSG1=$(gettext 'An error occured.')
  MSG2=$(printf "$(gettext 'You can check the log at %s.')" "$ERRLOG")
  EXTRABUTTON="<button><input file stock=\"gtk-file\"></input><label>$(gettext 'Look up log')</label><action>$TEXTVIEWER \"$ERRLOG\" &</action></button>"
  if [ $REST -gt 0 ]; then
    MSG3=$(gettext 'Skip this file and continue?')
    YESLABEL="$(gettext 'Skip')"
    NOLABEL="$(gettext 'Quit')"
    NOSYMBOL="gtk-quit"
    eval $(errmsgbabox yesno "$MSG1\\n$MSG2\\n\\n$MSG3")
    [ "$EXIT" = "Yes" ] || abort
  else
    errmsgbabox "$MSG1\\n$MSG2"
    break
  fi
 else
   NCONV=$(expr $NCONV + 1)
 fi
 cleanup1
 C=$(expr $NCONV + $REST )
 expr 100 '*' $NCONV / $C >"$COUNTFILE"
 [ "$ABORT" = "" ] || break
done
cleanup
EXTRABUTTON=""
if [ $NCONV -eq 0 ]; then
  errmsgbabox $(gettext 'No files converted.')
  exit
fi
if [ $NCONV -gt 1 ]; then
   EXTRABUTTON="<button><input file stock=\"gtk-open\"></input><label>$(gettext 'Brawse')</label><action>EXIT:Brawse</action></button>"
  eval $(errmsgbabox info $(printf "$(gettext '%s files successfully converted in %s.')" $NCONV "$DESTDIR"))
  [ "$EXIT" = "Brawse" ]  && exec rox "$DESTDIR"
  exit
fi
EXTRABUTTON="<button><input file stock=\"gtk-media-play\"></input><label>$(gettext 'Play')</label><action>EXIT:Play</action></button>"
eval $(errmsgbabox info $(printf "$(gettext 'Successfully converted into %s.')"  "$DESTFILE"))
[ "$EXIT" = "Play" ] && exec $PLAYER "$DESTFILE" &>/dev/null
}

#end from ffconvert

cdevkrg() {
BD=`ls -1 /sys/class/block`
for i in $BD; do
ls -l /dev/$i
done
ls -l /dev/root
echo
cat /proc/partitions
echo
}



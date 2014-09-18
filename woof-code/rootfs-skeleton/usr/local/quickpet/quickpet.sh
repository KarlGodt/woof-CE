#!/bin/bash -a
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_quickpet.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/quickpet/quickpet.sh"
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
# Quickpet-2.1 #
#quickpackage-1.4 #01micko 2010-4-12 #GPL
#revised 2010-4-17 #renamed
#revised 2010-4-21 #removed qp-update, move sfs button
#revised 2010-4-22 #new lupu-update mechanism
#revised 2010-4-24 #small bugfixes
#revised 2010-4-25 #added some stuff from Lit, by Lobster, IP4 bugfix, fail to get variable bugfix
#revised 2010-4-27 #added support menu and wiki entry
#revised 2010-5-02 #rewrite for more repos
#revised 2010-5-07 #rewrote update section, far too complicated, let's make it simple
#revised 2010-5-09 #bugfix, added driver tab
#revised 2010-5-09 #bugfix, added sizes
#revised 2010-5-12 #tookout htop, added cine and jre
#revised 2010-5-22 #Internationalisation of Quickpet-2.1
#revised 2010-6-23 #2.2 fixed browser-installer, will cater to any generic browser
#revised 2010-6-29 #2.9 switched to main lucid repo and changed some entries, also non-cevtred for gtkdialog-splash
#revised 2010-7-13 #2.9.7 added google-earth and test-vid
#revised 2010-7-19 #2.9.8 scrapped test-vid added Lupu recommends
#revised 2010-7-19 #2.9.8-2 srapped update, changed to "news"
#revised 2010-7-22 #2.9.9 cleanup for release of 5.1
#revised 2010-8-02 #opening video help files in browser or viewer to help with translation #bugfixed if no connection, these still work
#revised 2010-8-12 #testing release for stellite problems #scsijon and Kevin Bowers report issues

#URLS to use
#URLREPO=http://dpup.org/01Micko/lupu
#URLREPO="http://www.diddywahdiddy.net/Lucid_Puppy/Updates"
UPDATEREPO="http://www.diddywahdiddy.net/Lucid_Puppy/Updates"

#define working directorys
APPDIR="`dirname $0`"
[ "$APPDIR" = "." ] && APPDIR="`pwd`"
export APPDIR="$APPDIR"

WORKDIR=$HOME/.quickpet

IMGDIR=$WORKDIR/icons

#test latest update
LATEST_UD_VER_HAVE=`ls $HOME/.packages|grep "lucid_pup_update"|tail -n1|cut -d '.' -f1 2>/dev/null`
LATEST_UD_RECORD=`tail -n1 /etc/lupu_update/installed_updates`
if [ "$LATEST_UD_RECORD" != "$LATEST_UD_VER_HAVE" ];then echo "$LATEST_UD_VER_HAVE" >> /etc/lupu_update/installed_updates
fi

#. $APPDIR/splashrc

#remove /tmp files
rm -f /tmp/docheck 2>/dev/null
rm -f /tmp/statcheck 2>/dev/null
rm -f /tmp/quickpet-get 2>/dev/null
rm -f /tmp/quickpet-ud 2>/dev/null
rm -f /tmp/petsizeme 2>/dev/null
rm -f /tmp/LucidPuppyUpdate 2>/dev/null
rm -rf $APPDIR/tabs/ 2>/dev/null

VER=`cat $WORKDIR/version`

#read config
#. $WORKDIR/urls.conf 2>/dev/null
#. $WORKDIR/viewer.conf 2>/dev/null
. $WORKDIR/prefs.conf 2>/dev/null
. $WORKDIR/repos.conf 2>/dev/null
. $WORKDIR/repos-xtra.conf 2>/dev/null

#set language
DEFLANG=`env|grep "LANG="`
if [ "$DEFLANG" = "LANG=C" ];then xmessage -center "Please set your locale" &
exit
fi
LANGUAGE=`echo $LANG|head -c5` #workaround for utf8
TMPLANG="`ls $APPDIR/locals/ | grep $LANGUAGE`"
. $APPDIR/locals/en_US:english #always run to fill gaps in translation
[[ "$TMPLANG" != "en_US:english" ]] && . $APPDIR/locals/$TMPLANG 2> /dev/null

#find if browser is installed
BROWSINSTALLED=`grep "exec" /usr/local/bin/defaultbrowser|awk '{print $2}'`
if [[ $BROWSINSTALLED = quickpet ]];then USEBROWSER="gtkmoz"
		else USEBROWSER="defaultbrowser"
fi
#is QP already running? need to refine as can run QP and wget concurrently #done
#RUNNING=`ps  | grep "wget" | grep -v "grep"`
RUNNING=`ps  | grep -w "quickpack" | grep -v "grep"`
if [[ "$RUNNING" != "" ]];then gtkdialog-splash -icon gtk-dialog-warning -timeout 5 -fontsize large -bg orange -close never  -text "$LOC_112"     #Xdialog --timeout 5 --msgbox "$LOC_112" 0 0 0 2>/dev/null #yaf-splash -font "-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1" -timeout 6 -outline 0 -bg pink -text "$LOC_112" &
	exit
fi

#set repo
if [ $RADIO1 = "true" ];then URLREPO=$URL1
	elif [ $RADIO2 = "true" ];then URLREPO=$URL2
	elif [ $RADIO3 = "true" ];then URLREPO=$URL3
	elif [ $RADIO4 = "true" ];then URLREPO=$URL4
	elif [ $RADIO5 = "true" ];then URLREPO=$URL5
	elif [ $RADIO6 = "true" ];then URLREPO=$URL6
	elif [ $RADIO7 = "true" ];then URLREPO=$URL7
	elif [ $RADIO8 = "true" ];then URLREPO=$URL8
	elif [ $RADIO9 = "true" ];then URLREPO=$URL9
	elif [ $RADIO10 = "true" ];then URLREPO=$URL10
	elif [ $RADIO11 = "true" ];then URLREPO=$URL11

fi
if [ $RADIO1 = "true" ];then URLREPOX=$URLX1
	elif [ $RADIO2 = "true" ];then URLREPOX=$URLX2
	elif [ $RADIO3 = "true" ];then URLREPOX=$URLX3
	elif [ $RADIO4 = "true" ];then URLREPOX=$URLX4
	elif [ $RADIO5 = "true" ];then URLREPOX=$URLX5
	elif [ $RADIO6 = "true" ];then URLREPOX=$URLX6
	elif [ $RADIO7 = "true" ];then URLREPOX=$URLX7
	elif [ $RADIO8 = "true" ];then URLREPOX=$URLX8
	elif [ $RADIO9 = "true" ];then URLREPOX=$URLX9
	elif [ $RADIO10 = "true" ];then URLREPOX=$URLX10
	elif [ $RADIO11 = "true" ];then URLREPOX=$URLX11

fi

#set incoming dir
if [ ! -d $WORKDIR/Downloads ] ;then mkdir $WORKDIR/Downloads
fi

#DLDDIR="$WORKDIR/Downloads"
DLDDIR="/tmp"
#check to see if we are connected to the internet
function CHECKNET(){
	 wget -t 0 -4 -o /tmp/testcon --spider www.puppylinux.com
	 NOCON=`grep -w "failed" /tmp/testcon`
	 if [ "$NOCON" != "" ]; then #testnet &
#sleep 5
#kill `ps|grep "test_net"` 2>/dev/null #killall yaf-splash && yaf-splash -font "-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1" -timeout 6 -placement top -outline 0 -bg red -text "$LOC_101"
	 gtkdialog-splash -icon gtk-dialog-error -timeout 6 -fontsize large -bg hotpink -close never  -text "$LOC_101"
	 exit
	 fi
}



# lucid_pup_update-1.pet (or whatever VERSION number) is the current format for the update #scrapped
#lucidpuppyupdate is now just a news site with possible updates posted
function LUPU_UPDATE(){
	CHECKNET
	if [[ $USEBROWSER = gtkmoz ]];then  Xdialog --title $LOC_INFO --msgbox "$LOC_BRS" 0 0 0
	$USEBROWSER http://www.diddywahdiddy.net/LupuNews &
		elif [[ $BROWSINSTALLED = netsurf ]];then Xdialog --title $LOC_INFO --msgbox "$LOC_BRS" 0 0 0
		$USEBROWSER http://www.diddywahdiddy.net/LupuNews &
		elif [[ $BROWSINSTALLED != netsurf ]];then
		$USEBROWSER http://www.diddywahdiddy.net/LupuNews &
	fi

}

          ############################################################################################
          ###oooooooooooooooooooooo--------------------------------------oooooooooooooooooooooooooo###
          ######################### Main engine that downloads the goods #############################
          ###oooooooooooooooooooooo______________________________________oooooooooooooooooooooooooo###
          ###$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$###

function GETPET(){
	 CHECKNET
	 /usr/X11R7/bin/yaf-splash -font "-misc-dejavu sans-bold-r-normal--18-0-0-0-p-0-iso10646-1" -placement top -fg white -outline 0 -bg black -text "$LOC_102" &
	 rm -f /tmp/docheck 2>/dev/null
	 THEPET=`cat /tmp/thepet`
	 #DLDPET=`grep "$THEPET" $WORKDIR/urls.conf | cut -d '=' -f2`
	 GRABPET=`grep "$THEPET" $WORKDIR/petnames.conf | cut -d '=' -f2`

	 kill `ps | grep -w "quickpack" | awk '{print $1}'` 2>/dev/null
	 kill `ps | grep -w "BWIZ" | awk '{print $1}'` 2>/dev/null
	 #kill `ps | grep -w "oldupdategui" | awk '{print $1}'` 2>/dev/null
	 #chmod 644 /usr/sbin/quickpackage
	 #PETINST=`grep "$THEPET" $WORKDIR/urls.conf | sed s'/\// /'g | tr " '" '\n' | tail -n1 | tr -d '"'` #get the actual .pet

	 #yaf-splash -font "-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1" -placement top -outline 0 -timeout 4 -bg lightblue -text "$LOC_106a $THEPET $LOC_106b" &
	 #download &
	 #sleep 5
	 #kill `ps|grep "down_load"` 2>/dev/null
	 gtkdialog-splash -icon gtk-info -timeout 5 -fontsize large -bg lightblue -close never -text "$LOC_106a $THEPET $LOC_106b" &
	 COUNT=0
	 until [ "`grep -w "Content-Length" /tmp/docheck`" ] || [ "`grep -w "exists" /tmp/docheck`" ] || [ "`grep -w "Login successful" /tmp/docheck`" ] || [ "`grep -w "broken link" /tmp/docheck`" ]  || [ "`grep -w "No such file" /tmp/docheck`" ]|| [ "$COUNT" = "30" ]
		do echo "wget -S --spider -T 20 -4 $URLREPO/$GRABPET 2>/tmp/docheck" >/tmp/statcheck
		. /tmp/statcheck
	 COUNT=`expr $COUNT + 1`
	  sleep $SLEEP_SIZE
	 done
	 #if it fails try the main repo
	 rm -f /tmp/statXcheck
	 if [[ "`grep -w "broken link" /tmp/docheck`" ]];then rm -f /tmp/docheck
	 gtkdialog-splash -icon gtk-dialog-info -timeout 5 -fontsize large -bg yellow -close never -text "$LOC_113" &
	   until [ "`grep -w "Content-Length" /tmp/docheck`" ] || [ "`grep -w "exists" /tmp/docheck`" ] || [ "`grep -w "Login successful" /tmp/docheck`" ] || [ "`grep -w "No such file" /tmp/docheck`" ] || [ "$COUNT" = "30" ]
		  do echo "wget -S --spider -T 20 -4 $URLREPOX/$GRABPET 2>/tmp/docheck" >/tmp/statXcheck
		. /tmp/statXcheck
	 COUNT=`expr $COUNT + 1`
	  sleep $SLEEP_SIZE
	   done
		elif [[ "`grep -w "No such file" /tmp/docheck`" ]];then rm -f /tmp/docheck
			gtkdialog-splash -icon gtk-dialog-info -timeout 5 -fontsize large -bg yellow -close never -text "$LOC_113" &
			until [ "`grep -w "Content-Length" /tmp/docheck`" ] || [ "`grep -w "exists" /tmp/docheck`" ] || [ "`grep -w "Login successful" /tmp/docheck`" ] || [ "$COUNT" = "30" ]
				do echo "wget -S --spider -T 20 -4 $URLREPOX/$GRABPET 2>/tmp/docheck" >/tmp/statXcheck
			. /tmp/statXcheck
			COUNT=`expr $COUNT + 1`
			sleep $SLEEP_SIZE
			done
	 fi
	 if [ "`grep -w "Connection timed out" /tmp/docheck`" ];then
		gtkdialog-splash -icon gtk-dialog-warning -timeout 5 -fontsize large -bg hotpink -close never -text "$LOC_107" &
		exit
	 fi
	 if [ -f /tmp/statXcheck ]; then URLREPO="$URLREPOX"
	 fi
     PET_SIZE=`grep -w "Content-Length" /tmp/docheck|awk '{print $2}'`

	 if [ "$PET_SIZE" = "" ];then PET_SIZE=`grep -w -i $THEPET /tmp/docheck|grep -v Removed|grep -v exists|tail -n1|awk '{print $5}'`
	 fi
	 echo $PET_SIZE
	 #echo $PET_SIZE >/tmp/petsize
	 killall yaf-splash
	 echo "eval rxvt -background lightblue -title "Quickpet" -e wget -t 0 -c -4 -P $DLDDIR $URLREPO/$GRABPET" > /tmp/quickpet-get
	 . /tmp/quickpet-get




	 #if [ $(grep $THEPET $HOME/.quickpackage/sizes | cut -d "|" -f2) = $(stat -c %s  $HOME/.quickpackage/Downloads/$PETINST | cut -d '/' -f1) ];then petget +$DLDDIR/$PETINST
	 rm -f /tmp/integrity-check 2>/dev/null
	 if [ $PET_SIZE = $(stat -c %s  /tmp/$GRABPET) ] ;then petget +$DLDDIR/$GRABPET
	     else
	 gtkdialog-splash -icon gtk-dialog-warning -timeout 5 -fontsize large -bg red -close never -text "$LOC_108" &
	 #yaf-splash -font "-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1" -timeout 5 -placement top -outline 0 -bg red -text "$LOC_108"
		exit
	 fi
	 cd $HOME
	 sleep 1
	 ls $HOME/.packages > /tmp/quinstpacks
	 INST_SUCCESS=`grep -i $THEPET /tmp/quinstpacks`
	 if [ "$INST_SUCCESS" = "" ] ;then
	 gtkdialog-splash -icon gtk-dialog-warning -timeout 5 -fontsize large -bg red -close never -text "$LOC_108" &
	 rm -f $GRABPET
		else
	 gtkdialog-splash -icon gtk-apply -timeout 5 -fontsize large -bg green -close never -text "$LOC_110a $THEPET $LOC_110b" &
	 echo "yay" > /tmp/we_got_it
	 fi
	 if [ $CHKBOX = "false" ];then
     cp -f  $DLDDIR/$GRABPET $WORKDIR/Downloads/$GRABPET
     fi
     rm -f /tmp/we_got_it 2>/dev/null
     [ -x /pinstall.sh ]&& rm -f /pinstall.sh 2>/dev/null
	 exit
}
### END MAIN FUNCTION ###

#help and info
function INFO(){
	Xdialog --title $LOC_INFO --msgbox "$LOC_202" 0 0 0

}

# make PuppyBrowser default
function CHANGE(){
	#CHANGE_DEFAULT=`grep "exec" /usr/local/bin/defaultbrowser` #changed in case old entry is commented
	CHANGE_DEFAULT=`grep -v "#" /usr/local/bin/defaultbrowser`

	#new engine to find installed browsers from *.desktop files
rm -rf /tmp/tmpbrs
mkdir /tmp/tmpbrs
grep -i "browser" /usr/share/applications/*.desktop|cut -d ':' -f1|tr '/' ' '|awk '{print $4}'>/tmp/browserlist
echo '#browsers' >/tmp/installed-browsers
INSTALLED_BROWSERS=`cat /tmp/browserlist`
for i in $INSTALLED_BROWSERS;do grep 'Exec=' /usr/share/applications/$i|cut -d '=' -f2|sed 's/ \%U$//g'|sed s'/\// /'g | tr " '" '\n' | tail -n1>/tmp/tmpbrs/$i
	#cat /tmp/tmpbrs/$i>>/tmp/browserexecs
done
BROWSE=`ls /tmp/tmpbrs`
for b in $BROWSE;do cat /tmp/tmpbrs/$b>>/tmp/installed-browsers
done
     NEW_BROWSER=`grep -v '#' /tmp/installed-browsers|head -n1`
     NEW_DEFAULT="exec $NEW_BROWSER \"\$@\""
	echo "sed -i 's/$CHANGE_DEFAULT/$NEW_DEFAULT/' /usr/local/bin/defaultbrowser" >/tmp/chgbrs
	. /tmp/chgbrs
	#puppybrs &
	 #sleep 5
	 #kill `ps|grep "puppy_brs"` 2>/dev/null
	#yaf-splash -font "-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1" -timeout 4 -placement top -outline 0 -bg green -text "$LOC_111" &
	gtkdialog-splash -icon gtk-dialog-info -timeout 5 -fontsize large -bg green -close never -text "$NEW_BROWSER""$LOC_111" &
}

#readme
function README(){
	Xdialog --title $LOC_308 --msgbox "$LOC_203" 0 0 0
}

#help menu
function HELP(){
	Xdialog --title $LOC_HELP --msgbox "$LOC_204" 0 0 0
}

#nvidia variable
NVIDIA_TEXT="
<frame nVidia>
 <hbox homogeneous=\"true\">
  <text use-markup=\"true\"><label>\"<b>$LOC_392B</b>\"</label></text>
 </hbox>
 <hbox homogeneous=\"true\">
  <text use-markup=\"true\"><label>\"<i>$LOC_392C</i>\"</label></text>
 </hbox>
 <hbox>
  <text><label>\"$LOC_392_96\"</label></text>
  <button relief=\"2\" tooltip-text=\"$LOC_392Att\">
   <input file>/root/.quickpet/icons/nvidia.png</input>
   <action>echo \"nvidia-96\" > /tmp/thepet</action>
   <action>GETPET &</action>
   <action>EXIT:096</action>
  </button>
 </hbox>
 <hbox>
  <text><label>\"$LOC_392_173\"</label></text>
  <button relief=\"2\" tooltip-text=\"$LOC_392Btt\">
   <input file>/root/.quickpet/icons/nvidia.png</input>
   <action>echo \"nvidia-173\" > /tmp/thepet</action>
   <action>GETPET &</action>
   <action>EXIT:173</action>
  </button>
 </hbox>
 <hbox>
  <text><label>\"$LOC_392_256\"</label></text>
  <button relief=\"2\" tooltip-text=\"$LOC_392Ctt\">
   <input file>/root/.quickpet/icons/nvidia.png</input>
   <action>echo \"nvidia-256\" > /tmp/thepet</action>
   <action>GETPET &</action>
   <action>EXIT:256</action>
  </button>
 </hbox>
 <hbox>
  <text><label>\"$LOC_392h\"</label></text>
  <button relief=\"2\">
   <input file stock=\"gtk-help\"></input>
   <action>$USEBROWSER $WORKDIR/nvidiahelp.htm &</action>
  </button>
 </hbox>
</frame>"

#nvidia driver grab
function NVIDIA(){
export invidia="
<window title=\"nVidia\" resizable=\"false\">
 <vbox>
$NVIDIA_TEXT
  <hbox homogeneous=\"true\">
   <button>
    <label>$LOC_OK</label>
    <input file stock=\"gtk-ok\"></input>
   </button>
  </hbox>
 </vbox>
</window>
"
gtkdialog3 -p invidia -c
unset invidia
}
#clear downloads
function CLEAR(){
Xdialog --title "$LOC_801" --clear \
        --yesno "$LOC_802 " 0 0 0
case $? in
0) rm -f $HOME/.quickpet/Downloads/* ;;
1) exit ;;
255) exit ;;
esac
}

#reset after change prefs
function RESET(){
	echo "SLEEP_SIZE=$SLEEP_SIZE" > $WORKDIR/sleeprc
	kill `ps | grep -w "quickpack" | awk '{print $1}'` 2>/dev/null
	quickpet &
}

#preferences
function PREFS(){
#read sleep config
. $WORKDIR/sleeprc
SLEEP_SIZE_ITEMS="<item>$SLEEP_SIZE</item>"
for I in 2 4 6 8 10 12 14 16 18 20; do SLEEP_SIZE_ITEMS=`echo "$SLEEP_SIZE_ITEMS<item>$I</item>"`; done

export qpprefs="
<window title=\"Quickpet - Options\">
 <vbox>
    <text><label> $LOC_301</label></text>
    <text use-markup=\"true\"><label>\"<b>$LOC_302 </b>\"</label></text>
	<text use-markup=\"true\"><label>\"<b>$LOC_298 </b>\"</label></text>
	<checkbox>
     <label>$LOC_299</label>
	  <variable>CHKBOX</variable>
	  <action>if true sed -i 's/CHKBOX=[a-z]*[a-z]/CHKBOX=true/' $WORKDIR/prefs.conf</action>
	  <action>if false sed -i 's/CHKBOX=[a-z]*[a-z]/CHKBOX=false/' $WORKDIR/prefs.conf</action>
	  <default>$CHKBOX</default>
	</checkbox>
	<text use-markup=\"true\"><label>\"<b>$LOC_303</b>\"</label></text>
	<radiobutton>
	<label>\"diddywahdiddy.net\"</label>
	<variable>RADIO1</variable>
	<action>if true sed -i 's/RADIO1=[a-z]*[a-z]/RADIO1=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO1=[a-z]*[a-z]/RADIO1=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO1</default>
	</radiobutton>

	<radiobutton>
	<label>\"ibiblio.org\"</label>
	<variable>RADIO2</variable>
	<action>if true sed -i 's/RADIO2=[a-z]*[a-z]/RADIO2=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO2=[a-z]*[a-z]/RADIO2=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO2</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.linux.hr\"</label>
	<variable>RADIO3</variable>
	<action>if true sed -i 's/RADIO3=[a-z]*[a-z]/RADIO3=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO3=[a-z]*[a-z]/RADIO3=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO3</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.lug.udel.edu\"</label>
	<variable>RADIO4</variable>
	<action>if true sed -i 's/RADIO4=[a-z]*[a-z]/RADIO4=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO4=[a-z]*[a-z]/RADIO4=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO4</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.nluug.nl\"</label>
	<variable>RADIO5</variable>
	<action>if true sed -i 's/RADIO5=[a-z]*[a-z]/RADIO5=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO5=[a-z]*[a-z]/RADIO5=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO5</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.sh.cvut.cz\"</label>
	<variable>RADIO6</variable>
	<action>if true sed -i 's/RADIO6=[a-z]*[a-z]/RADIO6=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO6=[a-z]*[a-z]/RADIO6=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO6</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.tu-chemnitz.de\"</label>
	<variable>RADIO7</variable>
	<action>if true sed -i 's/RADIO7=[a-z]*[a-z]/RADIO7=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO7=[a-z]*[a-z]/RADIO7=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO7</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.ussg.iu.edu\"</label>
	<variable>RADIO8</variable>
	<action>if true sed -i 's/RADIO8=[a-z]*[a-z]/RADIO8=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO8=[a-z]*[a-z]/RADIO8=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO8</default>
	</radiobutton>

	<radiobutton>
	<label>\"mirror.aarnet.edu.au\"</label>
	<variable>RADIO9</variable>
	<action>if true sed -i 's/RADIO9=[a-z]*[a-z]/RADIO9=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO9=[a-z]*[a-z]/RADIO9=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO9</default>
	</radiobutton>

	<radiobutton>
	<label>\"ftp.oss.cc.gatech.edu\"</label>
	<variable>RADIO10</variable>
	<action>if true sed -i 's/RADIO10=[a-z]*[a-z]/RADIO10=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO10=[a-z]*[a-z]/RADIO10=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO10</default>
	</radiobutton>

	<radiobutton>
	<label>\"mirror.internode.on.net\"</label>
	<variable>RADIO11</variable>
	<action>if true sed -i 's/RADIO11=[a-z]*[a-z]/RADIO11=true/' $WORKDIR/prefs.conf</action>
	<action>if false sed -i 's/RADIO11=[a-z]*[a-z]/RADIO11=false/' $WORKDIR/prefs.conf</action>
	<default>$RADIO11</default>
	</radiobutton>
	<text use-markup=\"true\"><label>\"<b>Increase this Value</b>\"</label></text>
   <hbox homogeneous=\"true\">


	<text><label>\"If you are having Timeout errors\"</label></text>
    <combobox width-request=\"50\">
     <variable>SLEEP_SIZE</variable>
$SLEEP_SIZE_ITEMS
	</combobox>
   </hbox>

   <hbox>
    <button>
     <label>$LOC_OK</label>
     <input file stock=\"gtk-ok\"></input>
     <action>RESET &</action>
     <action>EXIT:exit</action>
    </button>
   </hbox>

  </vbox>
</window>
"
gtkdialog3 -p qpprefs
unset qpprefs
}

function ABOUT(){

export qabout="
<window title=\"Quickpet - About\"icon-name=\"gtk-about\" resizable=\"false\">
 <vbox>
	<hbox homogeneous=\"true\">
	<pixmap>
    <input file>/usr/share/doc/puppylogo48.png</input>
    </pixmap>
    </hbox>
    <hbox>
    <vbox>
    <frame>
    <text use-markup=\"true\"><label>\"<b>Author </b>\"</label></text>
	<text><label>Michael Amadio - 01micko</label></text>
	<text use-markup=\"true\"><label>\"<b>Concept</b>\"</label></text>
	<text><label>Larry Short - playdayz</label></text>
	<text><label>\" \"</label></text>
	<text use-markup=\"true\"><label>\"<b>Contributors</b>\"</label></text>
	<text><label>Sigmund Berglund - zigbert</label></text>
	<text><label>Barry Kauler - BarryK</label></text>
	</frame>
	</vbox>
	<vbox>
	<frame>
	<text use-markup=\"true\"><label>\"<b>Translators</b>\"</label></text>
	<text><label>Dutch - Bert</label></text>
	<text><label>Swedish - MinHundHettePerro</label></text>
	<text><label>French - Alain Bernard -Tasgarth</label></text>
	<text><label>German - Markus Vedder -mave</label></text>
	<text><label>Italian - Jacopo</label></text>
	<text><label>Chinese - sasaqqdan</label></text>
	<text><label>Japanese - Norihiro Yoneda -YoN</label></text>
	<text><label>Russian - bit</label></text>
	<text><label>Spanish - Pedro Worcel - droope</label></text>
	</frame>
	</vbox>
	</hbox>
	<hbox>
	<text use-markup=\"true\"><label>\"<b>Licenced under the GPL 2010. No Warranty</b>\"</label></text>
    <button>
     <label>$LOC_306</label>
     <input file stock=\"gtk-dnd\"></input>
     <action>defaulthtmlviewer file:///root/puppy-reference/doc/legal/gpl-3.0.htm &</action>
    </button>
	</hbox>
	<hbox>
    <button>
     <label>$LOC_OK</label>
     <input file stock=\"gtk-ok\"></input>
    </button>
	</hbox>
  </vbox>
</window>
"
gtkdialog3 -p qabout
unset qabout
}

#make html file out of "lupu recommends", execute browser, if installed
function LUPUREC(){
	#make a html page reflecting the video recommendation, opens in viewer if no browser/connection else browser
	#construct page in /tmp
	BODY="`cat /tmp/luci_recomend|sed 's/ below//'`"
	echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' >/tmp/lupurec.htm
	echo '<html>' >>/tmp/lupurec.htm
	echo '<head>' >>/tmp/lupurec.htm
	echo '<title>' >>/tmp/lupurec.htm
	echo 'lupu recommends' >>/tmp/lupurec.htm
	echo '</title>' >>/tmp/lupurec.htm
	echo '</head>' >>/tmp/lupurec.htm
	echo '<body>' >>/tmp/lupurec.htm
	echo '<H1>Lupu Recommends</H1>' >>/tmp/lupurec.htm
	echo '<br>' >>/tmp/lupurec.htm
	echo '<H2>Graphics Help</H2>' >>/tmp/lupurec.htm
	echo '<br>' >>/tmp/lupurec.htm
	if [ "$USEBROWSER" = "gtkmoz" ];then echo "You really should install a browser capable of translation if you need to translate this page." >>/tmp/lupurec.htm
		else echo "You can translate this page if your browser supports translation." >>/tmp/lupurec.htm
	fi
	echo '<br>' >>/tmp/lupurec.htm
	echo '<hr>' >>/tmp/lupurec.htm
	echo '<br>' >>/tmp/lupurec.htm
	echo "$BODY in Quickpet" >>/tmp/lupurec.htm
	echo '</body>' >>/tmp/lupurec.htm
	echo '</html>' >>/tmp/lupurec.htm
	#execute page in browser or viewer
	$USEBROWSER /tmp/lupurec.htm &
}

#graphics test
function graphics(){
. /usr/local/graphics-test/graphix_test
CARD_BRAND=`cat /tmp/card_brand`
if [ $CARD_BRAND = nVidia ];then CARD_TEXT="$NVIDIA_TEXT"
	else CARD_TEXT=""
fi
DISPLAY_TEXT=`cat /tmp/luci_recomend`
export DISPLAY_TEXT
export grafix="
<window title=\"Graphics\" resizable=\"false\">
 <vbox>
  <frame Lupu Recommends>
   <hbox width-request=\"420\">
   <vbox>
    <text width-request=\"400\"><label>\"${DISPLAY_TEXT}\"</label></text>
   </vbox>
   </hbox>
   <hbox width-request=\"420\">
   <text width-request=\"360\"><label>\"$LOC_705\"</label></text>
   <button tooltip-text=\"$LOC_706\">
    <input file stock=\"gtk-dialog-info\"></input>
    <action>LUPUREC &</action>
   </button>
   </hbox>
  </frame>
${CARD_TEXT}
   <hbox homogeneous=\"true\">
    <button>
     <input file stock=\"gtk-ok\"></input>
     <label>$LOC_OK</label>
    </button>
   </hbox>
 </vbox>
</window>
"
gtkdialog3 -p grafix -c
unset grafix
}

#reprt-video funtion
function REPVID(){
	report-video
	#RPT=`cat /tmp/report-video`
	xmessage -timeout 20 -bg thistle -center -buttons "" -file /tmp/report-video -title "Report Video" &
	#/usr/X11R7/bin/yaf-splash -bg thistle -timeout 20 -outline 0 -margin 4 -text "$RPT" &
}

case $1 in
	BI)
#browser-installer
. $WORKDIR/browsersrc

export BWIZ="
$BROWSELIST
"
gtkdialog3 -p BWIZ
unset BWIZ

	;;

	*)
#quickpet

##THE TABS
. $WORKDIR/guirc

################### GUI ########################

export quickpack="
<window title=\"Quickpet v$VER\" icon-name=\"gtk-yes\">
 <vbox>
 <menubar>
    <menu>
         <menuitem icon=\"gtk-preferences\">
           <label>$LOC_304</label>
           <action>PREFS</action>
         </menuitem>
         <menuitem icon=\"gtk-quit\">
           <label>$LOC_QUIT</label>
           <action>exit:quit</action>
         </menuitem>
         <menuitem icon=\"gtk-directory\" tooltip-text=\"$LOC_353\">
           <label>$LOC_351</label>
           <action>rox /root/.quickpet/Downloads</action>
         </menuitem>
         <menuitem icon=\"gtk-clear\" tooltip-text=\"$LOC_354\">
           <label>$LOC_352</label>
           <action>CLEAR</action>
         </menuitem>
         <menuitem icon=\"gtk-properties\">
           <label>$LOC_356</label>
           <action>REPVID</action>
         </menuitem>
         <menuitem icon=\"gtk-about\">
           <label>$LOC_355</label>
           <action>ABOUT</action>
         </menuitem>
        <label>$LOC_FILE</label>
        </menu>
        <menu>
         <menuitem icon=\"gtk-help\">
           <label>$LOC_HELP</label>
           <action>HELP</action>
         </menuitem>
         <menuitem icon=\"gtk-yes\">
           <label>Quickpet $LOC_305</label>
           <action>$USEBROWSER  http://puppylinux.org/wikka/LucidPuppyQuickpet &</action>
         </menuitem>
         <menuitem icon=\"gtk-dnd\">
           <label>$LOC_306</label>
           <action>defaulthtmlviewer file:///root/puppy-reference/doc/legal/gpl-3.0.htm &</action>
         </menuitem>
        <label>$LOC_307</label>
      </menu>
      <menu>
		 <menuitem>
           <label>$LOC_300</label>
           <action>/usr/local/petget/pkg_chooser.sh &</action>
         </menuitem>
         <menuitem>
           <label>$LOC_308</label>
           <action>README</action>
         </menuitem>
         <menuitem>
           <action>$USEBROWSER http://puppylinux.org/wikka/Compiling &</action>
           <label>Developer Module</label>
         </menuitem>
         <menuitem>
           <label>DuDE</label>
           <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?t=53680 &</action>
         </menuitem>
         <menuitem>
           <label>Firewallstate</label>
           <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=434498#434498 &</action>
         </menuitem>
         <menuitem>
           <label>Java</label>
           <action>$USEBROWSER http://puppylinux.org/wikka/JavaRuntimeEnvironment &</action>
         </menuitem>
         <menuitem>
           <label>Open Office</label>
           <action>$USEBROWSER http://puppylinux.org/wikka/OpenOffice &</action>
           <action>yaf-splash -font \"-misc-dejavu sans-bold-r-normal--16-0-0-0-p-0-iso10646-1\" -timeout 10 -placement top -outline 0 -bg lightgreen -text \"Note: This package installs to /mnt/home, you need to install Puppy first\" &</action>
         </menuitem>
         <menuitem>
           <label>precord</label>
           <action>$USEBROWSER http://murga-linux.com/puppy/viewtopic.php?t=49907 &</action>
         </menuitem>
         <menuitem>
            <label>Snap2 Backup</label>
			<action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=374387#374387 &</action>
          </menuitem>
          <menuitem>
             <label>Startmount</label>
             <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?t=50845 &</action>
          </menuitem>
          <menuitem>
             <label>Sunbird</label>
             <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=409050#409050 &</action>
          </menuitem>
        <label>$LOC_350</label>
      </menu>

      <menu>
         <menuitem>
           <label>SFS $LOC_307</label>
           <action>$USEBROWSER http://puppylinux.org/wikka/LucidPuppySFS &</action>
         </menuitem>
         <menuitem>
           <label>Edit SFS</label>
           <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=408314#408314 &</action>
         </menuitem>
         <menuitem tooltip-text=\"$LOC_357\">
           <label>sfs_linker</label>
           <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=352836#352836 &</action>
         </menuitem>
         <menuitem>
             <label>Sfs Install</label>
             <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=291574#291574 &</action>
         </menuitem>
         <menuitem>
           <label>Petmaker Plus (includes SFS)</label>
           <action>$USEBROWSER http://www.murga-linux.com/puppy/viewtopic.php?p=289038#289038 &</action>
         </menuitem>
     <label>SFS</label>
   </menu>

 </menubar>
  <hbox>
   <vbox>
    <pixmap>
    <input file>/usr/share/doc/puppylogo48.png</input>
    </pixmap>
   </vbox>
   <vbox>
    <text use-markup=\"true\" width-request=\"300\"><label>\"<b>$LOC_309 Quickpet</b>\"</label></text>
     <text width-request=\"350\"><label>$LOC_310</label></text>
   </vbox>
  </hbox>
     <notebook labels=\"$LOC_311|$LOC_312|$LOC_313|$LOC_314|$LOC_315\">
   <vbox>
     <text><label>$LOC_316</label></text>
$PETLIST
    </vbox>
    <vbox>
     <text><label>$LOC_317</label></text>
$NETLIST
    </vbox>
    <vbox>
     <text><label>$LOC_318</label></text>
$MOREPETS
    </vbox>
    <vbox>
     <text><label>$LOC_319</label></text>
$DRIVERS
    </vbox>
    <vbox>
     <text><label>$LOC_315</label></text>
$UPDATE
    </vbox>
    </notebook>
   <hbox>
    <button>
     <label>$LOC_INFO</label>
     <input file stock=\"gtk-info\"></input>
     <action>INFO</action>
    </button>
    <button>
    <input file stock=\"gtk-ok\"></input>
    <label>$LOC_OK</label>
    </button>
   </hbox>
 </vbox>
 <action signal=\"hide\">exit:Exit</action>
</window>"

gtkdialog3 -p quickpack

unset quickpack

	;;
esac
exit 0
###END###

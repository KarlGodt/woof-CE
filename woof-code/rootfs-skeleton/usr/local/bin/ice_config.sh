#!/bin/ash
# icewm configuration ver 0.6
#  01micko gpl 2010
# Credit to tronkel for the idea, thanks Jack
#20100730
#20100731 #added check to see if icewm is running, added taskbar position, top/bottom, added autohide option
#20100801 #added window list on taskbar
#20100802 #added show/hide cpu status

  _TITLE_="Puppy_ice_config"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script
with GTKdialog GUI to alter a few variables in
$HOME/.icewm/preferences
config file ."

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
 set +e
 source /etc/rc.d/f4puppy5 && {
 set +n
 source /etc/rc.d/f4puppy5; } || echo "WARNING : Could not source /etc/rc.d/f4puyppy5 ."

ADD_PARAMETER_LIST=
ADD_PARAMETERS=
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
for i in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
} || echo "Warning : No /etc/rc.d/f4puppy5 installed."
# various variables if not set globally in f4puppy5
VERBOSE=1
QUIET=
VERB=-v

__check_current_wm__(){
CURWM=`head -c5 /etc/windowmanager`
if [[ $CURWM != icewm ]];then Xdialog --title "Icewm" --timeout 6 --msgbox "You are not running Icewm. \nIcewm needs to be running to use this tool."  0 0 0 &
        exit
fi
}

IMGDIR="/usr/share/pixmaps"

. $HOME/.icewm/preferences 2>$ERR
if [ "$ShowTaskBar" = "1" ];then CHKBOX1=true
        else CHKBOX1=false
fi
if [ "$TaskBarShowShowDesktopButton" = "1" ];then CHKBOX2=true
        else CHKBOX2=false
fi
if [ "$TaskBarShowWindowIcons" = "1" ];then CHKBOX3=true
        else CHKBOX3=false
fi
if [ "$TaskBarDoubleHeight" = "0" ];then CHKBOX4=true
        else CHKBOX4=false
fi
if [ "$TaskBarAtTop" = "0" ];then CHKBOX5=true
        else CHKBOX5=false
fi
if [ "$TaskBarAutoHide" = "0" ];then CHKBOX6=true
        else CHKBOX6=false
fi
if [ "$TaskBarShowWindowListMenu" = "0" ];then CHKBOX7=true
        else CHKBOX7=false
fi
if [ "$TaskBarShowCPUStatus" = "0" ];then CHKBOX8=true
        else CHKBOX8=false
fi
#desktop number function
#function
DESKTOPS_old(){
        REPLACE=`grep 'WorkspaceNames' $HOME/.icewm/preferences`
if [ "$NUM" = "1" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "2" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "3" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "4" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \", \" 4 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "5" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \", \" 4 \", \" 5 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "6" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \", \" 4 \", \" 5 \", \" 6 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "7" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \", \" 4 \", \" 5 \", \" 6 \", \" 7 \"" $HOME/.icewm/preferences
elif [ "$NUM" = "8" ];then rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = \" 1 \", \" 2 \", \" 3 \", \" 4 \", \" 5 \", \" 6 \", \" 7\", \" 8 \"" $HOME/.icewm/preferences
        fi
}

#function
DESKTOPS(){
        REPLACE=`grep 'WorkspaceNames' $HOME/.icewm/preferences`
        for num in `seq 1 1 $NUM`;do
STRING="$STRING \" $num \","
        done
STRING="${STRING%,*}"
echo "$STRING"
rpl.sh $QUIET $VERB "$REPLACE" "WorkspaceNames = $STRING" $HOME/.icewm/preferences
}
#export -f DESKTOPS

#function
__MSG__(){
        Xdialog --title "Icewm" --timeout 10 --msgbox "Please restart Icewm from: \n Start > Shutdown > Restart Icewm"  0 0 0 &
}
#export -f MSG
MSG="Xdialog --title \"Icewm\" --timeout 10 --msgbox \"Please restart Icewm from: \n Start > Shutdown > Restart Icewm\"  0 0 0 &"
echo "#!/bin/ash
$MSG" >/tmp/ice_config_ok.sh
chmod +x /tmp/ice_config_ok.sh

NUM="`grep 'WorkspaceNames' $HOME/.icewm/preferences|tail -c4|head -c1`"
NUMBERS="<item>$NUM</item>"
for I in `seq 0 1 9`; do NUMBERS=`echo "$NUMBERS<item>$I</item>"`; done

#MAIN GUI
export MAIN="
<window title=\"Icewm Configuration\" resizable=\"false\">
 <vbox>
  <hbox homogeneous=\"true\">
   <pixmap>
    <input file>$IMGDIR/icewm-logo.png</input>
   </pixmap>
  </hbox>
   <frame Choose your Icewm options>
   <checkbox tooltip-text=\"Checked shows Taskbar, Unchecked hides Taskbar\">
     <label>Toggles Show/Hide Taskbar</label>
          <variable>CHKBOX1</variable>
          <action>if true rpl.sh $QUIET $VERB 'ShowTaskBar=0' 'ShowTaskBar=1' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'ShowTaskBar=1' 'ShowTaskBar=0' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX1</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked shows Show Desktop Button, Unchecked hides Show Desktop Button\">
     <label>Toggles Show/Hide Show Desktop Button</label>
          <variable>CHKBOX2</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarShowShowDesktopButton=0' 'TaskBarShowShowDesktopButton=1' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarShowShowDesktopButton=1' 'TaskBarShowShowDesktopButton=0' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX2</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked shows Taskbar Window Icons, Unchecked hides Taskbar Window Icons\">
     <label>Toggles Show/Hide Taskbar Window Icons</label>
          <variable>CHKBOX3</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarShowWindowIcons=0' 'TaskBarShowWindowIcons=1' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarShowWindowIcons=1' 'TaskBarShowWindowIcons=0' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX3</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked shows normal Taskbar Height, Unchecked Doubles Taskbar Height\">
     <label>Toggles Single/Double Taskbar Height</label>
          <variable>CHKBOX4</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarDoubleHeight=1' 'TaskBarDoubleHeight=0' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarDoubleHeight=0' 'TaskBarDoubleHeight=1' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX4</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked shows Taskbar at bottom of screen, Unchecked at top\">
     <label>Toggles Bottom/Top Taskbar Position</label>
          <variable>CHKBOX5</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarAtTop=1' 'TaskBarAtTop=0' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarAtTop=0' 'TaskBarAtTop=1' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX5</default>
        </checkbox>
        <checkbox tooltip-text=\"Unchecked Auto Hides the Taskbar\">
     <label>Toggles Show/Autohide the Taskbar</label>
          <variable>CHKBOX6</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarAutoHide=1' 'TaskBarAutoHide=0' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarAutoHide=0' 'TaskBarAutoHide=1' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX6</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked hides Window List Button on Taskbar, Unchecked shows\">
     <label>Toggles Show/Hide Window List button</label>
          <variable>CHKBOX7</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarShowWindowListMenu=1' 'TaskBarShowWindowListMenu=0' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarShowWindowListMenu=0' 'TaskBarShowWindowListMenu=1' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX7</default>
        </checkbox>
        <checkbox tooltip-text=\"Checked hides CPU Status in System Tray, Unchecked shows\">
     <label>Toggles Hide/Show CPU Status in System Tray</label>
          <variable>CHKBOX8</variable>
          <action>if true rpl.sh $QUIET $VERB 'TaskBarShowCPUStatus=1' 'TaskBarShowCPUStatus=0' $HOME/.icewm/preferences 2>$ERR</action>
          <action>if false rpl.sh $QUIET $VERB 'TaskBarShowCPUStatus=0' 'TaskBarShowCPUStatus=1' $HOME/.icewm/preferences 2>$ERR</action>
          <default>$CHKBOX8</default>
        </checkbox>
   <hbox>
    <combobox width-request=\"50\">
         <variable>NUM</variable>
$NUMBERS
        </combobox>
        <text><label>Set number of Desktops In Taskbar</label></text>
   </hbox>
   </frame>
   <hbox>
        <button ok>

         <action>/tmp/ice_config_ok.sh &</action>
         <action>EXIT:OK</action>
        </button>
   </hbox>
 </vbox>
</window>"
#<action>DESKTOPS</action>

# various variables if not set globally in f4puppy5
VERBOSE=1
QUIET=
VERB=-v
DBG=-d
NOWARN=-w

# run GUI
gtkdialog3 $DBG -p MAIN |
while read aLINE;  # alternative to <action>
do
        c=$((c+1))
        [ "$VERBOSE" ] && echo "$c aLINE='$aLINE'"
        case "$aLINE" in
         NUM=\"[0-9]\") NEWNUM=${aLINE//[[:alpha:][:punct:]]/}
         [ "$VERBOSE" ] && echo "NEWNUM='$NEWNUM'"
          for N in `seq 0 1 $NEWNUM`; do
           wsNAME="$wsNAME \" $N \","
          done
          wsNAME="${wsNAME%,*}"
         [ "$VERBOSE" ] && echo "wsNAME='$wsNAME'"
         sed -i".sedBAK" "s%WorkspaceNames=.*%WorkspaceNames=$wsNAME%" $HOME/.icewm/preferences
         [ $? = 0 ] && rm $HOME/.icewm/preferences.sedBAK || /bin/cp -a --backup=numbered  $HOME/.icewm/preferences.sedBAK $HOME/.icewm/preferences
       ;;
       *):
       ;;
       esac
done

unset MAIN

# Very End of this file 'usr/sbin/ice_config.sh' #
###END###

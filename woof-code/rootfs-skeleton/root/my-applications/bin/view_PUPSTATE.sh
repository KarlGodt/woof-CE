#!/bin/sh


START_Dir="`pwd`"
Conf_File_Dir_Name='/etc/rc.d'
Conf_File_Base_Name='PUPSTATE'
Conf_File_Real_Path='/etc/rc.d/PUPSTATE'
FullPath_Conf_File='/etc/rc.d/PUPSTATE'

Tmp_Dir='/tmp/view_PUPSTATE'
[ ! -d "$Tmp_Dir" ] && mkdir -p "$Tmp_Dir"

#cp /etc/rc.d/PUPSTATE /tmp/
##check for older files from this program
TARS=`find "$Tmp_Dir" -name "view_PUPSTATE.files.[0-9]*.tar.gz"`
#xmessage -bg orange -title "TARS" "$TARS" &
if [ "`echo "$TARS" | wc -l`" -gt 9 ] ; then
KeepTARS=`echo "$TARS" | tail -n 9`
grep_PAT=`echo "$KeepTARS" | sed 's/\./\\\\./g ; s/\-/\\\\-/g'`
#xmessage -bg lightgreen -title "grep_PAT" "$grep_PAT" & 
#xmessage -bg green -title "KeepTARS" "$KeepTARS" & 
DelTARS=`echo "$TARS" | grep -v "$grep_PAT"`
#xmessage -bg red -geometry 300x70+100+100 -title "DelTARS" "$DelTARS" &
for content in $DelTARS ; do rm -f $content ; done ; 
fi
echo 1
##check if PUPSTATE file is OK
if [ ! -f /etc/rc.d/PUPSTATE ] ; then
rox /etc/rc.d
if [ -d /initrd/pup_rw ] ; then
rox /initrd/pup_rw/
rox /initrd/pup_rw/etc/
rox /initrd/pup_rw/etc/rc.d
fi
xmessage -bg red "Sorry , the file /etc/rc.d/PUPSTATE does not exist
or is not in a readable state .
If you are running the LiveCD or n already installed
frugal instalation on USB or HardDrive , then something
seems to be seriously wrong .
Tis is what the ls and file commands found out about it :
`ls -l /etc/rc.d/PUPSTATE` 
`file /etc/rc.d/PUPSTATE`

If rox is showing an STALE FILE HANDLE , 
try to fix it by deleting the hidden whiteout files
created by the aufs (Another Union File System) .
You may need to click on the eye or glasses to see them
in the file manager window .

If you are running a full installation , try to fix it
by running the fsck command from another partition
or USB or LiveCD ." 

exit
fi

##main part
. /etc/rc.d/PUPSTATE
echo 2
cat -n /etc/rc.d/PUPSTATE  | tr '[[:blank:]]' ' ' | tr -s ' ' > $Tmp_Dir/view_PUPSTATE_pre.0
cat $Tmp_Dir/view_PUPSTATE_pre.0 |sed 's/^[[:blank:]]*//g ; s/|/_with_/g' > $Tmp_Dir/view_PUPSTATE_pre.1 
cat $Tmp_Dir/view_PUPSTATE_pre.1 | sed "
s/'\([[:alnum:]]\)/\1/g ; 
s/'\([[:blank:]]*[[:alnum:]]\)/\1/g ; 
s/'\([[:punct:]]*[[:alnum:]]\)/\1/g ; 
s/\([[:alnum:]]\)'/\1/g ; 
s/\([[:alnum:]][[:blank:]]*\)'/\1/g
" > $Tmp_Dir/view_PUPSTATE_pre.2  ##does not work to filer out the "'" 201_10_03

cat $Tmp_Dir/view_PUPSTATE_pre.2 | tr -s ' ' > $Tmp_Dir/view_PUPSTATE_pre.3
echo 3
##formatting the viewer input:(
#func(){
sed -i 's/\(^[[:digit:]]*\)\ /\1|/g' $Tmp_Dir/view_PUPSTATE_pre.3
sed -i 's/\(^[[:digit:]]\)|/00\1|/g' $Tmp_Dir/view_PUPSTATE_pre.3
sed -i 's:\(^[[:digit:]][[:digit:]]\)|:0\1|:g' $Tmp_Dir/view_PUPSTATE_pre.3
sed -i 's/\=/\|/g' $Tmp_Dir/view_PUPSTATE_pre.3
sed -i 's/\,/\|/g' $Tmp_Dir/view_PUPSTATE_pre.3

#}
echo 4
cat -n $Tmp_Dir/view_PUPSTATE_pre.3 | sed 's/^[[:blank:]]*//g' | grep -v -E -e '^[[:digit:]]*[[:blank:]]*[[:digit:]]*\|\#|^\#|^[[:blank:]]*\#' | tr '\t' ' ' > $Tmp_Dir/view_PUPSTATE_valid_lines

cat -n $Tmp_Dir/view_PUPSTATE_pre.3 | sed 's/^[[:blank:]]*//g' | grep -E -e '^[[:digit:]]*[[:blank:]]*[[:digit:]]*\|\#|^\#|^[[:blank:]]*\#' | tr '\t' ' ' | tr -s ' ' > $Tmp_Dir/view_PUPSTATE_comment_lines

echo 5
sed -i 's/|[[:blank:]]*\([[:alnum:]]*\)/|\1/g' $Tmp_Dir/view_PUPSTATE_valid_lines 
#sed -i 's/[[:blank:]]*/\ /g' $Tmp_Dir/view_PUPSTATE_valid_lines 
sed -i 's/\ /|/g' $Tmp_Dir/view_PUPSTATE_valid_lines
sed -i 's/\ /|/'  $Tmp_Dir/view_PUPSTATE_comment_lines

##sed -r -i 's/(.)/\1\ /g' /tmp/view_PUPSTATE_comment_lines
sed -i -r 's/([[:alnum:]]* )([[:alnum:]]* )([[:alnum:]]* )([[:alnum:]]* )([[:alnum:]]* )/\1\2\3\4\5\|/g' $Tmp_Dir/view_PUPSTATE_comment_lines

echo 6
rm -f $Tmp_Dir/view_PUPSTATE
END='not_now' ; line_nr=0
while [ "$END" != "now" ] ; do 
line_nr=$((line_nr+1))
grep_PAT="$line_nr"'|'
LINE_STR=`grep "^$grep_PAT" $Tmp_Dir/view_PUPSTATE_valid_lines`
[ -z "$LINE_STR" ] && LINE_STR=`grep "^$grep_PAT" $Tmp_Dir/view_PUPSTATE_comment_lines`
[ -z "$LINE_STR" ] && END='now'
echo "$LINE_STR" >> $Tmp_Dir/view_PUPSTATE
done
echo 7
sed -i '/^$/d' $Tmp_Dir/view_PUPSTATE


###GUI part
EXP_LABEL='<label> line__nr | line__NR | VARIABLE | VALUE  | VALUE__2 | VALUE__3' 
echo 8
###<label> line__nr | line__NR | VARIABLE | VALUE | VALUE__2 | VAL__3 | VAL__4 | VAL__5 | VAL__6 | VAL__7 | VAL__8 | VAL__9 | VAL__10 | VAL__11 |  VAL__12 </label>


if [ "$FASTPARTS" ] ; then
FASTP="$FASTPARTS"
#FASTP=`echo "$FASTP" | tr '|' '@'`
#FASTP=`echo "$FASTP" |sed 's/^[[:blank:]]*// ; s/[[:blank:]]*$//'`
##FASTP="`echo "$FASTP" | tr ' ' '\n'`" 
echo "$FASTPARTS"
#FPcount=0
#for content in $FASTP ; do
#FPcount=$((FPcount+1)) ; done
FPcount=`echo "$FASTP" | wc -w`
echo 'FPcount='"$FPcount"
if [ "$FPcount" -gt 3 ] ; then
while_count=3
while [ "$while_count" != "$FPcount" ] ; do
while_count=$((while_count+1))
echo 'while_count='"$while_count"
EXP_LABEL="$EXP_LABEL | VAL__$while_count "
done
fi
fi
EXP_LABEL="$EXP_LABEL </label>"
echo 10
export VIEW_RC_PUPSTATE="<window title=\"Puppy PUPSTATE viewer\" icon-name=\"gtk-about\" opacity=\"0\" modal=\"TRUE\" is-active=\"TRUE\" has-toplevel-focus=\"TRUE\" gravity=\"1\">
  <vbox>
   <text><label>SIMPLE GTKDIALOG3 VIEWER
/etc/rc.d/PUPSTATE</label></text>
   <frame PUPSTATE VARS created by initrd /$psubdir/initrd.gz's init<init>
    <tree>
      $EXP_LABEL
      <variable>ONESTATE</variable>
       <input>cat $Tmp_Dir/view_PUPSTATE</input>
       <width>700</width><height>180</height>
    </tree>
   </frame>
   <hbox homogeneous=\"FALSE\" spacing=\"10\">
   <vbox><text><label>To open the PUPSTATE file , click 'run Geany' :</label></text></vbox>
     <button><label>run Geany</label><input file stock=\"gtk-edit\"></input>
     <action>cp /etc/rc.d/PUPSTATE /etc/rc.d/PUPSTATE.view_PUPSTATE.bac.$$</action>
     <action>defaulttexteditor /etc/rc.d/PUPSTATE &</action>
     </button>
   <vbox><text><label>  Open the filemanager to view rc -directory:</label></text></vbox>
     <button><label>rc folder</label><input file stock=\"gtk-open\"></input>
     <action>rox /etc/rc.d &</action>
     </button>
    <button cancel></button>
   </hbox>
   <hbox>
   <text hadjustment=\"20\" vadjustment=\"60\">
   <label>To open the tmp PUPSTATE file in Gnumeric:</label></text>
   <button use-underline=\"true\" use-stock=\"TRUE\" \
   image-position=\"RIGHT\">
   <label>_Gnumeric</label>
    <action>gnumeric $Tmp_Dir/view_PUPSTATE &</action>
    </button>
    <vbox>
    <frame THIS FRAME THIS FRAME THIS FRAME THIS FRAME THIS FRAME>
    <text><label>T</label></text>
    
    </frame>
    </vbox>
    </hbox>
  </vbox>
 </window>
" 
#TODO <action>chmod 0444 /etc/rc.d/PUPSTATE</action> 
RETPARAMS="`gtkdialog3 --program=VIEW_RC_PUPSTATE`"

echo "$RETPARAMS" | tr ' ' ':'
#TIME=`date +%l%M%S` ## %T   time; same as %H:%M:%S | %H   hour (00..23)
TIME=`date +%H%M%S`

cd $Tmp_Dir
tar -czf "view_PUPSTATE.files.$TIME.tar.gz" view_PUPSTATE_pre.[0-9] view_PUPSTATE_valid_lines view_PUPSTATE_comment_lines view_PUPSTATE /etc/rc.d/PUPSTATE

cd "$START_Dir"

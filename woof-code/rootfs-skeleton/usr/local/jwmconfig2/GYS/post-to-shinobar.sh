# 2009-NOV-06 low and high position fixed
total=`wc -l /root/.jwmrc-tray | sed -e 's/ *//' | sed -e 's/ .*//g'` ### get total number of lines
low=`grep -n '^[[:blank:]]*<TrayButton' /root/.jwmrc-tray | head -n 1| cut -d':' -f1`  ### get line number of the first button(Menu)
#high=`grep -n '^[[:blank:]]*<TrayButton' /root/.jwmrc-tray | tail -n 1| cut -d':' -f1` ### get line number of the last button
high=`grep '<!-- Additional Pager attributes; width, height -->' -n /root/.jwmrc-tray | sed -e 's/\:.*>//g'` ### get line number with Additional Pager
high=`echo "(("$high" - 0))" | bc -l`
last=`echo "(("$total" - "$high" + 2))" | bc -l`
begin=`echo "(("$low" + 1))" | bc -l` ### first line with panel buttons
#end=`echo "(("$high" - 1))" | bc -l` ### last line with panel buttons
cat /root/.jwmrc-tray | head -n "$low" > /tmp/jwmrc-tray-head.txt
cat /root/.jwmrc-tray | tail -n "$last" > /tmp/jwmrc-tray-tail.txt


if [ "$choice" = Move ]; then
grep -n '<TrayButton popup' /root/.jwmrc-tray | grep -v '<\!--' > /tmp/g0.txt
zz=`grep -c '<TrayButton popup' /tmp/g0.txt`  ##total nr of buttons
yy=0
y=1
z=`echo "(("$high" - "$begin"))" | bc -l` ##difference of high - begin ~total nr of buttons
echo $z
echo $begin
echo $high
bb=`expr $begin - 1`
echo 380
echo $bb

while [ "$begin" != "$high" ]; do
(( bb++ ))  #bb=becomes begin
echo $bb
PB2=`cat /root/.jwmrc-tray  | sed -n ""$begin"p" | sed -e 's/<TrayButton popup="//g' | sed -e 's/\".*//g' | sed 's/^[ \t]*//'`
echo $PB2
#echo $PB2 > /tmp/jwmrc-tray-panel-$z.txt
#TTPT=`cat /root/.jwmrc-tray | sed -n ""$begin"p"`
#echo $TTPT > /tmp/jwmrc-tray-panel-$z.txt
#cat /tmp/jwmrc-tray-panel-$z.txt
SKIP=""
echo "$PB2" | grep -q '^<!--' && SKIP="yes"
[ "$PB2" = "" ] && SKIP="yes"
#[ "$SKIP" = "yes" ] && y=`expr $y - 1 `
echo $y
# echo $PB2 > /tmp/jwmrc-tray-move-$y.txt
LINE=`cat -n  /root/.jwmrc-tray | grep -w $bb -m 1` ##grep begin
echo 399
echo $LINE
LINEwoNr=`echo $LINE | cut -f 2-99 -d ' '` ## echo $LINE without quotes squeezes/deletes the many blanks
echo 402
echo "$LINEwoNr"
echo "$LINEwoNr" > /tmp/jwmrc-tray-move-$bb.txt ##begin
cat /tmp/jwmrc-tray-move-$bb.txt
echo 406
if [ "$SKIP" != "yes" ]; then
(( yy++ )); echo $yy ##first button to move
echo $bb  ##bb=begin
by=`expr $bb + $yy` ##begin+1
echo $by
echo 412
TTPT=`cat /root/.jwmrc-tray | grep "$PB2"`
echo $TTPT > /tmp/jwmrc-tray-move-$by.txt ##begin+1
cat /tmp/jwmrc-tray-move-$by.txt
#zz=`expr $z - 1` ##difference high - begin -1      
echo line 417
echo $zz
#echo $TTPT > /tmp/jwmrc-tray-move-$zz.txt
#at /tmp/jwmrc-tray-move-$zz.txt
#grep -n '<TrayButton popup' /root/.jwmrc-tray | grep -v '<\!--' > /tmp/g0.txt
#zz=`grep -c '<TrayButton popup' /tmp/g0.txt`


Xdialog --title "INPUT BOX" \
        --inputbox "$PB2 is button $yy of your $zz buttons.\n\
\n\
If you would like that button in another\n\
position please enter the number below." 18 45 2> /tmp/inputbox.tmp.$$

retval=$?
input=`cat /tmp/inputbox.tmp.$$`
rm -f /tmp/inputbox.tmp.$$
echo 434
echo $input
case $retval in
  0)
    echo "Input string is '$input'";;
  1)
    echo "Cancel pressed."
    rm -f /tmp/jwmrc-tray*
    exit 0
    ;;
  255)
    echo "Box closed."
    rm -f /tmp/jwmrc-tray*
    exit 0
    ;;
esac

if [ "$retval" != 0 ]; then
exit 0
fi

if [ "$input" != "" ]; then
#ls /tmp/jwmrc-tray-tmp-$input.txt
echo 457
#ls /tmp/jwmrc-tray-tmp-$zz.txt
echo 459
#ls /tmp/jwmrc-tray-tmp-$z.txt
echo 461
#ls /tmp/jwmrc-tray-tmp-$z.txt
echo 463
bbb=`expr $bb + $input` ##begin + input ##bbb for checking  ##wrong should be bbb=input
if [ "`ls /tmp/jwmrc-tray-tmp-$bbb.txt`" = "/tmp/jwmrc-tray-tmp-$bbb.txt" ]; then
echo 466
Xdialog --title "MESSAGE BOX" \
        --msgbox "Position "$input"
        has already been selected.
        you must now start over." 10 41

case $? in
  0)
    echo "OK" 464 ;;
  255)
    echo "Box closed."
    rm -f /tmp/jwmrc-tray*
    exit 0
    ;;
esac
rm -f /tmp/jwmrc-tray*
exit 0

fi # 465
echo 485
mv /tmp/jwmrc-tray-move-"$by".txt /tmp/jwmrc-tray-tmp-"$input".txt
echo 457
else # 455
echo 489
bbb=`expr $bb + $input` ##wrong:input="" should be bbb=`expr $bb + $y` or better bbb=y
if [ "`ls /tmp/jwmrc-tray-tmp-"$bbb".txt`" = /tmp/jwmrc-tray-tmp-"$bbb".txt ]; then #506

Xdialog --title "MESSAGE BOX" \
        --msgbox "Position "$y"
        has already been selected.
        You must now start over." 10 41

case $? in
  0)
    echo "OK";;
  255)
    echo "Box closed."
    rm -f /tmp/jwmrc-tray*
    exit 0
    ;;
esac
rm -f /tmp/jwmrc-tray*
exit 0
fi # 491
fi # 488
echo 511
echo $y
# mv /tmp/jwmrc-tray-move-$y.txt /tmp/jwmrc-tray-tmp-$y.txt

#fi # 488
else # 403
mv /tmp/jwmrc-tray-move-$bb.txt /tmp/jwmrc-tray-tmp-$bb.txt
fi # 516
begin=`echo "(("$begin" + 1))" | bc -l`
echo 520
echo $begin
y=`echo "(("$y" + 1))" | bc -l`
echo 523
echo $y
#fi # 403 daemon :)
shift
done
echo line 528
cat /tmp/jwmrc-tray-tmp-* >> /tmp/jwmrc-tray-head.txt
cat /tmp/jwmrc-tray-head.txt
echo line 531
cat /tmp/jwmrc-tray-tail.txt
echo line 533
cat /tmp/jwmrc-tray-tail.txt >> /tmp/jwmrc-tray-head.txt
cat /tmp/jwmrc-tray-head.txt
mv /tmp/jwmrc-tray-head.txt /root/.jwmrc-tray
# fi # 403 syntax error near unexpected token done
Xdialog --title "MESSAGE BOX" \
        --msgbox "Moving complete.
        You must restart jwm for
        changes to take effect." 10 41

case $? in
  0)
    echo "OK";;
  255)
    echo "Box closed."
    exit 0
    ;;
esac



fi # 370

rm -f /tmp/jwmrc-tray*

exit 0


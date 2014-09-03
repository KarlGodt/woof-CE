#!/bin/sh

FSFND="`find /root/.mozilla -type f -name fullerscreen.jar`"

if [ "$FSFND" = "" ];then
 export MAIN_DIALOG="
<window title=\"FullerScreen slide presenter\" icon-name=\"gtk-execute\">
 <vbox>
  <text><label>Welcome! FullerScreen is a tool for creating and presenting lecture slides, similar to Powerpoint. FullerScreen is an \"addon\" to the SeaMonkey (and Firefox) web browser, and you view the slides in a SeaMonkey window.</label></text>
  <text><label>So, the \"slides\" are just HTML web pages, that you can create with any web page editor such as the WYSIWYG SeaMonkey Composer, or the Geany or Bluefish text editors for source code editing. The difference from normal web pages though is that you can insert special source code that FullerScreen recognises, that makes it behave as a Powerpoint-like slide presenter.</label></text>
 <text><label>\" \"</label></text>
 <text><label>Firstly though, FullerScreen has to be installed into SeaMonkey. Puppy does not come with it preinstalled as it is better to do it now when you have a running system -- nothing to download though, the install file is already present. After you click the INSTALL button you will be asked a few questions -- just choose the defaults.</label></text>
 <text><label>After FullerScreen has been installed, SeaMonkey will open with an example slide presentation. The demo will explain how you can create your own slide web pages. Click INSTALL now and have fun...</label></text>

 <hbox>
   <button>
    <label>INSTALL</label>
    <action type=\"exit\">installfullerscreen</action>
   </button>
   <button cancel></button>
 </hbox>
 </vbox>
</window>
"

 RETSTRING="`gtkdialog3 --program=MAIN_DIALOG --center`"
 [ $? -ne 0 ] && exit
 RETSTAT="`echo -n "$RETSTRING" | grep '^EXIT' | cut -f 2 -d '"'`" #'
 [ "$RETSTAT" != "installfullerscreen" ] && exit
 
 seamonkey file:///usr/local/fullerscreen/fullerscreen-2.3.3-mod.xpi &
 
fi

while [ ! -f /usr/lib/seamonkey/defaults/pref/fullerscreen.js ];do
 sleep 1
done
sleep 1

killall seamonkey


seamonkey file:///usr/local/fullerscreen/fullerscreen.html

###END###

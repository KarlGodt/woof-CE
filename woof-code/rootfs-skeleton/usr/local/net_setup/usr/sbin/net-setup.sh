#!/bin/sh
#(c) copyright Barry Kauler 2004 www.puppylinux.org
#Puppy ethernet network setup script.
#I got some bits of code from:
# trivial-net-setup, by Seth David Schoen <schoen@linuxcare.com> (c)2002
# and the little executables and, or, dotquad from the
# lnx-bbx Linux project. ipcalc app from Redhat 7.
# Thanks to GuestToo and other guys on the Puppy Forum for bug finding.
# Rarsa (Raul Suarez) reorganized the code and cleaned up the user interface
## Ported to gtkdialog3 and abused by Dougal, June 2007
## Update: July 4th (redesign main dialog, change "Load module" dialog)
## Update: July 10th (change INTERFACEBUTTONS format, add findInterfaceInfo function)
## Update: July 11th (move findLoadedModules into tryLoadModule)
## Update: July 12th (move "save" and "unload" buttons out of main dialog)
## Update: July 13th (add "sleep 3" after loading usb modules, fixed bug in findInterfaceInfo)
## Update: July 13th (fix problem with tree height)
## Update: July 19th (add recognition of prism2_usb interfaces as wireless)
## Update: August 1st (fix spelling...)

# v2.21 BK updated 12 Sept 2007, updated 13 Sept 2007.
# v3.91 BK 16 nov 2007, bugfix.
# v3.96 duid-related bugfixes by rerwin (see 'rerwin' in code below).
#v4.00 BK bugfix for ndiswrapper.
#v411 path hack /usr/local/net_setup
#v411 hack, msg to use BootManager to blacklist modules.

BIGGESTCNT=0 #v2.21 BK
echo -n "" > /tmp/net-setup-interface-info-tmp #v411

CURDIR="`pwd`"
APPDIR="`dirname "$0"`"
cd "${APPDIR}"
APPDIR="`pwd`"
cd "${CURDIR}"

# Check if output should go to the console
if [ "${1}" == "-d" ] ; then
    DEBUG_OUTPUT=/dev/stdout
else
    DEBUG_OUTPUT=/dev/null
fi

## Dougal: put this into a variable
BLANK_IMAGE=/usr/share/pixmaps/net-setup_btnsize.png

#=============================================================================
#============= FUNCTIONS USED IN THE SCRIPT ==============
#=============================================================================
. ${APPDIR}/ndiswrapperGUI.sh
. ${APPDIR}/wag-profiles.sh

showMainWindow()
{
    MAIN_RESPONSE=""

    while true
    do

        buildMainWindow
        I=$IFS; IFS="" #v2.21 BK window size...
        WINHEIGHT=450                                           #rerwin
        WINWIDTH=540
        EXTRAHEIGHT=`echo "$INTERFACE_INTERFACE" | wc -l`
        WINHEIGHT=`expr $EXTRAHEIGHT \* 10 + $WINHEIGHT`
        if [ $BIGGESTCNT -gt 40 ];then
         WIDTHEXTRA=`expr $BIGGESTCNT - 40`
         WIDTHEXTRA=`expr $WIDTHEXTRA \* 8`
         WINWIDTH=`expr $WINWIDTH + $WIDTHEXTRA`
        fi
        WINGEOM="${WINWIDTH}x${WINHEIGHT}"

        #BK: important gtkdialog v0.7.20 or later needed...
        for STATEMENTS in  $(gtkdialog3 --geometry=$WINGEOM --program Puppy_Network_Setup); do
            eval $STATEMENTS 2>/dev/null
        done
        IFS=$I
        unset Puppy_Network_Setup

#begin rerwin
        #Interpret client-option checkbox; allow duid only if supported.
        [ "$CHKBOXDUID" = "true" ] && [ -d /var/lib/dhcpcd -o ! -d /etc/dhcpc ] && touch /root/.dhcpcd.duid || rm /root/.dhcpcd.duid 2> /dev/null   #rerwin
        [ -d /etc/dhcpc -a ! -d /var/lib/dhcpcd ] && CHECKDUID="false" || CHECKDUID=$CHKBOXDUID  #Update check-state in case user returns to main dialog - but force uncheck if running older dhcpcd.
#end rerwin

        # Dougal: this is simpler than all the grep business.
        # Could integrate into main case-structure, but not sure about MAIN_RESPONSE
        case "$EXIT" in
          Interface_*) INTERFACE=${EXIT#Interface_} ; MAIN_RESPONSE=13 ;;
          *) MAIN_RESPONSE=${EXIT} ;;
        esac

        # Dougal: blank the "Done" button, in case we go to 13 and back
        DONEBUTTON=""

        case $MAIN_RESPONSE in
            10) showLoadModuleWindow ;;
            17) saveNewModule ;;
            18) unloadNewModule ;;
            19) break ;;
            13) showConfigureInterfaceWindow ${INTERFACE} ;;
            66) AutoloadUSBmodules ;;
            #21) showHelp  ;;
            abort) break ;;
        esac

    done

} # end of showMainWindow


#=============================================================================
refreshMainWindowInfo()
{
    # Dougal: comment out and move to the showLoadModuleWindow -- only used there...
    #findLoadedModules

  #we need to know what ethernet interfaces are there...
  INTERFACE_NUM=`ifconfig -a | grep -Fc 'Link encap:Ethernet'`
  INTERFACES="`ifconfig -a | grep -F 'Link encap:Ethernet' | cut -f1 -d' ' | tr '\n' ' '`"
  INTERFACEBUTTONS=""
  INTERFACE_DATA=""
  INTERFACE_INTERFACE="" #v2.21
  INTERFACE_INTTYPE="" #v2.21
  INTERFACE_FI_DRIVER="" #v2.21
  INTERFACE_BUS="" #v2.21
  INTERFACE_INFO="" #v2.21
  #rm -f /tmp/interface-modules

  echo -n "" > /tmp/net-setup-interface-info-tmp #v411

  for INTERFACE in ${INTERFACES}
  do
    [ "$INTERFACE" ] || continue
    # Dougal: use function for finding/setting info to be used in tree (below)
    findInterfaceInfo $INTERFACE

    ## Dougal: use a tree to display interface info
    INTERFACE_DATA="$INTERFACE_DATA <item>$INTERFACE|$INTTYPE|$FI_DRIVER|$TYPE: $INFO</item>"
    #v2.21 BK...
    INTERFACE_INTERFACE="${INTERFACE_INTERFACE}${INTERFACE}
"
    INTERFACE_INTTYPE="${INTERFACE_INTTYPE}${INTTYPE}
"
    INTERFACE_FI_DRIVER="${INTERFACE_FI_DRIVER}${FI_DRIVER}
"
    INTERFACE_BUS="${INTERFACE_BUS}${TYPE}
"
    INTERFACE_INFO="${INTERFACE_INFO}${INFO}
"
    # add to display list
    INTERFACEBUTTONS="
${INTERFACEBUTTONS}
<vbox>
    <pixmap><input file>$BLANK_IMAGE</input></pixmap>
    <button>
        <label>${INTERFACE}</label>
        <action>EXIT:Interface_${INTERFACE}</action>
    </button>
</vbox>"
  done

  if [ "$INTERFACE_DATA" ] ; then
    # Get the right height for the tree...
    case "$INTERFACE_NUM" in
     1) HEIGHT=65 ;;
     2) HEIGHT=100 ;;
     3) HEIGHT=125 ;;
     4) HEIGHT=150 ;;
     5) HEIGHT=175 ;;
     6) HEIGHT=200 ;;
    esac


#    <tree>
#       <label>Interface|Type|Module|Device description</label>
#       $INTERFACE_DATA
#       <height>$HEIGHT</height><width>350</width>
#       <variable>SELECTED_INTERFACE</variable>
#   </tree>

    INTERFACEDESCRS="
    <hbox spacing=\"10\">
      <text use-markup=\"true\"><label>\"<b>Interface</b>
$INTERFACE_INTERFACE\"</label></text>
      <text use-markup=\"true\"><label>\"<b>Type</b>
$INTERFACE_INTTYPE\"</label></text>
      <text use-markup=\"true\"><label>\"<b>Module</b>
$INTERFACE_FI_DRIVER\"</label></text>
      <text use-markup=\"true\"><label>\"<b>Bus</b>
$INTERFACE_BUS\"</label></text>
      <text use-markup=\"true\"><label>\"<b>Description</b>
$INTERFACE_INFO\"</label></text>
    </hbox>
"
    INTERFACEBUTTONS="
    <hbox>
        $INTERFACEBUTTONS
    </hbox>"
  fi

  if [ $INTERFACE_NUM -eq 0 ];then
    echo "Puppy cannot see any active network interfaces.

If you have one or more network adaptors (interfaces) in the PC and you want to use them, then driver modules will have to be loaded. This is supposed to be autodetected and the correct driver loaded when Puppy boots up, but it hasn't happened in this case. Never mind, you can do it manually!" > /tmp/net-setup_MSGINTERFACES.txt

  fi
  if [ $INTERFACE_NUM -eq 1 ];then
    echo "Puppy has identified the following network interface on your computer, but it still needs to be configured.
To test or configure it, click on its button."  > /tmp/net-setup_MSGINTERFACES.txt
  fi
  if [ $INTERFACE_NUM -gt 1 ];then
    echo "Puppy has identified the following network interfaces on your computer, but they still need to be configured.
To test or configure an interface, click on its button."  > /tmp/net-setup_MSGINTERFACES.txt
  fi

    #echo "Puppy has done a quick check to see which network driver modules are currently loaded. Here they are (the relevant interface is in brackets):
 #${LOADEDETH}" > /tmp/net-setup_MSGMODULES.txt

#Rerwin: Initialize Client-identification option.
[ -f /root/.dhcpcd.duid ] && CHECKDUID="true" || CHECKDUID="false"   #rerwin

} # end refreshMainWindowInfo

#=============================================================================
buildMainWindow()
{
    echo "${TOPMSG}" > /tmp/net-setup_TOPMSG.txt


    export Puppy_Network_Setup="<window title=\"Puppy Network Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>

    <text><label>\"
`cat /tmp/net-setup_TOPMSG.txt`
\"</label></text>

    <frame  Interfaces >
        <vbox>
            <text>
                <label>\"`cat /tmp/net-setup_MSGINTERFACES.txt`\"</label>
            </text>
            ${INTERFACEDESCRS}
            ${INTERFACEBUTTONS}
            <checkbox>
             <label>Identify all interfaces to the network as representing the same computer.</label>
             <variable>CHKBOXDUID</variable>
             <default>$CHECKDUID</default>
            </checkbox>
        </vbox>
    </frame>

    <frame  Network modules >
      ${USB_MODULE_BUTTON}
      ${MODULEBUTTONS}
    </frame>
    <hbox>
        <button help>
            <action>man 'net_setup' &> /dev/null & </action>
        </button>
        <button>
             <label>Exit</label>
             <input file icon=\"gtk-quit\"></input>
             <action>EXIT:19</action>
        </button>
    </hbox>
</vbox>
</window>"
}                               #rerwin - inserted checkbox

#=============================================================================
showLoadModuleWindow()
{
    findLoadedModules
    echo -n "" > /tmp/ethmoduleyesload.txt
    MODULELIST=`cat /etc/networkmodules | sort | tr "\n" " "`
    # Dougal: create list of modules (pipe delimited)
sort /etc/networkmodules | tr '"' '|' | tr ':' '|' | sed 's%|$%%g' | tr -s ' ' >/tmp/module-list

#v411 BK msg for ndiswrapper...
NDISWRAPPERWARNING=""
EXISTWI="`grep '^Wireless ' /tmp/net-setup-interface-info-tmp | grep -v 'ndiswrapper'`"
if [ "$EXISTWI" != "" ];then
 NDISWRAPPERWARNING="
<b>NDISWRAPPER WARNING</b>
A wireless driver (module) is already loaded:
 ${EXISTWI}
...the driver is the fourth entry.
It is best if you hit the 'Cancel' button now, quit the Wizard, and run the BootManager (see System menu), then blacklist the module, then reboot. Then you will not have the potentially-conflicting driver. If you find that Ndiswrapper does not do the trick for you, you can always run BootManager again and restore the original driver."
fi

 export LOAD_MODULE_DIALOG="<window title=\"Load a network module\" icon-name=\"gtk-execute\" window-position=\"1\">
<vbox>
 <notebook labels=\"Select module|More\">
 <vbox>
  <pixmap><input file>$BLANK_IMAGE</input></pixmap>
  <hbox>
   <text><label>\"If you see a module below that matches your hardware (and isn't loaded yet...), select it and press the 'Load' button.
If not (or you are unsure, or want to use Ndiswrapper to load a Windows driver), go to the 'More' tab.\"</label></text>
   <text><label>\"     \"</label></text>
   <vbox>
    <pixmap><input file>$BLANK_IMAGE</input></pixmap>
    <button>
     <label>Load</label>
     <input file stock=\"gtk-apply\"></input>
     <action>EXIT:load</action>
    </button>
   </vbox>
  </hbox>
  <pixmap><input file>$BLANK_IMAGE</input></pixmap>
  <tree>
    <label>Module|Bus|Description</label>
    <input>cat /tmp/module-list</input>
    <height>200</height><width>550</width>
    <variable>NEW_MODULE</variable>
  </tree>

 </vbox>
 <vbox>
 <text><label>\"     \"</label></text>
 <hbox>
  <text use-markup=\"true\">
   <label>\"Click <b>Specify</b> to choose a module that's not listed, or specify a module followed by parameters (might be mandatory for ISA cards, see examples below).
Click <b>Ndiswrapper</b> to use a Windows driver.
Click <b>Auto-probe</b> to try loading ALL the modules in the list.

Example1: ne io=0x000,
Example2: arlan  io=0x300 irq=11
(Example1 works for most ISA cards and does some autoprobing of io and irq)
${NDISWRAPPERWARNING}\"</label>
  </text>
  <text>
   <label>\"     \"</label>
  </text>
  <vbox>
   <text>
    <label>\"     \"</label>
   </text>
   <button>
    <label>Specify</label>
    <input file icon=\"gtk-index\"></input>
    <action>EXIT:specify</action>
   </button>
   <button>
    <label>Ndiswrapper</label>
    <input file icon=\"gtk-execute\"></input>
    <action>EXIT:ndiswrapper</action>
   </button>
   <button>
    <label>Auto-probe</label>
    <input file icon=\"gtk-refresh\"></input>
    <action>EXIT:auto</action>
   </button>
  </vbox>
  </hbox>
  </vbox>

  </notebook>
  <hbox>
   <button cancel></button>
  </hbox>
 </vbox>
</window>"

  I=$IFS; IFS=""
  for STATEMENTS in  $(gtkdialog3 --program LOAD_MODULE_DIALOG); do
    eval $STATEMENTS 2>/dev/null
  done
  IFS=$I
  unset LOAD_MODULE_DIALOG

  case "$EXIT" in
    auto)   autoLoadModule ;;
    ndiswrapper)    loadNdiswrapperModule ;;
    specify)    loadSpecificModule ;;
    load)   if [ "$NEW_MODULE" ] ; then
              tryLoadModule ${NEW_MODULE}
            else
              TOPMSG="REPORT ON LOADING OF MODULE: No module was selected"
            fi ;;
    cancel) TOPMSG="REPORT ON LOADING OF MODULE: No module was loaded"  ;;
  esac

  NEWLOADED="`cat /tmp/ethmoduleyesload.txt`"
  NEWLOADf1=${NEWLOADED%% *} #remove any extra params.
  if [ "${NEWLOADED}" ];then
    ##### add new code here: find new interface, then give window naming it
    ##### and offering to save/unload
    ##### ONLY AFTER that refresh main window
    NEW_NUM=`ifconfig -a | grep -Fc "Link encap:Ethernet"`
    NEW_INTERFACES=""
    NEW_DATA=""
    NEW_INTERFACES_FRAME=""
    if [ $NEW_NUM -gt $INTERFACE_NUM ] ; then # got a new interface
      let DIFF=NEW_NUM-INTERFACE_NUM

      for ANEW in `ifconfig -a | grep -F 'Link encap:Ethernet' |cut -f1 -d' '`
      do
        case "$INTERFACES" in *$ANEW*) continue ;; esac
        # If we got here, it's a new one
        NEW_INTERFACES="$NEW_INTERFACES $ANEW"
      done

      echo -n "" > /tmp/net-setup-interface-info-tmp #v411

      for ANEW in $NEW_INTERFACES
      do
        # get info for it
        findInterfaceInfo $ANEW
        # add to code for new interface dialog
        NEW_DATA="$NEW_DATA <item>$ANEW|$INTTYPE|$FI_DRIVER|$TYPE: $INFO</item>"
      done
      # Set message telling about new interfaces
      if [ $DIFF -eq 1 ] ; then
        NEW_MESSAGE="The following new interface has been found"
      else
        NEW_MESSAGE="The following new interfaces have been found"
      fi
      # create the frame with the new interfaces
      case "$DIFF" in
       1) HEIGHT=65 ;;
       2) HEIGHT=100 ;;
       3) HEIGHT=125 ;;
       4) HEIGHT=150 ;;
       5) HEIGHT=175 ;;
       6) HEIGHT=200 ;;
      esac
      NEW_INTERFACES_CODE="
  <frame  New interfaces >
    <text><label>$NEW_MESSAGE</label></text>
    <tree>
        <label>Interface|Type|Module|Device description</label>
        $NEW_DATA
        <height>$HEIGHT</height><width>400</width>
        <variable>SELECTED_INTERFACE</variable>
    </tree>
  </frame>

    <text>
      <label>\"Click the 'Save' button to save the selection, so that Puppy will automatically load $NEWLOADf1 at bootup.
Click Cancel to just go back and configure the new interface.\"</label>
    </text>
    <hbox>

      <button>
        <label>Save</label>
        <input file icon=\"gtk-save\"></input>
        <action>EXIT:save</action>
      </button>

  "

    else
      NEW_INTERFACES_CODE="
  <text><label>No new interfaces were detected.</label></text>
  <text><label>\" \"</label></text>

    <text>
      <label>\"Click the 'Unload' button to unload the new module and try to load another one.\"</label>
    </text>
    <hbox>
      <button>
        <label>Unload</label>
        <input file stock=\"gtk-undo\"></input>
        <action>EXIT:unload</action>
      </button>
    "
    fi #if [ $NEW_NUM -gt $INTERFACE_NUM ]
    # give dialog with two buttons and appropriate message
    export NEW_MODULE_DIALOG="<window title=\"New module loaded\" icon-name=\"gtk-execute\" window-position=\"1\">
<vbox>
  <pixmap><input file>$BLANK_IMAGE</input></pixmap>
  <text><label>The following new module has been loaded: $NEWLOADf1</label></text>
  <pixmap><input file>$BLANK_IMAGE</input></pixmap>
  $NEW_INTERFACES_CODE

   <button cancel></button>
  </hbox>
</vbox>
</window>"

    # Run new dialog
    I=$IFS; IFS=""
    for STATEMENTS in  $(gtkdialog3 --program NEW_MODULE_DIALOG); do
      eval $STATEMENTS 2>/dev/null
    done
    IFS=$I
    unset NEW_MODULE_DIALOG

    # Do what we're asked
    case "$EXIT" in
     save)
       saveNewModule
       TOPMSG="New module information saved"
       ;;
     unload)
       unloadNewModule
       TOPMSG="New module unloaded"
       ;;
     *) TOPMSG="Cancelled"
       ;;
    esac

    # refresh main
    refreshMainWindowInfo
    # set new message for main dialog
    #TOPMSG="REPORT ON LOADING OF MODULE: Module '$NEWLOADf1' successfully loaded"

    else
      BGCOLOR="#ffc0c0"
      TOPMSG="REPORT ON LOADING OF MODULE: No module was loaded"
    fi
} # end of showLoadModuleWindow

#=============================================================================
tryLoadModule()
{
    MODULE_NAME="$1"
    if grep -q "$MODULE_NAME" /tmp/loadedeth.txt ; then
        Xdialog --screen-center --title "Puppy Network Wizard: hardware" \
                --msgbox "The driver is already loaded.\nThat does not mean it will actually work though!\nAfter clicking OK, see if a new interface\nhas been detected." 0 0
        echo -n "${MODULE_NAME}" > /tmp/ethmoduleyesload.txt
        return 0
    else
        if modprobe ${MODULE_NAME}
        then
            echo -n "${MODULE_NAME}" > /tmp/ethmoduleyesload.txt
            case "$NETWORK_MODULES" in *" $MODULE_NAME "*) ;;
             *) echo "${MODULE_NAME}" >> /etc/networkusermodules ;;
            esac
            Xdialog --left --wrap --stdout --title "Puppy Network Wizard: hardware" --msgbox "Module ${MODULE_NAME} has loaded successfully.\nThat does not mean it will actually work though!\nAfter clicking OK, see if a new interface\nhas been detected." 0 0
            return 0
        else
            Xdialog --stdout --msgbox "Loading ${MODULE_NAME} failed; try a different driver." 0 0
            return 1
        fi
    fi
} # end tryLoadModule

#=============================================================================
loadNdiswrapperModule()
{
    showNdiswrapperGUI
    if [ $? -eq 0 ] ; then
        ndiswrapper -m

        #v4.00 bugfix...
        NATIVEMOD=""
        nwINTERFACE="`grep '^alias .* ndiswrapper$' /etc/modprobe.conf | cut -f 2 -d ' '`" #most likely 'wlan0'
        #if this interface is already claimed by a native linux driver,
        #then get rid of it...
        if [ -e /sys/class/net/$nwINTERFACE -a "$nwINTERFACE" != "" ];then
         NATIVEMOD="`readlink /sys/class/net/${nwINTERFACE}/device/driver/module`"
         NATIVEMOD="`basename $NATIVEMOD`"
         if [ "$NATIVEMOD" != "ndiswrapper" ];then
          #note 'ndiswrapper -l' also returns the native linux module.
          nwiPATTERN='^'"$nwINTERFACE"' '
          if [ "`iwconfig | grep "$nwiPATTERN" | grep 'IEEE' | grep 'ESSID'`" != "" ];then
           rmmod $NATIVEMOD
           sleep 6
           [ $INTERFACE_NUM -ge 0 ] && INTERFACE_NUM=`expr $INTERFACE_NUM - 1`
           #...needed later to determine that number of interfaces has changed with ndiswrapper.
           INTERFACES="`ifconfig -a | grep -F 'Link encap:Ethernet' | cut -f1 -d' ' | tr '\n' ' '`"
           #...also needed later.
          fi
         else
          NATIVEMOD=""
         fi
        fi

        tryLoadModule "ndiswrapper"
        ndRETVAL=$?

        #v4.00...
        if [ $ndRETVAL -eq 0 ];then
         #well let's be radical, blacklist the native driver...
         if [ "$NATIVEMOD" != "" ];then
          skmPATTERN='^SKIPLIST.* '"$NATIVEMOD"' '
          if [ "`grep "$skmPATTERN" /etc/rc.d/MODULESCONFIG`" = "" ];then
           skipPATTERN="s/^SKIPLIST=\"/SKIPLIST=\" ${NATIVEMOD} /"
           sed "$skipPATTERN" /etc/rc.d/MODULESCONFIG > /tmp/MODULESCONFIG
           cp -f /tmp/MODULESCONFIG /etc/rc.d/MODULESCONFIG
           . /etc/rc.d/MODULESCONFIG
           Xdialog --title "Network Wizard" --msgbox "WARNING: the ${NATIVEMOD} module has been added to the SKIPLIST variable\nin /etc/rc.d/MODULESCONFIG as it conflicts with ndiswrapper. This will\nprevent the module from loading at bootup. However, if you decide that\nyou do not want to use ndiswrapper, open MODULESCONFIG in a text editor\nand remove the string ' ${NATIVEMOD} ' in the SKIPLIST variable." 0 0
          fi
         fi
        fi

        return $ndRETVAL
    fi
} # end loadNdiswrapperModule

#=============================================================================
loadSpecificModule()
{
    RESPONSE=$(Xdialog --stdout --title "Puppy Network Wizard: hardware" --inputbox "Please type the name of a specific module to load\n(extra parameters allowed, but don't type tab chars)." 0 0 "" 2> /dev/null)
    if [ $? -eq 0 ];then
        tryLoadModule "${RESPONSE}"
    fi
} # end loadSpecificModule

#=============================================================================
autoLoadModule()
{
    #this is the autoloading...
    SOMETHINGWORKED=false
    #clear
    for CANDIDATE in $NETWORK_MODULES
    do

        #if have pcmcia, do not try loading the others...
        MDOIT="no"
        case "$CANDIDATE" in
         *_cs*) [ "$MPCMCIA" = "yes" ] && MDOIT="yes" ;;
         *)     [ "$MPCMCIA" = "yes" ] || MDOIT="yes" ;;
        esac

        #also, do not try if it is already loaded...?
        grep -q "$CANDIDATE" /tmp/loadedeth.txt && MDOIT="no"

        #in case of false-hits, ignore anything already tried this session...
        grep -q "$CANDIDATE" /tmp/logethtries.txt && MDOIT="no"

        if [ "$MDOIT" = "yes" ];then
            echo; echo "*** Trying $CANDIDATE."
            if modprobe $CANDIDATE
            then
                SOMETHINGWORKED=true
                WHATWORKED=$CANDIDATE
                #add it to the log for this session...
                echo "$CANDIDATE" >> /tmp/logethtries.txt
                break
            fi
        fi

    done
    sleep 2
    if $SOMETHINGWORKED
    then
        Xdialog --left --wrap --msgbox "Success loading the $WHATWORKED module. That does not mean it will actually work though!\nAfter clicking OK, back on the main window if you see a new active interface\nproceed to configure it.\n\nNOTE: it is possible that a module loads ok, but it is a false hit, that is, does\nnot actually work with your network adaptor. In that case, try autoprobing again. This\nscript will remember the previous attempts (until you exit this script) and will\njump over them.\nIf you do get false hits, let us know about it on the Puppy Discussion Forum!" 0 0
        echo -n "$WHATWORKED" > /tmp/ethmoduleyesload.txt
    else
        MALREADY="`cat /tmp/loadedeth.txt`"
        Xdialog --msgbox "No module loaded successfully.\n\nNote however that these modules are already loaded:\n${MALREADY}" 0 0
        return 1
    fi
} # end autoLoadModule

#=============================================================================
findLoadedModules()
{
  echo -n " " > /tmp/loadedeth.txt

    LOADED_MODULES="$(lsmod | cut -f1 -d' ' | sort)"
    NETWORK_MODULES=" $(cat /etc/networkmodules /etc/networkusermodules  2> ${DEBUG_OUTPUT} | cut -f1 -d' ' | tr '\n' ' ') "

  COUNT_MOD=0
  for MOD in $LOADED_MODULES
  do    let COUNT_MOD=COUNT_MOD+1
  done

  (
        for AMOD in $LOADED_MODULES
        do
            echo "X"
            # Dougal: use a case structure for globbing
            # Also try and retain original module names (removed "tr '-' '_')
            case "$NETWORK_MODULES" in
             *" $AMOD "*)
               echo "$AMOD" >> /tmp/loadedeth.txt
               echo -n " " >> /tmp/loadedeth.txt #space separation
               ;;
             *" ${AMOD/_/-} "*) # kernel shows module with underscore...
              echo "${AMOD/_/-}" >> /tmp/loadedeth.txt
              echo -n " " >> /tmp/loadedeth.txt #space separation
              ;;
            esac
        done
  ) | Xdialog --title "Puppy Network Wizard" --progress "Checking loaded modules" 0 0 $COUNT_MOD

} # end of findLoadedModules

#=============================================================================
testInterface()
{
  INTERFACE=$1

    (
        UNPLUGGED="false"
        ifconfig $INTERFACE | grep " UP " &> ${DEBUG_OUTPUT}
        if [ ! $? -eq 0 ];then #=0 if found
            ifconfig $INTERFACE up
        fi
        #BK1.0.7 improved link-beat detection...
        echo "X"
        if ! ifplugstatus ${INTERFACE} | grep -F -q 'link beat detected' ;then
          sleep 2
          echo "X"
          if ! ifplugstatus-0.25 ${INTERFACE} | grep -F -q 'link beat detected' ;then
            sleep 2
            echo "X"
            if ! ifplugstatus ${INTERFACE} | grep -F -q 'link beat detected' ;then
              sleep 2
              echo "X"
              if ! ifplugstatus-0.25 ${INTERFACE} | grep -F -q 'link beat detected' ;then
                UNPLUGGED="true"
              fi
            fi
          fi
        fi
        echo "${UNPLUGGED}" > /tmp/net-setup_UNPLUGGED.txt
  ) | Xdialog --title "Puppy Network Wizard" --progress "Testing Interface ${INTERFACE}" 0 0 4

  UNPLUGGED=$(cat /tmp/net-setup_UNPLUGGED.txt)

  if [ "$UNPLUGGED" != "false" ];then #BK1.0.7
    #no cable plugged in, no network connection possible...
    ifconfig $INTERFACE down
    BGCOLOR="#ffc0c0"
    if [ "${IS_WIRELESS}" ] ; then
      TOPMSG="REPORT ON TEST OF $INTERFACE CONNECTION:
'Unable to connect to a wireless network'

Verify that the wireless network is available and
that you have provided the correct wireless parameters."
    else
      TOPMSG="REPORT ON TEST OF $INTERFACE CONNECTION:
'Unable to connect to the network'

Verify that the network is available and
that the ethernet cable is plugged in."
    RETTEST=1
    fi
  else
    BGCOLOR="#e0ffe0"
    TOPMSG="REPORT ON TEST OF $INTERFACE CONNECTION:
'Puppy was able to find a live network'

You can proceed to acquire an IP address."
        RETTEST=0
  fi

  return ${RETTEST}
} # end of testInterface

#=============================================================================
showConfigureInterfaceWindow()
{
  INTERFACE=$1

  initializeConfigureInterfaceWindow

  RETVALUE=""
  # 1=Close window 19=Back Button 22=Save configuration
  while true
  do

    buildConfigureInterfaceWindow

    I=$IFS; IFS=""
    for STATEMENTS in  $(gtkdialog3 --program Puppy_Network_Setup); do
      eval $STATEMENTS
    done
    IFS=$I
    unset Puppy_Network_Setup

    RETVALUE=${EXIT}
    [ "${RETVALUE}" = "abort" ] && RETVALUE=1

    RETSETUP=99
    case $RETVALUE in
       1 | 19) # close window
        #v2.21 BK...
        LASTTOPMSGA="NETWORK CONFIGURATION OF $INTERFACE SUCCESSFUL"
        LASTTOPMSGB="The configuration has been saved to file"
        if [ "`echo "$TOPMSG" | grep "$LASTTOPMSGB"`" = "" ];then
         TOPMSG="NETWORK CONFIGURATION OF $INTERFACE CANCELED!"
        else
         TOPMSG="NETWORK CONFIGURATION OF $INTERFACE COMPLETED"
        fi

          break
          ;;
      66) # Dougal: add "Done" button to exit (there was a wrong message)
          exit
          ;;
      10) # AutoDHCP
          setupDHCP
          RETSETUP=$?
          ;;
      11) # StaticIP
          showStaticIPWindow
          RETSETUP=$?
          ;;
      13) # Test
          testInterface ${INTERFACE}
          RETSETUP=$?
          ;;
      14) # Wireless
          configureWireless ${INTERFACE}
          ;;
      #21) # Help
          #showHelp
          #;;
      22) # Save configuration
          break
          ;;
    esac

    # Dougal: define the "Done" button here, so it doesn't appear the first time around...
    DONEBUTTON="<button>
                    <label>Done</label>
                    <input file stock=\"gtk-apply\"></input>
                    <action>EXIT:66</action>
                </button>"

    if [ $RETVALUE -eq 10 ] || [ $RETVALUE -eq 11 ] ; then
      if [ $RETSETUP -ne 0 ] ; then
        TOPMSG="NETWORK CONFIGURATION OF $INTERFACE UNSUCCESSFUL!
Try again, click 'Back' to try a different interface or click 'Done' to give up for now."
      else
        RETVALUE=1
        Xdialog --yesno "NETWORK CONFIGURATION OF $INTERFACE SUCCESSFUL!

Do you want to save this configuration?

If you want to keep this configuration for next boot: click 'Yes'.
If you just want to use this configuration for this session: click 'No'." 0 0
        if [ $? -eq 0 ] ; then
          saveInterfaceSetup ${INTERFACE}
          TOPMSG="NETWORK CONFIGURATION OF $INTERFACE SUCCESSFUL!
The configuration has been saved to file /etc/${INTERFACE}mode.
This file is read at bootup by /usr/local/net_setup/etc/rc.d/rc.network

If there are no more interfaces to setup and configure, just click 'Done' to get out."
        else
          TOPMSG="NETWORK CONFIGURATION OF $INTERFACE SUCCESSFUL!
The configuration was not saved for next boot.

If there are no more interfaces to setup and configure, just click 'Done' to get out."
        fi
      fi
    fi

  done

} # end showConfigureInterfaceWindow

#=============================================================================
buildConfigureInterfaceWindow()
{
    export Puppy_Network_Setup="<window title=\"Configure network interface ${INTERFACE}\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
    <pixmap><input file>$BLANK_IMAGE</input></pixmap>
    <text><label>\"${TOPMSG}\"</label></text>
    ${WIRELESSSECTION}
    <frame  Test interface >
        <hbox>
            <text><label>\"${TESTMSG}\"</label></text>
            <vbox>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                <button>
                    <label>Test ${INTERFACE}</label>
                    <action>EXIT:13</action>
                </button>
            </vbox>
        </hbox>
    </frame>
    <frame  Configure interface >
        <hbox>
            <text><label>\"${DHCPMSG}\"</label></text>
            <vbox>
                <text><label>\" \"</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                <button>
                    <label>Auto DHCP</label>
                    <action>EXIT:10</action>
                </button>
            </vbox>
        </hbox>
        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        <hbox>
            <text><label>\"${STATICMSG}\"</label></text>
            <vbox>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                <button>
                    <label>Static IP</label>
                    <action>EXIT:11</action>
                </button>
            </vbox>
        </hbox>
    </frame>
    <hbox>
        $DONEBUTTON
        <button help>
            <action>man 'net_setup' &> /dev/null & </action>
        </button>
        ${SAVE_SETUP_BUTTON}
        <button>
            <label>Back</label>
            <input file stock=\"gtk-go-back\"></input>
            <action>EXIT:19</action>
        </button>
    </hbox>
</vbox>
</window>"
}

#=============================================================================
initializeConfigureInterfaceWindow()
{
    TOPMSG="OK, let's try to configure ${INTERFACE}."

    TESTMSG="You should make sure that ${INTERFACE} is connected to a 'live' network.
After you confirm that, you can configure the interface."

    DHCPMSG="The easiest way to configure the network is by using a DHCP server (usually provided by your network). This will enable Puppy to query the server at bootup and automatically be assigned an IP address. The 'dhcpcd' client daemon program is launched and network access happens automatically."

    STATICMSG="If a DHCP server is not available, you will have to do everything manually by setting a static IP, but this script will make it easy."

    checkIfIsWireless ${INTERFACE}

    if [ "$IS_WIRELESS" ] ; then
        WIRELESSSECTION="<frame  Configure wireless network >
<hbox>
    <text><label>\"Puppy found that ${INTERFACE} is a wireless interface.
To connect to a wireless network, you must first set the wireless network parameters by clicking on the 'Wireless' button, then assign an IP address to it, either with DHCP or Static IP (see below).\"</label></text>
    <vbox>
        <text><label>\" \"</label></text>
        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        <button>
            <label>Wireless</label>
            <action>EXIT:14</action>
        </button>
    </vbox>
</hbox>
</frame>"
    else
        WIRELESSSECTION=""
    fi
    SAVE_SETUP_BUTTON=""
}

#=============================================================================
checkIfIsWireless()
{
  INTERFACE=$1
  IS_WIRELESS=""
  INTMODULE=`readlink /sys/class/net/$INTERFACE/device/driver`
  INTMODULE=${INTMODULE##*/}

  if grep -q "${INTERFACE}" /proc/net/wireless || [ "$INTMODULE" = "prism2_usb" ] ; then
    IS_WIRELESS="true"
  fi
}

#=============================================================================
configureWireless()
{
    INTERFACE=$1
    showProfilesWindow ${INTERFACE}
    if [ $? -eq 0 ] ; then
        testInterface ${INTERFACE}
    else
        TOPMSG="WIRELESS CONFIGURATION OF $INTERFACE CANCELED!
To connect to a wireless network you have to select a profile to use'. "
    fi
}

#=============================================================================
setupDHCP()
{
    {
        # Must kill old dhcpcd first
        dhcpcd -k "$INTERFACE"
        #v3.91 later pkgs use /var by default...
        if [ -d /etc/dhcpc ];then
         rm /etc/dhcpc/dhcpcd-${INTERFACE}.* &>/dev/null #if left over from last session, causes trouble.
        else
#begin rerwin - Retain duid, if any, so all interfaces can use it (per ipv6) or delete it if using MAC address as client ID.    rerwin
         rm -f /var/lib/dhcpcd/dhcpcd-${INTERFACE}.* 2>/dev/null  #.info
#end rerwin
         rm -f /var/run/dhcpcd-${INTERFACE}.* 2>/dev/null #.pid
        fi
        sleep 5

#begin rerwin - select type of client ID and set up for common duid for pup-save or within partition.
        if [ -f /root/.dhcpcd.duid ];then  #Use default if indicated, or MAC address, as client ID
         if [ -s /mnt/home/.common.duid -o -s /root/.dhcpcd.duid ];then  #a partition-common duid exists.
          [ ! -d /var/lib/dhcpcd ] && mkdir /var/lib/dhcpcd
          [ -s /mnt/home/.common.duid ] && cp /mnt/home/.common.duid /var/lib/dhcpcd/dhcpcd.duid || cp /root/.dhcpcd.duid /var/lib/dhcpcd/dhcpcd.duid  #use partition-common duid.
         #else let dhcpcd use previously acquired duid or create new one
         fi
         dhcpcd -d $INTERFACE
        else
         rm -f /var/lib/dhcpcd/dhcpcd.duid 2>/dev/null  #.duid
         [ -d /etc/dhcpc ] && dhcpcd -d $INTERFACE || dhcpcd -d -I '' $INTERFACE   #Use option safe for older dhcpcd, if might be present
        fi
        if [ $? -eq 0 ] ; then
#end rerwin
            HAS_ERROR=0
#begin rerwin - Save copy of duid, if any, for use during reboot and as partition-common duid.
            cp /var/lib/dhcpcd/dhcpcd.duid /root/.dhcpcd.duid 2>/dev/null
            [ -d /mnt/home -a ! -s /mnt/home/.common.duid ] && cp /var/lib/dhcpcd/dhcpcd.duid /mnt/home/.common.duid 2>/dev/null
#end rerwin
        else
            HAS_ERROR=1
        fi
        echo "${HAS_ERROR}" > /tmp/net-setup_HAS_ERROR.txt
        echo "XXXX"
    } | Xdialog --no-buttons --title "Puppy Network Wizard: DHCP" --infobox "There may be a delay of up to 60 seconds while Puppy waits for the
DHCP server to respond. Please wait patiently..." 0 0 0

  HAS_ERROR=$(cat /tmp/net-setup_HAS_ERROR.txt)

  if [ ${HAS_ERROR} -eq 0 ]
  then
    MODECOMMANDS="
echo \"Trying to get IP address from DHCP server (60sec timeout)...\"
echo \"Trying to get IP address from DHCP server (60sec timeout)...\" > /dev/console
rm /etc/dhcpc/dhcpcd-${INTERFACE}.pid 2>/dev/null #if left over from last session, causes trouble.
rm /etc/dhcpc/dhcpcd-${INTERFACE}.cache 2>/dev/null #ditto
rm /etc/dhcpc/dhcpcd-${INTERFACE}.info 2>/dev/null #ditto
if [ ! -f /root/.dhcpcd.duid ];then
 [ -d /etc/dhcpc ] && dhcpcd $INTERFACE || dhcpcd -I '' $INTERFACE
else
 #[ ! -d /var/lib/dhcpcd ] && mkdir /var/lib/dhcpcd
 #[ -s /root/.dhcpcd.duid ] && cp /root/.dhcpcd.duid /var/lib/dhcpcd/dhcpcd.duid
 dhcpcd $INTERFACE
fi"   #Use default if indicated, or MAC address, as client ID.  #rerwin
  else
    MODECOMMANDS=""
  fi

    return ${HAS_ERROR}
} #end of setupDHCP

#=============================================================================
showStaticIPWindow()
{
    IP_ADDRESS="`ifconfig ${INTERFACE} | grep 'inet addr' | sed 's/.*inet addr://' | cut -d" " -f1`"
    NETMASK="`ifconfig ${INTERFACE} | grep 'inet addr' | sed 's/.*Mask://'`"
    GATEWAY="`iproute | grep default | cut -d" " -f3`"
    DNS_SERVER1="`grep nameserver /etc/resolv.conf | head -n1 | cut -d" " -f2`"
    DNS_SERVER2="`grep nameserver /etc/resolv.conf | tail -n1 | cut -d" " -f2`"

    EXIT=""
    while true
    do

        buildStaticIPWindow
        I=$IFS; IFS=""
        for STATEMENTS in  $(gtkdialog3 --program Puppy_Network_Setup); do
            eval $STATEMENTS
        done
        IFS=$I
        unset Puppy_Network_Setup

        case "$EXIT" in
            abort|Cancel) # close window
                break
                ;; # Do Nothing, It will exit without doing anything
            #"21" ) # Help
                #showHelp
                #;;
            "OK" ) # OK
                validateStaticIP
                if [ $? -eq 0 ] ; then
                    setupStaticIP
                    [ $? -ne 0 ] && EXIT=""
                else
                    EXIT=""
                fi
                break
                ;;
        esac
    done

    if [ "${EXIT}" = "OK" ] ; then
        return 0
    else
        return 1
    fi
}

#=============================================================================
buildStaticIPWindow()
{
    [ -z "$IP_ADDRESS" ]  && IP_ADDRESS="0.0.0.0"
    [ -z "$NETMASK" ]     && NETMASK="255.255.255.0"
    [ -z "$GATEWAY" ]     && GATEWAY="0.0.0.0"
    [ -z "$DNS_SERVER1" ] && DNS_SERVER1="0.0.0.0"
    [ -z "$DNS_SERVER2" ] && DNS_SERVER2="0.0.0.0"

    export Puppy_Network_Setup="<window title=\"Set Static IP\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
    <text><label>\"Enter your static IP parameters:
- If you are using a router check your router's
status page to get these values.
- If you connect directly to your modem you will
need to get these values from your ISP.

Please enter all addresses in dotted-quad decimal
format (xxx.xxx.xxx.xxx). other formats will
not be recognized.
\"</label></text>
    <frame  Static IP parameters >
        <hbox>
            <vbox>
                <text><label>IP address:</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            </vbox>
            <entry>
                <variable>IP_ADDRESS</variable>
                <default>${IP_ADDRESS}</default>
            </entry>
        </hbox>
        <hbox>
            <vbox>
                <text><label>Net Mask:</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            </vbox>
            <entry>
                <variable>NETMASK</variable>
                <default>${NETMASK}</default>
            </entry>
        </hbox>
        <hbox>
            <vbox>
                <text><label>Gateway:</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            </vbox>
            <entry>
                <variable>GATEWAY</variable>
                <default>${GATEWAY}</default>
            </entry>
        </hbox>
    </frame>
    <frame  DNS parameters >
        <hbox>
            <vbox>
                <text><label>Primary:</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            </vbox>
            <entry>
                <variable>DNS_SERVER1</variable>
                <default>${DNS_SERVER1}</default>
            </entry>
        </hbox>
        <hbox>
            <vbox>
                <text><label>Secondary:</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            </vbox>
            <entry>
                <variable>DNS_SERVER2</variable>
                <default>${DNS_SERVER2}</default>
            </entry>
        </hbox>
    </frame>
    <hbox>
        <button help>
            <action>man 'net_setup' &> /dev/null & </action>
        </button>
        <button ok></button>
        <button cancel></button>
    </hbox>
</vbox>
</window>"
}

#=============================================================================
validateStaticIP()
{
    ERROR_MSG=""
    if ! validip "${IP_ADDRESS}" ; then
        ERROR_MSG="${ERROR_MSG}\n- Invalid IP Address"
    fi
    if ! validip "${NETMASK}" ; then
        ERROR_MSG="${ERROR_MSG}\n- Invalid Netmask"
    fi
    if [ ! -z "$GATEWAY" ] ; then
        if ! validip "${GATEWAY}"  ; then
            ERROR_MSG="${ERROR_MSG}\n- Invalid Gateway address"
        fi
    fi
    if ! validip "${DNS_SERVER1}"  ; then
        ERROR_MSG="${ERROR_MSG}\n- Invalid DNS server 1 address"
    fi
    if ! validip "${DNS_SERVER2}"  ; then
        ERROR_MSG="${ERROR_MSG}\n- Invalid DNS server 2 address"
    fi

    if [ "x${ERROR_MSG}" != "x" ] ; then
      Xdialog --left --title "Puppy Network Wizard: Static IP" \
                    --msgbox "Some of the addresses provided are invalid\n${ERROR_MSG}" 0 0
      return 1
    fi

  DEFAULTMASK=$(ipcalc --netmask "${IP_ADDRESS}" | cut -d= -f2)

  if [ "x${NETMASK}" != "x${DEFAULTMASK}" ] ; then
      Xdialog --center --title "Puppy Network Wizard: Static IP" \
                    --yesno "WARNING:\nYour netmask does not correspond to your network address class.\n\nAre you sure it is correct?" 0 0
      if [ $? -eq 1 ] ; then
        return 1
      fi
  fi

    # Check that network is right
    if [ -z "$GATEWAY" ];then
        # It is legitimate not to have a gateway at all.  In that case, it
        # doesn't have a network. :-)
        unset HOSTNET
        unset GATENET
  else
        HOSTNUM=$(dotquad "$IP_ADDRESS")
        MASKNUM=$(dotquad "$NETMASK")
        GATENUM=$(dotquad "$GATEWAY")
        HOSTNET=$(and "$MASKNUM" "$HOSTNUM")
        GATENET=$(and "$MASKNUM" "$GATENUM")
 fi

    if [ "x${HOSTNET}" != "x${GATENET}" ] ; then
    Xdialog --center --wrap --title "Puppy Network Wizard: Static IP" \
                    --msgbox "Your gateway $GATEWAY is not on this network! Please try again.\n(You may have entered your address, gateway or netmask incorrectly.)" 0 0  0 0
    return 1
    fi

    return 0
} #end of staticIPSetup

#=============================================================================
setupStaticIP()
{
    BROADCAST=$(ipcalc -b ${IP_ADDRESS} ${NETMASK} | cut -d= -f2)

    ifconfig ${INTERFACE} down

    CONVO="ifconfig ${INTERFACE} ${IP_ADDRESS} netmask ${NETMASK} broadcast ${BROADCAST} up"
    CONVG="route add -net default gw ${GATEWAY}"

  # do the work
  ifconfig ${INTERFACE} ${IP_ADDRESS} netmask ${NETMASK} broadcast ${BROADCAST} up

  if [ $? -eq 0 ];then
        MODECOMMANDS="${CONVO}"
        # Configure a nameserver, if we're supposed to.
        # This now replaces any existing resolv.conf, which
        # we will try to back up.
        if [ "${DNS_SERVER1}" != "0.0.0.0" ] ; then
            mv -f /etc/resolv.conf /etc/resolv.conf.$$
            echo "nameserver ${DNS_SERVER1}" > /etc/resolv.conf
            if [ "${DNS_SERVER2}" != "0.0.0.0" ] ; then
                echo "nameserver ${DNS_SERVER2}" >> /etc/resolv.conf
            fi
        fi

   # add default route, if we're supposed to
        if [ "$GATEWAY" ] ; then
            route add -net default gw "$GATEWAY"
            if [ $? -eq 0 ];then #0=ok.
                Xdialog --center --title "Puppy Network Wizard: Static IP" --msgbox "Default route set through $GATEWAY." 0 0
                MODECOMMANDS="${MODECOMMANDS}\n${CONVG}"
            else
                Xdialog --center --title "Puppy Network Wizard: Static IP" --msgbox "Could not set default route through $GATEWAY.  Please try again.\n\nNote that Puppy has tried to do this:\n${CONVG}" 0 0
                ifconfig "$INTERFACE" down
                return 1
            fi
        fi

    return 0
  else
        Xdialog --center --title "Puppy Network Wizard: Static IP" --msgbox "Interface configuration failed; please try again.\n\nWhat Puppy has just tried to do is this:\n${CONVO} \n\nIf you think that this is incorrect for your system, and you can come up\nwith something else that works, let me know and maybe I can modify this\nnetwork setup script." 0 0
        ifconfig "$INTERFACE" down
        MODECOMMANDS=""
        return 1
    fi
} #end of setupStaticIP

#=============================================================================
saveNewModule()
{
  # save newly loaded module
  if ! grep "$NEWLOADED" /etc/ethernetmodules ;then
    echo "$NEWLOADED" >> /etc/ethernetmodules
  fi
  TOPMSG="MODULE '$NEWLOADED' RECORDED IN /etc/ethernetmodules
Puppy will read this when booting up."
    setDefaultMODULEBUTTONS
}


#=============================================================================
unloadNewModule()
{
  # unload newly loaded module
  modprobe -r $NEWLOADED
  grep -v "$NEWLOADED" /etc/ethernetmodules > /etc/ethernetmodules.tmp
  sync
  mv -f /etc/ethernetmodules.tmp /etc/ethernetmodules
  TOPMSG="MODULE '$NEWLOADED' UNLOADED.
Also, '$NEWLOADED' removed from /etc/ethernetmodules (if it was there)."

  setDefaultMODULEBUTTONS

    refreshMainWindowInfo

}

#=============================================================================
validip(){
# uses dotquad.c to parse $1 as a dotted-quad IP address
if dotquad "$1" &> /dev/null
then
 return 0
else
 return 1
fi
} #end of validip function

#=============================================================================
setDefaultMODULEBUTTONS()
{
  MODULEBUTTONS="
<hbox>
    <text>
        <label>\"If it appears the driver module for a network adaptor isn't loaded, or you want a different one (such as a Windows driver with Ndiswrapper) click on the 'Load module' button.\"</label>
    </text>
    <vbox>
        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        <button>
            <label>Load module</label>
            <action>EXIT:10</action>
        </button>
    </vbox>
</hbox>"
}

#=============================================================================
# Dougal: created this, so can give an option to autoload usb modules
setDefaultUSB_MODULE_BUTTON()
{
  USB_MODULE_BUTTON="
    <hbox>
        <text>
            <label>\"If you have connected a USB network device after booting, the appropriate module is probably not loaded.
Press the 'Autoload USB' button to (try and) autoload modules for such devices.\"</label>
        </text>
        <vbox>
            <pixmap><input file>$BLANK_IMAGE</input></pixmap>
            <button>
                <label>Autoload USB</label>
                <action>EXIT:66</action>
            </button>
        </vbox>
    </hbox>"
}

#=============================================================================
# Dougal: run the script autoloading usb modules
AutoloadUSBmodules()
{
 NEWMODULES=""
 # Run the script

 #load-usb-modules.sh   v2.21 Bk...
[ -s /tmp/new-usb-modules ] && rm -f /tmp/new-usb-modules
KERNELVER="`uname -r`"
. /etc/rc.d/MODULESCONFIG
USBMODINFO="`cat /lib/modules/modules.usbmap.$KERNELVER | tr -s " " | cut -f 1,3,4 -d " " | tr [A-Z] [a-z]`"
#...returns module-name vendor-id product-id
USBNUMS="`cat /proc/bus/usb/devices | grep '^P: ' | tr -s ' ' | cut -f 2-3 -d ' ' | tr ' ' '|' | tr [A-Z] [a-z] | tr '\n' ' '`"
for ONENUM in $USBNUMS
do
 VENDOR="`echo -n "$ONENUM" | cut -f 1 -d '|' | cut -f 2 -d '='`"
 PRODUCT="`echo -n "$ONENUM" | cut -f 2 -d '|' | cut -f 2 -d '='`"
 ONEUSB="0x${VENDOR} 0x${PRODUCT}"
 [ "$ONEUSB" = "0x0000 0x0000" ] && continue
 USBMODULE="`echo "$USBMODINFO" | grep "$ONEUSB" | cut -f 1 -d ' ' | head -n 1`"
 #pickup cases where more than one module has same IDs...
 USBMODULE2="`echo "$USBMODINFO" | grep "$ONEUSB" | cut -f 1 -d ' ' | tail -n 1`"
 if [ "$USBMODULE" != "" ];then
  #skip some modules... SKIPLIST is in /etc/rc.d/MODULESCONFIG
  SKIPPATTERN=" $USBMODULE "
  [ "`echo -n "$SKIPLIST" | grep "$SKIPPATTERN"`" != "" ] && continue
  #rt73 module gets picked but in some cases rt2570 has same IDs and should be used...
  [ "$USBMODULE" = "rt73" ] && [ "$USBMODULE2" = "rt2570" ] && USBMODULE="rt2570"
  modprobe $USBMODULE
  [ $? -eq 0 ] && echo -n "$USBMODULE " >> /tmp/new-usb-modules
 fi
done


 #sleep 1
 NONE_MESSAGE="No new USB modules loaded. Maybe try the 'Load module' button to manually select a module for your device."
 # Check for new modules
 if [ -s /tmp/new-usb-modules ] ; then
   # check if new modules are actually for network devices...
   for AMOD in `cat /tmp/new-usb-modules`
   do grep -q "^$AMOD" /etc/networkmodules && NEWMODULES="$NEWMODULES $AMOD"
   done
   # now see if there's really a new one
   if [ "$NEWMODULES" ] ; then
     # need to wait for interfaces to initialize...
     sleep 3
     TOPMSG="The following USB modules have been loaded:
   $NEWMODULES
   Now see if a new interface has appeared below..."
   else
     TOPMSG="$NONE_MESSAGE"
   fi
 else
   TOPMSG="$NONE_MESSAGE"
 fi
 # Remove the usb-modules frame
 USB_MODULE_BUTTON=""
 # refresh the main window (find new interfaces)
 refreshMainWindowInfo
}

#=============================================================================
# Dougal: a function to find info about interface:
#v2.21 BK modified...
findInterfaceInfo()
{
  local INT="$1"
  TYPE=""
  INFO=""

  FI_DRIVER="`readlink /sys/class/net/$INT/device/driver`"
  FI_DRIVER="`basename "$FI_DRIVER"`"
  FIPATTERN="^$FI_DRIVER "
  WHATWEWANT="`grep "$FIPATTERN" /etc/networkmodules | tr '|' '_' | tr '"' '|'`" #'geany
  TYPE="`echo -n "$WHATWEWANT" | cut -f 2 -d '|' | cut -f 1 -d ':'`"
  INFO="`echo -n "$WHATWEWANT" | cut -f 2 -d '|' | tr -s ' ' | cut -f 2-29 -d ' '`"
  [ "$TYPE" = "" ] && TYPE="x"
  [ "$INFO" = "" ] && INFO="x"

  #want to manipulate the info string for display purposes...
  CNTLINE=0;FINALINFO=""
  for ONEWORD in $INFO
  do
   CNTWORD=`echo "$ONEWORD" | wc -c`
   CNTLINE=`expr $CNTLINE + $CNTWORD`
   [ $CNTLINE -gt $BIGGESTCNT ] && BIGGESTCNT=$CNTLINE #use for window width.
   [ $CNTLINE -gt 50 ] && break
   FINALINFO="${FINALINFO}${ONEWORD} " #ensures whole words only in string.
  done
  INFO="$FINALINFO "

  if grep -q "$INT" /proc/net/wireless || [ "$FI_DRIVER" = "prism2_usb" ] ; then
    INTTYPE="Wireless"
  else
    INTTYPE="Ethernet"
  fi

  #v411 BK: save info to file...
  echo "$INTTYPE $INT $TYPE $FI_DRIVER '$FINALINFO'" >> /tmp/net-setup-interface-info-tmp


} # end findInterfaceInfo

#=============================================================================
saveInterfaceSetup()
{
  INTERFACE=$1

  if [ ! "$IS_WIRELESS" ] ; then
    rm -f /etc/${INTERFACE}wireless
  fi

  if [ -e "/tmp/wag-profiles_iwconfig.sh" ] ; then
    cp /tmp/wag-profiles_iwconfig.sh /etc/${INTERFACE}wireless
  fi

  echo -e "${MODECOMMANDS}" > /etc/${INTERFACE}mode

}

#=============================================================================
showHelp()
{
  pman "net_setup" &>$OUT &
}


#=============================================================================
#=============== START OF SCRIPT BODY ====================
#=============================================================================


# Cleanup older temp files
rm -f /tmp/ethmoduleyesload.txt
rm -f /tmp/loadedeth.txt
rm -f /tmp/wag-profiles_iwconfig.sh

> /tmp/logethtries.txt

# Do we have pcmcia hardware?... v2.21 BK...
[ "`lsmod | grep -E '^i82365|^tcic|^yenta_socket'`" != "" ] && MPCMCIA="yes"

setDefaultMODULEBUTTONS

# Dougal: add this for usb modules:
setDefaultUSB_MODULE_BUTTON

refreshMainWindowInfo

BGCOLOR="#ffe0e0" #light red.
TOPMSG="Hi, networking is not always easy to setup, but let's give it a go!"

showMainWindow

#=============================================================================
#================ END OF SCRIPT BODY =====================
#=============================================================================

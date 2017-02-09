# This function library is a descendant of the Wifi Access Gadget
# BATCHMARKER01 - Marker for Line-Position to bulk insert code into.
. /etc/rc.d/f4puppy5
# created by Keenerd. It went to several modifications to finally
# be fully integrated into the ethernet/network wizard.
#v430 tempestuous: update for 2.6.30.5 kernel.

# History of wag-profiles
# Dougal: port to gtkdialog3 and add icons
# Update: Jul. 4th 2007: rearrange the main window, add disabling of WPA button
# Update: Jul. 13th: add usage of wlanctl for prism2_usb module
# Update: Jul. 17th: fix broken pipe when running /tmp/wireless-config
# Update: Jul. 29th: split iwconfig commands into multiple lines, add security option
# Update: Jul. 31th: add security and scanning for prism2_usb
# Update: Aug.  1st: add usage of the scanned cell mode -- used to be ignored
# Update: Aug. 17th: fixed problem with "<hidden>" essid in WPA and made some improvements
#       to parsing scan results
# Update: Aug. 21st: add WPA2 code
# Update: Aug. 23rd: fixed missing WPA2 instance
# Update: Oct.  2nd: from Craig: add r8180|r8187 + support all prism2 modules
# Update: Dec.  2nd: change minimum passphrase length to 8 chars
# Update: Jan. 2nd 2008: comment out wpa_cli reconfigure as pointed out by Pizza
# Update: Mar.  7th: squash dialog a bit, for 7" screens
# Update: Mar. 15th: fix "grep -A 10" to "-A 11"
# Update: Jun. 25th: add new wireless drivers to case structure
# Update: Jun. 29th: improve getCellParameters, so we get ALL info for the cell
# Update: Jul.  6th: add escaping of funny chars when generating PSK
#                                        add new function: validateWpaAuthentication
#                                        add new function: cleanUpInterface
# Update: Jul.  8th: add increasing rate for ath5k
# Update: Jul. 15th: convert to new config setup, add assignProfileData, runPrismScan
# Update: Jul. 20th: change "Supp." and "Hidden" to "Broadcast SSID" and "Hidden SSID"
# Update: Jul. 21st: fix loadProfileData -- filename got truncated
# Update: Jul. 22nd: fix loadProfileData again: use grep -l
#                                        add wlan_tkip loading for ath_pci
# Update: Jul. 23rd: fix the code for returning an error from interface config
# Update: Jul. 24th: improve profiles dialog, move "scan" button to top
# Update: Jul. 25th: add some failsafes for saving bad profiles, to fix crashes
# Update: Jul. 28th: remove the code returning "failure" in case of a failed command
# Update: Jul. 30th: change redirection to DEBUG_OUTPUT to _append_
# Update: Aug.  1st: move configuration files into /etc/network-wizard
# Update: Aug. 15th: add Mode:Master to getCellParameters
#                                        add CELL_ENC_TYPE, so scan dialog shows actuall type
# Update: Aug. 16th: add support for Extra:rsn_ie (=WPA2) in scan window
# Update: Aug. 18th: add iwconfig commands to cleanUpInterface
# Update: Aug. 20th: fix bug with two IE: lines for same cell
# Update: Aug. 23rd: use "wpa_cli terminate" to properly kill wpa_supplicant
#                                        create killDhcpcd and use in cleanUpInterface
#       in setupScannedProfile, default to WPA_AP_SCAN="1" if SSID exists
# Update: Aug. 25th: add ndiswrapper to modules allowed to use WPA
#                                        add option to reset pcmcia card if scan fails
# Update: Sep. 12th: if scan finds no networks, try again before giving dialog
#                                        create create*Dialog functions to build dialogs with gtkdialog
# Update: Sep. 13th: comment out CELL_ENC_TYPE code: "IE:" isn't reliable
#                                        update ath5k rate increase to use "ath5k*"
# Update: Sep. 15th: add to cleanUpInterface setting mode to managed (suggested by Nym1)
# Update: Sep. 16th: add clean_up_gtkdialog and rename dialog variables
#                                        add giveNoNetworkDialog, so user knows profile isn't saved
#                                        replace all `` subshells with $()
# Update: Sep. 17th: add "retry" option to buildPrismScanWindow...
# Update: Sep. 18th: add cleanUpInterface before wireless scans...
# Update: Sep. 21st: validateWpaAuthentication, double max time to 30 (old code had 60!)
#                                        replace gxmessage and Xdialog --progress with gtkdialog
# Update: Sep. 22nd: add fancy new wpa_supplicant progressbar
# Update: Sep. 23rd: in killDhcpcd, replace dhcpcd -k with manual kill
# Update: Sep. 24th: add improved wpa fail dialog and killing of wpa_supplicant on failure!
#                                        add to useWpaSupplicant "wizard" parameter, for running from rc.network
#                                        in killDhcpcd, kill from .pid files and make /var/lib/dhcpcd checked first
#                                        move setupDHCP over from net-setup.sh and add new progressbar
# Update: Sep. 28th: add suggestions to createNoNetworksDialog
#                                        create giveErrorDialog, so can reuse code
# Update: Sep. 30th: setupDHCP: add echoing of all dhcpcd output to $DEBUG_OUTPUT
#                                        remove NWID from advanced fields: it's pre 802.11...
#                                        add ERROR to interface raising in cleanUpInterface
# Update: Oct.  1st: add disabling of irrelevant encryption buttons when profile loaded
# Update: Oct. 10th: add more WPA supporting modules from tempestuous+ alphabetize wext mods
#                                        fix bug when WPA passphrase has spaces in it (quote inner subshell)
#                                        move wpa psk code into function (getWpaPSK)
#                                        create wpa_supplicant config file when profile saved (saveWpaProfile)
#                                        cancel the wpa_cli code in useWpaSupplicant (since done already with sed)
# Update: Oct. 13th: make ap_scan default to 2 for ndiswrapper (even with broadcast ssid)
# Update: Oct. 16th: disabling quoting of 64-char psk in wpa_supplicant config files
# Update: Oct. 27th: add rt28[67]0* to WPA whitelist
# Update: Oct. 29th: localize
# Update: Oct. 31st: comment out the route table flushing in cleanUpInterface
# Update: Nov.  7th: move rtl818[07] to the list of "wext" using modules.
# Update: Dec.  7th: Remove the escaping of chars when running wpa_passphrase
# Update: Feb. 8th 2009: Handle funny chars in key: escape gtkdialog output and config variable
# Update: Feb. 10th: remove bashisms
# Update: Mar.  2nd: in saveWpaProfile, change sed commands to start with \W (not tab)
# Update: Mar.  3rd: in the wpa_passphrase subshell, add 'grep -v', due to [^#] not working...
# Update: Mar.  6th: in setupDHCP, if not running from X, add flag to stop dhcpcdProgress
# Update: Mar. 15th: add iwl5100 and iwlagn to WPA-supporting mmodules (I assume they do...)
# Update: Mar. 19th: move to using tmp files for wireless scans, add Get_Cell_Parameters
#                                        update giveNoWPADialog to offer the user to add module to list
# Update: Mar. 26th: add 5 second sleep between wireless scans for pcmcia cards
# Update: Mar. 29th: move 5 second sleep to before scanning at all, in waitForPCMCIA
#                                        add running "iwconfig "$INTERFACE" key on" before setting key
# Update: Mar. 30th: in assembleProfileData, quote the key when echoing to sed!
# Update: Apr.  1st: in buildProfilesWindow, quote the default title, ssid and key
#                                        change pcmcia sleep detection to module name being *_cs...
# Update: Apr.  2nd: add checkIsPCMCIA,
#                                        move interface cleanup out if buildScanWindow, add ifconfig down/up
# Update: Apr.  4th: fix checkIsPCMCIA

#
# Paul Siu
# Ver 1.1 Jun 09, 2007
#  Added support for ralink wireless network adapters.
#
# Rarsa
# Ver 1.0 Oct 23, 2006
#  Reorganized code
#  Integrated into net-setup (the Puppy Ethernet/Network wizard)

# History of Wifi Access Gadget
# Keenerd
# ver 0.4.0
#  under development
#  new ping dialog
#  profile generator
#  new interface
#  replace xmessage dialogs
#  automatic dhcpcd handling
# ver 0.3.2
#  10+ cells
#  socket-test in main program
#  improved pupget registration
#  improved ifconfig use
#  improved ad-hoc support
#  waiting dialog
#  slightly prettier xmessage
# ver 0.3.1
#  improved 1.0.5 compatability
#  bug fixes
# ver 0.3.0
#  profiles
#  help interface
#  install to /usr
# ver 0.2.6
#  additional scan error handling
#  additional dhcpcd error handling
#  smarter buttons
#  PCMCIA optional
#  rewrote everything (bug hunt/verbose code)
#  new debug script
# ver 0.2.5
#  essid with spaces
#  external wag-conf
#  no overwrite of user files on reinstall
#  better socket testing
# ver 0.2.4
#  autodetect adapter from /proc/net/wireless
#  ping moved to seperate button
#  got rid of silly disk writes
#  added socket testing
# ver 0.2.3
#  usability improvements in documentation and installer
# ver 0.2.2
#  reports open networks
#  refresh in Scan dialog
#  dotpupped
# ver 0.2.1
#  scan bug fixed
#  partial support of Wifi-Beta
#  intelligent buttons
# ver 0.2.0
#  interactive scanning
#  public release
# ver 0.1.0
#  interactive command buttons
# ver 0.0.0
#  basic diagnostic listing

_debug "$0:'$*'"

## Dougal: dirs where config files go
# network profiles, like the blocks in /etc/WAG/profile-conf used to be
# named ${PROFILE_AP_MAC}.${PROFILE_ENCRYPTION}.conf
PROFILES_DIR='/etc/network-wizard/wireless/profiles'
[ -d "$PROFILES_DIR" ] || mkdir $VERB -p "$PROFILES_DIR"
# wpa_supplicant.conf files
# named ${PROFILE_AP_MAC}.${PROFILE_ENCRYPTION}.conf
WPA_SUPP_DIR='/etc/network-wizard/wireless/wpa_profiles'
[ -d "$WPA_SUPP_DIR" ] || mkdir $VERB -p "$WPA_SUPP_DIR"
# configuration data for wireless interfaces (like if they support wpa)
# named $HWADDRESS.conf (assuming the HWaddress is more unique than interface name...)
# mainly intended to know if interface has been "configured"...
WLAN_INTERFACES_DIR='/etc/network-wizard/wireless/interfaces'
[ -d "$WLAN_INTERFACES_DIR" ] || mkdir $VERB -p "$WLAN_INTERFACES_DIR"

# a file where WPA-supporting modules not included in the default list can be added
Extra_WPA_Modules_File='/etc/network-wizard/wpa_modules'

## Dougal: put this into a variable
BLANK_IMAGE=/usr/share/pixmaps/net-setup_btnsize.png

## KRG : kernel 3.4.9 hangs at ifconfig wlan0 0.0.0.0 for one-two minutes,
## I get "phy0 -> rt2x00lib_request_firmware: Error - Failed to request Firmware."
## from dmesg, both busybox and regular ifconfig
## Dropped the relevant rt2860.bin into /lib/firmware/ directory, still same error.
KERNEL=`uname -r`
#K_VERSION=`echo "$KERNEL" | awk -F '[_.-]' '{print $1}'`
#K_PATCHLEVEL=`echo "$KERNEL" | awk -F '[_.-]' '{print $2}'`
#K_SUBLEVEL=`echo "$KERNEL" | awk -F '[_.-]' '{print $3}'`
#K_EXTRALEVEL=`echo "$KERNEL" | awk -F '[_.-]' '{print $4}'`
#echo "$KERNEL" | IFS='.-_' read K_VERSION K_PATCHLEVEL K_SUBLEVEL K_EXTRALEVEL K_EXTRANAME;
IFS='.-_' read K_VERSION K_PATCHLEVEL K_SUBLEVEL K_EXTRALEVEL K_EXTRANAME<<EOI
`echo "$KERNEL"`
EOI
[ "${K_EXTRALEVEL//[[:digit:]]/}" ] && { K_EXTRANAME=${K_EXTRALEVEL}${K_EXTRANAME};K_EXTRALEVEL=0; }
(
echo KERNEL=$KERNEL
echo K_VERSION=$K_VERSION
echo K_PATCHLEVEL=$K_PATCHLEVEL
echo K_SUBLEVEL=$K_SUBLEVEL
echo K_EXTRALEVEL=$K_EXTRALEVEL
echo K_EXTRANAME=$K_EXTRANAME
) >&2
#=============================================================================
# set dhcpcd options

IPV4LL='-L' #-L, --noipv4ll
            # Don't use IPv4LL at all.

ARP=        #-A, --noarp
            # Don't request or claim the address by ARP.

GWAY=       # -G, --nogateway
            # Don't set any default routes.

     #-M, --nomtu
            # Don't set the MTU of the interface.

     #-N, --nontp
            # Don't touch /etc/ntpd.conf or restart the ntp service.

     #-R, --nodns
            # Don't send DNS information to resolvconf or touch
            # /etc/resolv.conf.

     #-T, --test
            # On receipt of discover messages, simply print the contents of the
            # DHCP message to the console.  dhcpcd will not configure the
            # interface, touch any files or restart any services.

     #-Y, --nonis
            # Don't touch /etc/yp.conf or restart the ypbind service.

     #-D, --nisdomain
            # Forces dhcpcd to set domainname of the host to the domainname
            # option supplied by DHCP server.

     #--netconfig
            # Forces dhcpcd to use the SuSE netconfig tool. This option turn on
            # following options: -N, -R, -Y and sets -c to
            # /etc/sysconfig/network/scripts/dhcpcd-hook.


     #or if that is not an
     #option you can compile DUID support out of dhcpcd or use the -I,
     #--clientid clientid option and set clientid to ''.

     #ISC dhcpd, dnsmasq, udhcpd and Microsoft DHCP server 2003 default config-
     #urations work just fine with the default dhcpcd configuration.

     #dhcpcd requires a Berkley Packet Filter, or BPF device on BSD based sys-
     #tems and a Linux Socket Filter, or LPF device on Linux based systems.

     #-d, --debug
            # Echo debug and informational messages to the console.  Subsequent
            # debug options stop dhcpcd from daemonising.


#=============================================================================
setupDHCP()
{
        _debug "setupDHCP:'$*' start"
        [ "$INTERFACE" ] || INTERFACE=$1
        [ "$INTERFACE" ] || return 1
        # max time we will wait for (used in dhcpcdProgress and used to decide I_INC)
        local MAX_TIME='30'
        # by how much we multiply the time to get percentage (3 for 30 seconds max time)
        local I_MULTIPLY='3'
        if [ "$HAVEX" = "yes" ]; then
                # Create a temporary fifo to pass messages to progressbar (can't just pipe to it)
                local PROGRESS_OUTPUT=/tmp/progress-fifo$$
                mkfifo $PROGRESS_OUTPUT
                echo "running '$L_TITLE_Network_Wizard'..."
                export Dhcpcd_Progress_Dialog="<window title=\"$L_TITLE_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
  <text><label>\"$(eval echo $L_TEXT_Dhcpcd_Progress)\"</label></text>
  <frame $L_FRAME_Progress>
      <progressbar>
      <label>Connecting</label>
      <input>while read bla ; do case \$bla in [0-9]*) ;; *) echo \"\$bla\" >>$DEBUG_OUTPUT ;; esac ; case \$bla in Debug*) continue ;; esac ; echo \"\$bla\" ; done</input>
      <action type=\"exit\">Ready</action>
    </progressbar>
  </frame>
  <hbox>
   <button>
     <label>$L_BUTTON_Abort</label>
     <input file icon=\"gtk-stop\"></input>
     <action>kill \$(ps ax | grep \"dhcpcd $DBG -I $IPV4LL $INTERFACE\" | awk '{print \$1}')</action>
     <action>EXIT:Abort</action>
   </button>
  </hbox>
 </vbox>
</window>"
                gtkdialog3 --program=Dhcpcd_Progress_Dialog <$PROGRESS_OUTPUT >$OUT &
                local XPID=$!
        else
                local PROGRESS_OUTPUT=$DEBUG_OUTPUT
                # we need some marker to let the progress function know we're done
                local TmpMarker=/tmp/setupDHCP.$(date +%N)
        fi
        # Run everything in a subshell, so _all_ the echoes go into gtkdialog
        # (we can't just use a pipe, since it will be attached to only one process)
        (
                # A function that does the incrementing of the progressbar
                # (It could have just been a loop, but the code is clearer this way...)
                # $1 - XPID, so we know if the user aborted
                dhcpcdProgress(){
                        for i in $(seq 1 $MAX_TIME)
                        do
                                sleep 1
                                # see if user aborted
                                if [ "$HAVEX" = "yes" ]; then
                                        pidof gtkdialog3 2>&1 |grep $Q "$1" || return
                                        # exit the function
                                else
                                        if [ -f "$TmpMarker" ] ; then
                                                rm "$TmpMarker"
                                                return
                                        fi
                                fi
                                #  i*3 will only get us up to 90% at 30 sec, but still... this
                                #+ could be tweaked and obviously needs to be adjusted to the max time
                                echo $((i*$I_MULTIPLY))
                        done
                }

                # Run the function that echoes the numbers that increment the progressbar
                dhcpcdProgress "$XPID" &

                # Run dhcpcd. The output goes to the text in the progressbar...
                if dhcpcd $DBG -I '' $IPV4LL "$INTERFACE" 2>&1
                then
                        HAS_ERROR=0
                else
                        HAS_ERROR=1
                fi
                # we're in a subshell, so variables set here will not be seen outside...
                echo "$HAS_ERROR" >/tmp/net-setup_HAS_ERROR.txt
                # close progressbar
                if [ "$HAVEX" = "yes" ] ; then
                        pidof gtkdialog3 2>&1 | grep $Q "$XPID" && echo "100"
                else
                        touch "$TmpMarker"
                fi
        # close subshell
        ) 2>&1 >> $PROGRESS_OUTPUT


        read HAS_ERROR < /tmp/net-setup_HAS_ERROR.txt
        rm /tmp/net-setup_HAS_ERROR.txt

        ## Clean up:
        if [ -n "$XPID" ] ;then
                kill $XPID #>/dev/null 2>&1
                # any rogue gtkdialog processes
                clean_up_gtkdialog Dhcpcd_Progress_Dialog
        fi
        if [ "$HAVEX" = "yes" ]; then # it's a pipe
                rm $PROGRESS_OUTPUT
        fi
        if [ $HAS_ERROR -eq 0 ]
        then
        # Dougal: not sure about this -- maybe add something? need to know we've used it
                MODECOMMANDS=""
        else
                MODECOMMANDS=""
                # need to kill dhcpcd, since it keeps running even with an error!
                killDhcpcd "$INTERFACE"
        fi

_debug "setupDHCP:'$*' end"
        return $HAS_ERROR
} #end of setupDHCP

#=============================================================================
showProfilesWindow()
{

_debug "showProfilesWindow:'$*' start"

        INTERFACE=${INTERFACE:-"$1"}
        [ "$INTERFACE" ] || return 1
        # Dougal: find driver and set WPA driver from it
        INTMODULE=$(readlink /sys/class/net/$INTERFACE/device/driver)
        INTMODULE=${INTMODULE##*/}
        case "$INTMODULE" in
         hostap*) CARD_WPA_DRV="hostap" ;;
         rt61|rt73) CARD_WPA_DRV="ralink" ;;
         r8180|r8187) CARD_WPA_DRV="ipw" ;;
         # Dougal: all lines below are "wext" (split and alphabetized for readability)
         ath_pci)  modprobe $Q $VERB wlan_tkip ;    CARD_WPA_DRV="wext" ;;
         ath5k*|ath9k*|b43|b43legacy|bcm43xx)       CARD_WPA_DRV="wext" ;;
         ar9170usb|at76c50x-usb)                    CARD_WPA_DRV="wext" ;;
         ipw2100|ipw2200|ipw3945)                   CARD_WPA_DRV="wext" ;;
         iwl3945|iwl4965|iwl5100|iwlagn)            CARD_WPA_DRV="wext" ;;
         libertas_cs|libertas_sdio|libertas_tf_usb) CARD_WPA_DRV="wext" ;;
         mwl8k)         CARD_WPA_DRV="wext" ;;
         ndiswrapper)   CARD_WPA_DRV="wext" ;;
         p54pci|p54usb) CARD_WPA_DRV="wext" ;;
         rndis_wlan)    CARD_WPA_DRV="wext" ;;
         rtl8180|rtl8187|rt2400pci|rt2500*|rt28[67]0*|rt61pci|rt73usb) CARD_WPA_DRV="wext" ;;
         usb8xxx)                                   CARD_WPA_DRV="wext" ;;
         zd1211|zd1211b|zd1211rw)                   CARD_WPA_DRV="wext" ;;
         #libertas_cs|libertas_sdio|libertas_tf_usb|mwl8k|usb8xxx) CARD_WPA_DRV="wext" ;; #v430
         #rt2800pci) CARD_WPA_DRV="wext" ;;  # KRG: Joy-IT GreatWall 310
	'') :;;
         *) # doesn't support WPA encryption
           # add an option to add modules to file
           if [ -f "$Extra_WPA_Modules_File" ] &&\
                CARD_WPA_DRV=$(grep -m1 "^$INTMODULE:" $Extra_WPA_Modules_File) ; then
             CARD_WPA_DRV=${CARD_WPA_DRV#*:}
           else
         CARD_WPA_DRV=""
                 giveNoWPADialog
           fi
           ;;
        esac

        # Dougal: add usage of wlan-ng, for prism2_usb module
        case "$INTMODULE" in prism2_*) USE_WLAN_NG="yes" ;; esac

        refreshProfilesWindowInfo
        setupNewProfile
        EXIT=""
        while true
        do
                _debug "building...buildProfilesWindow..."
                buildProfilesWindow
                _debug "buildProfilesWindow...build."

                I=$IFS; IFS=""
                ## Add escaping of funny chars before we eval the statement!
                for STATEMENT in  $(gtkdialog3 --program NETWIZ_Profiles_Window | sed 's%\$%\\$%g ; s%`%\\`%g ; s%"%\\"%g ; s%=\\"%="%g ; s%\\"$%"%g' ); do
                        eval $STATEMENT
                done
                IFS=$I
                clean_up_gtkdialog NETWIZ_Profiles_Window
                unset NETWIZ_Profiles_Window

                case "$EXIT" in
                        "abort" | "19" ) # Back or close window
				RV=255
                                break
                                ;; # Do Nothing, It will exit the while loop
                        "11" ) # Scan
                                showScanWindow
                                ;;
                        "12" ) # New profile
                                setupNewProfile
                                ;;
                        "20" ) # Save
                                assembleProfileData
                                [ $? =  0 ] && saveProfiles
                                refreshProfilesWindowInfo
                                loadProfileData "${CURRENT_PROFILE}"
                                ;;
                        "21" ) # Delete
                                deleteProfile
                                NEW_PROFILE_DATA=""
                                #saveProfiles
                                refreshProfilesWindowInfo
                                setupNewProfile
                                ;;
                        "22" ) # Use This Profile
                                  if useProfile ; then
                                        #return 0
                                   if test "$CURRENT_CONTEXT" = 'wag-profiles.sh'; then
					 setupDHCP
                                         RV=$?
                                    else RV=0
                                    fi
                                        break
                                  else # Dougal: add new message to say it failed
                                        #return 2
                                        RV=2
                                        break
                                  fi
                                ;;
                        "40" ) # Advanced fields
                                if [ "$ADVANCED" ] ; then
                                        unset -v ADVANCED
                                else
                                        ADVANCED=1
                                fi
                                ;;
                        ##  Dougal: comment out all the button shading below, so they
                        ##+ only get shaded when loading a profile!
                        "50" ) # No encryption
                                PROFILE_ENCRYPTION="Open"
                                ENABLE_WEP_BUTTON='false'
                                ENABLE_WPA_BUTTON='false'
                                ENABLE_WPA2_BUTTON='false'
                                ENABLE_OPEN_BUTTON='true'
                                ;;
                        "51" ) # WEP
                                PROFILE_ENCRYPTION="WEP"
                                ENABLE_WEP_BUTTON='true'
                                ENABLE_WPA_BUTTON='false'
                                ENABLE_WPA2_BUTTON='false'
                                ENABLE_OPEN_BUTTON='false'
                                ;;
                        "52" ) # WPA
                                PROFILE_ENCRYPTION="WPA"
                                PROFILE_WPA_TYPE=""
                                ENABLE_WEP_BUTTON='false'
                                ENABLE_WPA_BUTTON='true'
                                ENABLE_WPA2_BUTTON='false'
                                ENABLE_OPEN_BUTTON='false'
                                ;;
                        "53" ) # WPA2
                                PROFILE_ENCRYPTION="WPA2"
                                PROFILE_WPA_TYPE="2"
                                ENABLE_WEP_BUTTON='false'
                                ENABLE_WPA_BUTTON='false'
                                ENABLE_WPA2_BUTTON='true'
                                ENABLE_OPEN_BUTTON='false'
                                ;;
                        load) # If it wasn't any other button, it must be a profile button
                                PROFILE_TITLES="$( echo "$PROFILE_TITLES" | grep -v \"#NEW#\" )"
                                CURRENT_PROFILE="$PROFILE_COMBO"
                                loadProfileData "$CURRENT_PROFILE"

                                ;;
                esac

        done
_debug "showProfilesWindow:'$*' end"
        return ${RV:-1}
} # end showProfilesWindow

#=============================================================================
__giveNoWPADialog(){
        export NETWIZ_No_WPA_Dialog="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-dialog-info\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\">
      <input file stock=\"gtk-dialog-info\"></input>
    </pixmap>
  <text>
    <label>${L_TEXT_No_Wpa_p1}${INTMODULE}${L_TEXT_No_Wpa_p2}</label>
  </text>
  <hbox>
    <button ok></button>
  </hbox>
 </vbox>
</window>"

        gtkdialog3 --program NETWIZ_No_WPA_Dialog >$OUT 2>&1
        clean_up_gtkdialog NETWIZ_No_WPA_Dialog
        unset NETWIZ_No_WPA_Dialog
}

giveNoWPADialog(){
        _debug "NETWIZ_No_WPA_Dialog..."
        export NETWIZ_No_WPA_Dialog="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-dialog-info\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\">
    <input file stock=\"gtk-dialog-info\"></input>
  </pixmap>
  <text use-markup=\"true\">
    <label>\"${L_TEXT_No_Wpa_p1}<b>${INTMODULE}</b>${L_TEXT_No_Wpa_p2}\"</label>
  </text>
  <text use-markup=\"true\">
    <label>\"${L_TEXT_No_Wpa_Ask}\"</label>
  </text>
  <hbox>
        <button>
          <label>$L_BUTTON_No</label>
          <input file stock=\"gtk-no\"></input>
          <action>EXIT:cancel</action>
        </button>
        <button>
          <label>$L_BUTTON_Add_WPA</label>
          <action>EXIT:10</action>
        </button>
  </hbox>
 </vbox>
</window>"

        for ONE in $( gtkdialog3 --program=NETWIZ_No_WPA_Dialog )
        do eval $ONE
        done
        clean_up_gtkdialog NETWIZ_No_WPA_Dialog
        unset NETWIZ_No_WPA_Dialog
        [ "$EXIT" = "10" ] || return
        # give dialog with details we're going to add
        echo "running NETWIZ_WPA_Details_Dialog..."
        export NETWIZ_WPA_Details_Dialog="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-info\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"5\">
    <input file stock=\"gtk-info\"></input>
  </pixmap>
  <text>
    <label>${L_TEXT_Wpa_Add_p1}${Extra_WPA_Modules_File}${L_TEXT_Wpa_Add_p2}</label>
  </text>
  <hbox>
    <text><label>${L_ENTRY_Wpa_Add_Module}</label></text>
    <entry editable=\"false\">
          <default>$INTMODULE</default>
      <variable>ENTRY1</variable>
    </entry>
  </hbox>
  <hbox>
    <text><label>${L_ENTRY_Wpa_Add_WEXT}</label></text>
    <entry>
          <default>wext</default>
      <variable>ENTRY2</variable>
    </entry>
  </hbox>
  <hbox>
   <button ok></button>
   <button cancel></button>
  </hbox>
 </vbox>
</window>"

        for ONE in $( gtkdialog3 --program=NETWIZ_WPA_Details_Dialog )
        do eval $ONE
        done
        clean_up_gtkdialog NETWIZ_WPA_Details_Dialog
        unset NETWIZ_WPA_Details_Dialog
        [ "$EXIT" = "OK" ] || return
        # add the details
        [ -z "$ENTRY2" ] && ENTRY2=wext
        echo "$ENTRY1:$ENTRY2" >> $Extra_WPA_Modules_File
        CARD_WPA_DRV="$ENTRY2"

        _debug "giveNoWPADialog:'$*' end"
} #END giveNoWPADialog

#=============================================================================
refreshProfilesWindowInfo()
{
	_debug "showProfilesWindow:$*"
	#called by showProfilesWindow
        PROFILE_TITLES=$(grep -F 'TITLE=' ${PROFILES_DIR}/*.conf | cut -d= -f2 | tr -d '"' | tr " " "_" )
        # KRG: check duplicate tiltles and emit warning
        PROFILE_TITLES=`echo "$PROFILE_TITLES" | sed '/^$/d'`
        for TITLE in $PROFILE_TITLES; do
        #grep "^TITLE=\"$TITLE\"" ${PROFILES_DIR}/*.conf >&2
        FILES=`grep -l "^TITLE=\"$TITLE\"" ${PROFILES_DIR}/*.conf`
        NR=`echo "$FILES" | wc -l`
         if test "$NR" -gt 1; then
	(
         echo "WARNING: $TITLE is same in"
         echo "$FILES"
         ) >&2
         fi
        done
        _debug "showProfilesWindow:$*"
} # end refreshProfilesWindowInfo

#=============================================================================
buildProfilesWindow()
{
        _debug "buildProfilesWindow...start"
        DEFAULT_TITLE=""
        DEFAULT_ESSID=""
        DEFAULT_KEY=""
        DEFAULT_NWID=""
        DEFAULT_FREQ=""
        DEFAULT_CHANNEL=""
        DEFAULT_AP_MAC=""

        if [ "$PROFILE_MODE" = "ad-hoc" ] ; then
                PROFILE_MODE_M="false"
                PROFILE_MODE_A="true"
                DEFAULT_MODE_M="<default>${PROFILE_MODE_M}</default><visible>disabled</visible>"
                DEFAULT_MODE_A="<default>${PROFILE_MODE_A}</default>"
        else
                PROFILE_MODE_M="true"
                PROFILE_MODE_A="false"
                DEFAULT_MODE_M="<default>${PROFILE_MODE_M}</default>"
                DEFAULT_MODE_A="<default>${PROFILE_MODE_A}</default><visible>disabled</visible>"
        fi

    ## Dougal: add security option for iwconfig/wlanctl-ng
    if [ "$PROFILE_SECURE" = "open" ] ; then
                PROFILE_SECURE_R="false"
                PROFILE_SECURE_O="true"
                DEFAULT_SECURE_R="<default>${PROFILE_SECURE_R}</default><visible>disabled</visible>"
                DEFAULT_SECURE_O="<default>${PROFILE_SECURE_O}</default>"
        else
                PROFILE_SECURE_R="true"
                PROFILE_SECURE_O="false"
                DEFAULT_SECURE_R="<default>${PROFILE_SECURE_R}</default>"
                DEFAULT_SECURE_O="<default>${PROFILE_SECURE_O}</default><visible>disabled</visible>"
        fi
        if [ "$PROFILE_WPA_AP_SCAN" = "1" ] ; then # WPA Supplicant
                PROFILE_WPA_AP_SCAN_S="true"
                PROFILE_WPA_AP_SCAN_D="false"
                PROFILE_WPA_AP_SCAN_H="false"
                DEFAULT_WPA_AP_SCAN_S="<default>${PROFILE_WPA_AP_SCAN_S}</default>"
                DEFAULT_WPA_AP_SCAN_D="<default>${PROFILE_WPA_AP_SCAN_D}</default><visible>disabled</visible>"
                DEFAULT_WPA_AP_SCAN_H="<default>${PROFILE_WPA_AP_SCAN_H}</default><visible>disabled</visible>"
        elif [ "$PROFILE_WPA_AP_SCAN" = "0" ] ; then # Driver
                PROFILE_WPA_AP_SCAN_S="false"
                PROFILE_WPA_AP_SCAN_D="true"
                PROFILE_WPA_AP_SCAN_H="false"
                DEFAULT_WPA_AP_SCAN_S="<default>${PROFILE_WPA_AP_SCAN_S}</default><visible>disabled</visible>"
                DEFAULT_WPA_AP_SCAN_D="<default>${PROFILE_WPA_AP_SCAN_D}</default>"
                DEFAULT_WPA_AP_SCAN_H="<default>${PROFILE_WPA_AP_SCAN_H}</default><visible>disabled</visible>"
        else # Hidden SSID
                PROFILE_WPA_AP_SCAN_S="false"
                PROFILE_WPA_AP_SCAN_D="false"
                PROFILE_WPA_AP_SCAN_H="true"
                DEFAULT_WPA_AP_SCAN_S="<default>${PROFILE_WPA_AP_SCAN_S}</default><visible>disabled</visible>"
                DEFAULT_WPA_AP_SCAN_D="<default>${PROFILE_WPA_AP_SCAN_D}</default><visible>disabled</visible>"
                DEFAULT_WPA_AP_SCAN_H="<default>${PROFILE_WPA_AP_SCAN_H}</default>"
        fi

        [ "$PROFILE_TITLE" ]   &&   DEFAULT_TITLE="<default>\"${PROFILE_TITLE}\"</default>"
        [ "$PROFILE_ESSID" ]   &&   DEFAULT_ESSID="<default>\"${PROFILE_ESSID}\"</default>"
        [ "$PROFILE_KEY" ]     &&     DEFAULT_KEY="<default>\"${PROFILE_KEY}\"</default>"
        [ "$PROFILE_FREQ" ]    &&    DEFAULT_FREQ="<default>${PROFILE_FREQ}</default>"
        [ "$PROFILE_CHANNEL" ] && DEFAULT_CHANNEL="<default>${PROFILE_CHANNEL}</default>"
        [ "$PROFILE_AP_MAC" ]  &&  DEFAULT_AP_MAC="<default>${PROFILE_AP_MAC}</default>"

        buildProfilesWindowButtons

        setAdvancedFields

        case "$PROFILE_ENCRYPTION" in
                WEP)
                        setWepFields
                        ;;
                WPA)
                        setWpaFields
                        ;;
                WPA2)
                        setWpaFields
                        ;;
                * )
                        setNoEncryptionFields
                        ;;
        esac

        MAYBE_WIRELESS=`iwconfig 2>&1 | grep -vi 'no wireless extensions' | sed '/^[[:blank:]]*$/d ; /^$/d ; s/"//g'`
        echo "MAYBE_WIRELESS=$MAYBE_WIRELESS"
        if test "$MAYBE_WIRELESS"; then
         dlg_wl_TEXT=`echo "$MAYBE_WIRELESS" | sed 's/^[[:blank:]]*//'` # remove leading tabs formatting by iwconfig
        else
         dlg_wl_TEXT="No Wireless device detected."
        fi
        echo "dlg_wl_TEXT='$dlg_wl_TEXT'"

        dlg_WL_FRAME="	<frame Recognized Wireless Device>
	<text width-chars=\"60\" selectable=\"true\">
	<label>\"$dlg_wl_TEXT\"</label>
	</text>
	</frame>"

_debug "exporting NETWIZ_Profiles_Window..."
        export NETWIZ_Profiles_Window="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
        $dlg_WL_FRAME
        <hbox>
                <text use-markup=\"true\"><label>\"$L_TEXT_Profiles_Window\"</label></text>
                <button>
                        <label>$L_BUTTON_Scan</label>
                        <input file stock=\"gtk-zoom-100\"></input>
                        <action>EXIT:11</action>
                </button>
        </hbox>
        <frame  $L_FRAME_Load_Existing_Profile >
                <hbox>
                        <text>
                                <label>\"$L_TEXT_Select_Profile\"</label>
                        </text>
                        <combobox>
                                <variable>PROFILE_COMBO</variable>
                                ${PROFILE_BUTTONS}
                        </combobox>
                        <button>
                                <label>$L_BUTTON_Load</label>
                                <input file stock=\"gtk-apply\"></input>
                                <action>EXIT:load</action>
                        </button>
                </hbox>
        </frame>
        <frame  $L_FRAME_Edit_Profile >
                <vbox>

                        <hbox>
                                <vbox>
                                        <text><label>\"$L_TEXT_Encryption\"</label></text>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <vbox>
                                <button sensitive=\"$ENABLE_OPEN_BUTTON\">
                                        <label>$L_BUTTON_Open</label>
                                        <action>EXIT:50</action>
                                </button>
                                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <vbox>
                                        <button sensitive=\"$ENABLE_WEP_BUTTON\">
                                                <label>WEP</label>
                                                <action>EXIT:51</action>
                                        </button>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <vbox>
                                        <button sensitive=\"$ENABLE_WPA_BUTTON\">
                                                <label>WPA/TKIP</label>
                                                <action>EXIT:52</action>
                                        </button>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <vbox>
                                        <button sensitive=\"$ENABLE_WPA2_BUTTON\">
                                                <label>WPA2</label>
                                                <action>EXIT:53</action>
                                        </button>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                        </hbox>

                        <hbox>
                                <vbox>
                                        <text><label>\"$L_TEXT_Profile_Nmae\"</label></text>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <entry>
                                        <variable>PROFILE_TITLE</variable>
                                        ${DEFAULT_TITLE}
                                </entry>
                        </hbox>

                        <hbox>
                                <vbox>
                                        <text><label>\"$L_TEXT_Essid\"</label></text>
                                        <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                                </vbox>
                                <entry>
                                        <variable>PROFILE_ESSID</variable>
                                        ${DEFAULT_ESSID}
                                </entry>
                        </hbox>
                        <hbox>
                                <text><label>$L_TEXT_Mode</label></text>
                                <vbox>
                                        <checkbox>
                                                <label>$L_CHECKBOX_Managed</label>
                                                <variable>PROFILE_MODE_M</variable>
                                                <action>if true disable:PROFILE_MODE_A</action>
                                                <action>if false enable:PROFILE_MODE_A</action>
                                                ${DEFAULT_MODE_M}
                                        </checkbox>
                                </vbox>
                                <vbox>
                                        <checkbox>
                                                <label>\"$L_CHECKBOX_Adhoc\"</label>
                                                <variable>PROFILE_MODE_A</variable>
                                                <action>if true disable:PROFILE_MODE_M</action>
                                                <action>if false enable:PROFILE_MODE_M</action>
                                                ${DEFAULT_MODE_A}
                                        </checkbox>
                                </vbox>
                                <text><label>\"$L_TEXT_Security\"</label></text>
                                <vbox>
                                        <checkbox>
                                                <label>$L_CHECKBOX_Open</label>
                                                <variable>PROFILE_SECURE_O</variable>
                                                <action>if true disable:PROFILE_SECURE_R</action>
                                                <action>if false enable:PROFILE_SECURE_R</action>
                                                ${DEFAULT_SECURE_O}
                                        </checkbox>
                                </vbox>
                                <vbox>
                                        <checkbox>
                                                <label>$L_CHECKBOX_Restricted</label>
                                                <variable>PROFILE_SECURE_R</variable>
                                                <action>if true disable:PROFILE_SECURE_O</action>
                                                <action>if false enable:PROFILE_SECURE_O</action>
                                                ${DEFAULT_SECURE_R}
                                        </checkbox>
                                </vbox>
                        </hbox>

                        ${ENCRYPTION_FIELDS}

                        <hbox>
                                <button>
                                        <label>$L_BUTTON_Save</label>
                                        <input file icon=\"gtk-save\"></input>
                                        <action>EXIT:20</action>
                                </button>
                                <button>
                                        <label>$L_BUTTON_Delete</label>
                                        <input file icon=\"gtk-delete\"></input>
                                        <action>EXIT:21</action>
                                </button>
                                <button>
                                        <label>$L_BUTTON_Use_Profile</label>
                                        <action>EXIT:22</action>
                                </button>
                        </hbox>
                </vbox>
        </frame>

        <hbox>
                <button>
                  <label>$L_BUTTON_New_Profile</label>
                  <input file icon=\"gtk-new\"></input>
                  <action>EXIT:12</action>
                </button>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
                <button>
                        <label>${ADVANCED_LABEL}</label>
                        <input file icon=\"${ADVANCED_ICON}\"></input>
                        <action>EXIT:40</action>
                </button>
                <button>
                  <label>$L_BUTTON_Back</label>
                  <input file stock=\"gtk-go-back\"></input>
                  <action>EXIT:19</action>
                </button>
        </hbox>
</vbox>
</window>"
_debug_GTKdialog "$NETWIZ_Profiles_Window"
_debug "buildProfilesWindow:'$*' end"
} # end buildProfilesWindow

#=============================================================================
setNoEncryptionFields()
{
        _debug "setNoEncryptionFields:'$*' start"
        ENCRYPTION_FIELDS="$ADVANCED_FIELDS"
        _debug "setNoEncryptionFields:'$*' end"
}

#=============================================================================
setWepFields()
{
        _debug "setWepFields:'$*' start"
        ENCRYPTION_FIELDS="
<hbox>
        <vbox>
                <text><label>$L_TEXT_Key</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <entry>
                <variable>PROFILE_KEY</variable>
                ${DEFAULT_KEY}
        </entry>
</hbox>
${ADVANCED_FIELDS}
"
_debug "setWepFields:'$*' end"
} # end setWepFields

#=============================================================================
setWpaFields()
{
        _debug "setWpaFields:'$*' start"
        ENCRYPTION_FIELDS="
<hbox>
        <vbox>
                <text><label>$L_TEXT_AP_Scan</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <vbox>
                <checkbox>
                        <label>$L_CHECKBOX_Hidden_SSID</label>
                        <variable>PROFILE_WPA_AP_SCAN_H</variable>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_D</action>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_S</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_D</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_S</action>
                        ${DEFAULT_WPA_AP_SCAN_H}
                </checkbox>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <vbox>
                <checkbox>
                        <label>$L_CHECKBOX_Broadcast_SSID</label>
                        <variable>PROFILE_WPA_AP_SCAN_S</variable>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_D</action>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_H</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_D</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_H</action>
                        ${DEFAULT_WPA_AP_SCAN_S}
                </checkbox>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <vbox>
                <checkbox>
                        <label>$L_CHECKBOX_Driver</label>
                        <variable>PROFILE_WPA_AP_SCAN_D</variable>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_S</action>
                        <action>if true disable:PROFILE_WPA_AP_SCAN_H</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_S</action>
                        <action>if false enable:PROFILE_WPA_AP_SCAN_H</action>
                        ${DEFAULT_WPA_AP_SCAN_D}
                </checkbox>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <vbox>
                <text><label>\"       \"</label></text>
        </vbox>
</hbox>
<hbox>
        <vbox>
                <text><label>$L_TEXT_Shared_Key</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <entry>
                <variable>PROFILE_KEY</variable>
                ${DEFAULT_KEY}
        </entry>
</hbox>
"
_debug "setWpaFields:'$*' end"
} # end setWpaFields

#=============================================================================
# Dougal: removed NWID code from top of advanced fields
#<hbox>
        #<vbox>
                #<text><label>Network Id:</label></text>
                #<pixmap><input file>$BLANK_IMAGE</input></pixmap>
        #</vbox>
        #<entry>
                #<variable>PROFILE_NWID</variable>
                #${DEFAULT_NWID}
        #</entry>
#</hbox>

setAdvancedFields()
{
        _debug "setAdvancedFields:'$*' start"
        if [ ! "$ADVANCED" ] ; then
                ADVANCED_LABEL="$L_LABEL_Advanced"
                ADVANCED_ICON="gtk-add"
                ADVANCED_FIELDS=""
        else
                ADVANCED_LABEL="$L_LABEL_Basic"
                ADVANCED_ICON="gtk-remove"
                ADVANCED_FIELDS="
<hbox>
        <vbox>
                <text><label>$L_TEXT_Frequency</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <entry>
                <variable>PROFILE_FREQ</variable>
                ${DEFAULT_FREQ}
        </entry>
</hbox>
<hbox>
        <vbox>
                <text><label>$L_TEXT_Channel</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <entry>
                <variable>PROFILE_CHANNEL</variable>
                ${DEFAULT_CHANNEL}
        </entry>
</hbox>
<hbox>
        <vbox>
                <text><label>\"$L_TEXT_AP_MAC\"</label></text>
                <pixmap><input file>$BLANK_IMAGE</input></pixmap>
        </vbox>
        <entry>
                <variable>PROFILE_AP_MAC</variable>
                ${DEFAULT_AP_MAC}
        </entry>
</hbox>"
        fi
        _debug "setAdvancedFields:'$*' end"
} #end setAdvancedFields

#=============================================================================
buildProfilesWindowButtons()
{
  _debug "buildProfilesWindowButtons:'$*' start"
        PROFILE_BUTTONS=""
        #echo "PROFILE_FILE='$PROFILE_FILE'"
        if test -s "$PROFILE_FILE"; then
         defPROFILE=`grep -F "TITLE=" "$PROFILE_FILE" | cut -d= -f2 | tr -d '"'`
         test "$defPROFILE" && PROFILE_BUTTONS="<item>${defPROFILE}</item>"
        fi
        for PROFILE in $PROFILE_TITLES
        do
    case $PROFILE in '#NEW#') continue;; esac
    test "$PROFILE" = "$defPROFILE" && continue
                PROFILE_BUTTONS="${PROFILE_BUTTONS}<item>${PROFILE}</item>"
  done
  #echo "PROFILE_BUTTONS='$PROFILE_BUTTONS'"
  _debug "buildProfilesWindowButtons:'$*' end"
} # end buildProfileWindowButtons

#=============================================================================
setupNewProfile ()
{
        _debug "setupNewProfile:'$*' start"
        PROFILE_TITLE=""
        PROFILE_ESSID=""
        PROFILE_MODE="managed"
        PROFILE_SECURE="open"
        PROFILE_KEY=""
        PROFILE_NWID=""
        PROFILE_FREQ=""
        PROFILE_CHANNEL=""
        PROFILE_AP_MAC=""
        PROFILE_ENCRYPTION="Open"
        #  Need to use separate variables, so when a profile is loaded that has
        #+ open/WEP, it doesn't blank out everything, just the profile one...
        #  Need the card one for shading WPA buttons
        PROFILE_WPA_DRV="$CARD_WPA_DRV"
        # Enable all buttons by default
        ENABLE_WEP_BUTTON='true'
        ENABLE_WPA_BUTTON='true'
        ENABLE_WPA2_BUTTON='true'
        ENABLE_OPEN_BUTTON='true'
        # Dougal: disable the WPA buttons if interface doesn't support it.
        if [ ! "$CARD_WPA_DRV" ] ; then
                ENABLE_WPA_BUTTON='false'
                ENABLE_WPA2_BUTTON='false'
        fi

        PROFILE_TITLES="$( echo "$PROFILE_TITLES" | grep -v \"#NEW#\" )"
        PROFILE_TITLES="$PROFILE_TITLES
#NEW#"
        CURRENT_PROFILE="#NEW#"

_debug "setupNewProfile:'$*' end"
} # end setupNewProfile

#=============================================================================
# this is code from loadPrifileData, moved here so can be used at boot...
# (rather daft all this, should change profiles to contain PROFILE_ names)
assignProfileData(){
        _debug "assignProfileData:'$*' start"
        # now assign to PROFILE_ names...
        PROFILE_WPA_DRV="$WPA_DRV"
        PROFILE_WPA_TYPE="$WPA_TYPE"
        PROFILE_WPA_AP_SCAN="$WPA_AP_SCAN"
        PROFILE_ESSID="$ESSID"
        PROFILE_NWID="$NWID"
        PROFILE_KEY="$KEY"
        PROFILE_MODE="$MODE"
        PROFILE_SECURE="$SECURE"
        PROFILE_FREQ="$FREQ"
        PROFILE_CHANNEL="$CHANNEL"
        PROFILE_AP_MAC="$AP_MAC"
        [ "$PROFILE_ESSID" = "<hidden>" ] && PROFILE_ESSID=""

        if [ "$PROFILE_KEY" = "" ] ; then
                PROFILE_ENCRYPTION="Open"
                ENABLE_WEP_BUTTON='false'
                ENABLE_WPA_BUTTON='false'
                ENABLE_WPA2_BUTTON='false'
                ENABLE_OPEN_BUTTON='true'
        elif [ "$PROFILE_WPA_DRV" = "" ] ; then
                PROFILE_ENCRYPTION="WEP"
                ENABLE_WEP_BUTTON='true'
                ENABLE_WPA_BUTTON='false'
                ENABLE_WPA2_BUTTON='false'
                ENABLE_OPEN_BUTTON='false'
        elif [ "$PROFILE_WPA_TYPE" ] ; then # Dougal: add WPA2
                PROFILE_ENCRYPTION="WPA2"
                ENABLE_WEP_BUTTON='false'
                ENABLE_WPA_BUTTON='false'
                ENABLE_WPA2_BUTTON='true'
                ENABLE_OPEN_BUTTON='false'
        else
                PROFILE_ENCRYPTION="WPA"
                ENABLE_WEP_BUTTON='false'
                ENABLE_WPA_BUTTON='true'
                ENABLE_WPA2_BUTTON='false'
                ENABLE_OPEN_BUTTON='false'
        fi
        _debug "assignProfileData:'$*' end"
} # end assignProfileData

#=================================================================n============
loadProfileData()
{
        _debug "loadProfileData:'$*' start"
        # Dougal: added "SECURE" param, increment the "-A" below
        PROFILE_TITLE="$1"
        #PROFILE_DATA=`grep -A 11 -E "TITLE[0-9]+=\"${PROFILE_TITLE}\"" /etc/WAG/profile-conf`
        ## Dougal: I'm not sure about the name -- maybe need to change underscores to spaces?
        PROFILE_FILE=$( grep -l "TITLE=\"${PROFILE_TITLE}\"" ${PROFILES_DIR}/*.conf | head -n1 )
        # add failsafe, in case there is none
        [ "$PROFILE_FILE" ] || return 2
        [ -s "$PROFILE_FILE" ] || return 3
        # Dougal: source config file
        . "$PROFILE_FILE"
        # now assign to PROFILE_ names...
        assignProfileData
        _debug "loadProfileData:'$*' end"
} # end loadProfileData


_check_if_title_in_use()
{
ls "${PROFILES_DIR}"/*.conf 1>>$OUT 2>>$ERR
if test $? = 0; then
 grep $Q "^TITLE=\"$PROFILE_TITLE\"" "${PROFILES_DIR}"/*.conf
 if test $? = 0; then
  xmessage -bg red1 -title "$0" "Profile name '$PROFILE_TITLE' already in use." &
  true
 else
  false
 fi
else
 false
fi
RV=$?
#echo RV=$RV
return $RV
}

#=============================================================================
assembleProfileData()
{
        _debug "assembleProfileData:'$*' start"

        PROFILE_TITLE="$(echo "$PROFILE_TITLE" | tr ' ' '_')"
        # (BASHISM!)
        #PROFILE_TITLE=${PROFILE_TITLE// /_}
	_check_if_title_in_use && return 1

        if [ "$PROFILE_MODE_A" = "true" ] ; then
                PROFILE_MODE="ad-hoc"
        else
                PROFILE_MODE="managed"
        fi

        if [ "$PROFILE_SECURE_O" = "true" ] ; then
                PROFILE_SECURE="open"
        else
                PROFILE_SECURE="restricted"
        fi

        if [ "$PROFILE_WPA_AP_SCAN_H" = "true" ] ; then
                PROFILE_WPA_AP_SCAN="2"
        elif [ "$PROFILE_WPA_AP_SCAN_D" = "true" ] ; then
                PROFILE_WPA_AP_SCAN="0"
        else # WPA supplicant does the scanning
                PROFILE_WPA_AP_SCAN="1"
        fi

        case $PROFILE_ENCRYPTION in
                WPA|WPA2)
                        ;;
                WEP)
                        PROFILE_WPA_DRV=""
                        PROFILE_WPA_AP_SCAN=""
                        ;;
                *)
                        PROFILE_KEY=""
                        PROFILE_WPA_DRV=""
                        PROFILE_WPA_AP_SCAN=""
                        ;;
        esac

        NEW_PROFILE_DATA="TITLE=\"${PROFILE_TITLE}\"
        WPA_DRV=\"${PROFILE_WPA_DRV}\"
        WPA_TYPE=\"$PROFILE_WPA_TYPE\"
        WPA_AP_SCAN=\"${PROFILE_WPA_AP_SCAN}\"
        ESSID=\"${PROFILE_ESSID}\"
        NWID=\"${PROFILE_NWID}\"
        KEY=\"$(echo "$PROFILE_KEY" | sed 's%\$%\\$%g ; s%`%\\`%g ; s%"%\\"%g')\"
        MODE=\"${PROFILE_MODE}\"
        SECURE=\"${PROFILE_SECURE}\"
        FREQ=\"${PROFILE_FREQ}\"
        CHANNEL=\"${PROFILE_CHANNEL}\"
        AP_MAC=\"${PROFILE_AP_MAC}\"
        "
        _debug "assembleProfileData:'$*' end"
return 0
} # end assembleProfileData

#=============================================================================
deleteProfile(){
        _debug "deleteProfile:'$*' start"
        # skip the templates...
        case $PROFILE_TITLE in autoconnect|template) return ;; esac
        PROFILE_FILE="${PROFILES_DIR}/${PROFILE_AP_MAC}.${PROFILE_MODE}.${PROFILE_SECURE}.${PROFILE_ENCRYPTION}.conf"
        if [ -s "${PROFILE_FILE}" ] ; then
             rm "${PROFILE_FILE}"
        fi
        WPA_CONF="${WPA_SUPP_DIR}/${PROFILE_AP_MAC}.${PROFILE_MODE}.${PROFILE_SECURE}.${PROFILE_ENCRYPTION}.conf"
        if [ -s "${WPA_CONF}" ] ; then
             rm "${WPA_CONF}"
        fi
        _debug "deleteProfile:'$*' end"
} # end deleteProfile

#=============================================================================
## Dougal: we don't need all the mess here if not using one config file...
saveProfiles ()
{
        _debug "saveProfiles:'$*' start"
        CURRENT_PROFILE=$( echo "$NEW_PROFILE_DATA" | grep -F "TITLE=" | cut -d= -f2 | tr -d '"' )
        # Dougal: the templates aren't named after the mac address... (none)
        case $CURRENT_PROFILE in autoconnect|template) return ;; esac
        # add failsafe: skip if no mac address exists
        if [ -z "$PROFILE_AP_MAC" ] ; then
          #giveNoNetworkDialog
          giveErrorDialog "$L_MESSAGE_Bad_Profile"
          return 2
        fi
        PROFILE_FILE="${PROFILES_DIR}/${PROFILE_AP_MAC}.${PROFILE_MODE}.${PROFILE_SECURE}.${PROFILE_ENCRYPTION}.conf"
        echo "$NEW_PROFILE_DATA" > "${PROFILE_FILE}"
        # create wpa_supplicant config file
        case $PROFILE_ENCRYPTION in WPA|WPA2) saveWpaProfile ;; esac
        _debug "saveProfiles:'$*' end"
} # end saveProfiles

#=============================================================================
# A function to create an appropriate wpa_supplicant config, rather than use wpa_cli
saveWpaProfile(){
        _debug "saveWpaProfile:'$*' start"
        # first, get the WPA PSK (might have an error)
        getWpaPSK || return 1

        #WPA_CONF="${WPA_SUPP_DIR}/${PROFILE_AP_MAC}.${PROFILE_ENCRYPTION}.conf"
        WPA_CONF="${WPA_SUPP_DIR}/${PROFILE_AP_MAC}.${PROFILE_MODE}.${PROFILE_SECURE}.${PROFILE_ENCRYPTION}.conf"
        if [ ! -e "$WPA_CONF" ] ; then
                # copy template
                cp $VERB -a "${WPA_SUPP_DIR}/wpa_supplicant$PROFILE_WPA_TYPE.conf" "$WPA_CONF"
        fi
        # need to escape the original phrase for sed
        ## (need to be escaped twice (extra \\) if we want the result escaped)
        ESCAPED_PHRASE="$( echo "$PROFILE_KEY" | sed 's%\\%\\\\%g ; s%\$%\\$%g ; s%`%\\`%g ; s%"%\\"%g ; s%\/%\\/%g' )"
        STATUS=$?
        # need to change ap_scan, ssid and psk
        sed -i "s/ap_scan=.*/ap_scan=$PROFILE_WPA_AP_SCAN/" "$WPA_CONF"
	STATUS=$((STATUS+$?))
        sed -i "s/\Wssid=.*/	ssid=\"$PROFILE_ESSID\"/" "$WPA_CONF"    #TAB
	STATUS=$((STATUS+$?))
        sed -i "s/\Wpsk=.*/	#psk=\"$ESCAPED_PHRASE\"\n	psk=$PSK/" "$WPA_CONF" #TAB
	STATUS=$((STATUS+$?))
        #sed -i "s/	psk=.*/ psk=\"$PSK\"/" "$WPA_CONF"    #TAB
        #STATUS=$((STATUS+$?))
        _debug "saveWpaProfile:'$*' end"
        return $STATUS
} #end saveWpaProfile

#=============================================================================
# A function to get the psk from wpa_passphrase (moved out of useWpaSupplicant
getWpaPSK(){
        _debug "getWpaPSK:'$*' start"
        # If key is not hex, then convert to hex
        echo "$PROFILE_KEY" | grep $Q -E "^[0-9a-fA-F]{64}$"
        if [ $? -eq 0 ] ; then
                PSK="$PROFILE_KEY"
        else
                #KEY_SIZE=`echo "${PROFILE_KEY}" | wc -c`
                KEY_SIZE=${#PROFILE_KEY}
                if [ "$KEY_SIZE" -lt 8 ] || [ "$KEY_SIZE" -gt 64 ] ; then
                        giveErrorDialog "Error!
Shared key must be either
- ASCII between 8 and 63 characters
- 64 characters hexadecimal
"
                        return 1
                else #if [ $KEY_SIZE -lt 8 ] || [ $KEY_SIZE -gt 64 ]
                        # Dougal: add escaping of funny chars in passphrase
                        # also quote the inner subshell
                        # No! don't need subshell apparently, escaping chars is unneeded
                        #"$( echo "$PROFILE_KEY" | sed 's%\$%\\$%g ; s%`%\\`%g ; s%"%\\"%g' )"
                        ##  Strage: the first grep below was enough for me, but a user got
                        ##+ errors, because it didn't filter out the "#psk" line!
                        PSK=$(wpa_passphrase "$PROFILE_ESSID" "$PROFILE_KEY" | \
                                   grep -F "psk=" | grep -Fv '#psk' | cut -d"=" -f2 )
                        echo "PSK is |$PSK|" >> $DEBUG_OUTPUT
                        # make sure we got something!
                        if [ ! "$PSK" ] ; then
                          giveErrorDialog "$L_MESSAGE_Bad_PSK"
                          return 1
                        fi
                fi #if [ $KEY_SIZE -lt 8 ] || [ $KEY_SIZE -gt 64 ] ; then
        fi #if [ $? -eq 0 ] ; then #check for hex
        _debug "getWpaPSK:'$*' end"
        return 0
} # end getWpaPSK

#=============================================================================
# A function that gives an error message using gtkdialog
# $@: the dialog text
giveErrorDialog(){
        _debug "giveErrorDialog:'$*' start"
        # always echo it, too, for debug purposes
        echo "$@" >> $DEBUG_OUTPUT
        [ "$HAVEX" = "yes" ] || return
        echo "running NETWIZ_ERROR_DIALOG..."
        export NETWIZ_ERROR_DIALOG="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-dialog-error\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\">
      <input file stock=\"gtk-dialog-error\"></input>
    </pixmap>
  <text>
    <label>\"$@\"</label>
  </text>
  <hbox>
    <button ok></button>
  </hbox>
 </vbox>
</window>"

        gtkdialog3 --program NETWIZ_ERROR_DIALOG #>/dev/null 2>&1
        clean_up_gtkdialog NETWIZ_ERROR_DIALOG
        unset NETWIZ_ERROR_DIALOG
        _debug "giveErrorDialog:'$*' end"
} #end giveErrorDialog

__giveNoNetworkDialog(){
        export NO_NETWORK_ERROR_DIALOG="<window title=\"Puppy Network Wizard\" icon-name=\"gtk-dialog-error\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\">
      <input file stock=\"gtk-dialog-error\"></input>
    </pixmap>
  <text>
    <label>\"Error!
The profile had no network associated with it.
You must run a wireless scan and select a
network, then create a profile for it.\"</label>
  </text>
  <hbox>
    <button ok></button>
  </hbox>
 </vbox>
</window>"

        gtkdialog3 --program NO_NETWORK_ERROR_DIALOG >$OUT 2>&1
        clean_up_gtkdialog NO_NETWORK_ERROR_DIALOG
        unset NO_NETWORK_ERROR_DIALOG
}

#=============================================================================
useProfile ()
{
        _debug "useProfile:'$*' start"
        case $PROFILE_ENCRYPTION in
                WPA|WPA2)
                        useWpaSupplicant wizard || return 1
                        ;;
                *)
                        if [ "$USE_WLAN_NG" ] ; then
                          useWlanctl || return 1
                        else
                          useIwconfig || return 1
                        fi
                        ;;
        esac
        _debug "useProfile:'$*' end"
} # end useProfile

#=============================================================================
killWpaSupplicant ()
{

        _debug "killWpaSupplicant '$*'"
        # If there are supplicant processes for the current interface, kill them
        [ -d /var/run/wpa_supplicant ] || return
        INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
        #SUPPLICANT_PIDS=$( ps -e | grep -v "grep" | grep -E "wpa_supplicant.+${INTERFACE}" | grep -oE "^ *[0-9]+")
        #if [ -n "$SUPPLICANT_PIDS" ]; then
        #       rm /var/run/wpa_supplicant/$INTERFACE* >$OUT 2>&1
        #       for SUPPLICANT_PID in $SUPPLICANT_PIDS ; do
        #               kill $SUPPLICANT_PID >$OUT 2>&1
        #       done
        #       sleep 5 # to wait for the supplicant to shutdown
        #fi

        # Dougal: replace the above with this...
        wpa_cli -i "$INTERFACE" terminate 2>&1 |grep -v 'Failed to connect'
        [ -e /var/run/wpa_supplicant/$INTERFACE ] && rm -rf /var/run/wpa_supplicant/$INTERFACE
        _debug "killWpaSupplicant '$*'"
} # end killWpaSupplicant

##=============================================================================
# Dougal: put this into a function, for maintainability and so it can be used in setupDHCP
killDhcpcd()
{
        _debug "killDhcpcd '$*'"
        INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
        # release dhcpcd
        #dhcpcd -k "$INTERFACE" 2>$ERR
        # dhcpcd -k caused problems with instances of dhcpcd running on other interfaces...
        #kill $(ps ax | grep "dhcpcd $DBG -I  $INTERFACE" | awk '{print $1}') 2>$ERR
        # clean up if needed
        ## Dougal: check /var first, since /etc/dhcpc might exist in save file from the past...

        if [ -d /var/lib/dhcpcd ] ; then
          if [ -s /var/run/dhcpcd-${INTERFACE}.pid ] ; then
            kill $( cat /var/run/dhcpcd-${INTERFACE}.pid )
            rm -f /var/run/dhcpcd-${INTERFACE}.* #2>/dev/null
          fi

          #begin rerwin - Retain duid, if any, so all interfaces can use
          #it (per ipv6) or delete it if using MAC address as client ID.    rerwin
          rm -f /var/lib/dhcpcd/dhcpcd-${INTERFACE}.* #2>/dev/null  #.info
#end rerwin
          #rm -f /var/run/dhcpcd-${INTERFACE}.* 2>$ERR #.pid

        elif [ -d /etc/dhcpc ];then
          if [ -s /etc/dhcpc/dhcpcd-${INTERFACE}.pid ] ; then
            kill $( cat /etc/dhcpc/dhcpcd-${INTERFACE}.pid )
            rm /etc/dhcpc/dhcpcd-${INTERFACE}.pid #2>/dev/null
          fi
          rm /etc/dhcpc/dhcpcd-${INTERFACE}.* #2>/dev/null
          #if left over from last session, causes trouble.
        fi

        _debug "killDhcpcd '$*'"
} # end killDhcpcd

#=============================================================================
# a function to clean up before configuring interface
# list of stuff stolen from wicd
# $1: interface name
cleanUpInterface()
{
        _debug "cleanUpInterface '$*'"
        # put interface down
        #ifconfig "$1" down
        killDhcpcd "$1"
        # kill wpa_supplicant
        killWpaSupplicant "$1"
        # clean up some wireless stuff (taken from wifi-radar)
        if [ "$IS_WIRELESS" = "yes" ] ; then
echo IS_WIRELESS
          iwconfig "$1" essid off
echo "$0:cleanUpInterface '$*' `date` $LINENO"
          iwconfig "$1" key off
echo "$0:cleanUpInterface '$*' `date` $LINENO"
          iwconfig "$1" mode managed # auto doesn't exist anymore??
echo "$0:cleanUpInterface '$*' `date` $LINENO"
          iwconfig "$1" channel auto
echo "$0:cleanUpInterface '$*' `date` $LINENO"
        fi
        # put interface down
echo "$0:cleanUpInterface '$*' `date` $LINENO"
        ifconfig "$1" down
echo "$0:cleanUpInterface '$*' `date` $LINENO"

if [ "$K_VERSION" = 2 ] ; then
        # reset ip address (set a false one)
echo "$0:cleanUpInterface '$*' `date` $LINENO"
        ifconfig "$1" 0.0.0.0
echo "$0:cleanUpInterface '$*' `date` $LINENO"
fi

        # stop dhcpcd
        #killall dhcpcd 2>$ERR
        # flush routing table
        #ip route flush dev "$1"
        # bring interface up again
        #ifconfig "$1" up

if [ "$K_VERSION" = 2 ] ; then
        echo "$0:function cleanUpInterface:'$*' `date` $LINENO"
        if ! ERROR=$(ifconfig "$1" up 2>&1) ; then
          giveErrorDialog "${L_MESSAGE_Failed_To_Raise_p1}${1}${L_MESSAGE_Failed_To_Raise_p2} ifconfig $1 up
$L_MESSAGE_Failed_To_Raise_p3
$ERROR
"
          return 1
        fi
fi
        return $?
} # end cleanUpInterface

#=============================================================================
## Dougal: function to kill stray processes
## dialog variable passed as param
clean_up_gtkdialog(){
 [ "$1" ] || return 0
 for I in $( /bin/ps -eo pid,command | grep "$1" | grep -v grep | grep -F 'gtkdialog3' | cut -d' ' -f1 )
 do kill $I
 done
}

#=============================================================================
useIwconfig ()
{
_debug "useIwconfig:'$*' start"
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
  #(
        # Dougal: give the text message even when using dialog (for debugging)
        echo "Configuring interface $INTERFACE to network $PROFILE_ESSID with iwconfig..."
        if [ "$HAVEX" = "yes" ]; then
          echo "running NETWIZ_Connecting_DIALOG..."
          export NETWIZ_Connecting_DIALOG="<window title=\"L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\"><input file stock=\"gtk-network\"></input></pixmap>
  <text><label>\"${L_MESSAGE_Configuring_Interface_p1}${INTERFACE}${L_MESSAGE_Configuring_Interface_p2}${PROFILE_ESSID}...
\"</label></text>
 </vbox></window>"
          gtkdialog3 --program NETWIZ_Connecting_DIALOG &
          local XPID=$!
        fi
        #killWpaSupplicant
        # Dougal: reset the interface
        cleanUpInterface "$INTERFACE" >> $DEBUG_OUTPUT 2>&1
        #echo "X"
        #RUN_IWCONFIG=""
        # Dougal: re-order these a bit, to match order in wicd
        (
        [ "$PROFILE_MODE" ]    && iwconfig "$INTERFACE" mode    $PROFILE_MODE
        [ "$PROFILE_ESSID" ]   && iwconfig "$INTERFACE" essid  "$PROFILE_ESSID"
        [ "$PROFILE_CHANNEL" ] && iwconfig "$INTERFACE" channel $PROFILE_CHANNEL
        [ "$PROFILE_AP_MAC" ]  && iwconfig "$INTERFACE" ap      $PROFILE_AP_MAC
        [ "$PROFILE_NWID" ]    && iwconfig "$INTERFACE" nwid    $PROFILE_NWID
        [ "$PROFILE_FREQ" ]    && iwconfig "$INTERFACE" freq    $PROFILE_FREQ
        if [ "$PROFILE_KEY" ] ; then
          iwconfig "$INTERFACE" key on
          iwconfig "$INTERFACE" key $PROFILE_SECURE "$PROFILE_KEY"
        fi
        # Dougal: add increasing of rate for ath5k
        case $INTMODULE in ath5k*) iwconfig "$INTERFACE" rate 11M  ;; esac
        ) >> $DEBUG_OUTPUT 2>&1

        #echo "X"
        if [ "$XPID" ] ;then
          kill $XPID #>/dev/null 2>&1
          clean_up_gtkdialog NETWIZ_Connecting_DIALOG
        fi
        unset NETWIZ_Connecting_DIALOG
        _debug "useIwconfig:'$*' end"
        return 0
  #) | Xdialog --title "Puppy Ethernet Wizard" --progress "Saving profile" 0 0 3
} # end useIwconfig

#=============================================================================
# Dougal: add this for the prism2_usb module
useWlanctl(){
	_debug "useWlanctl:'$*' start"
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
  #(
        # Dougal: give the text message even when using dialog (for debugging)
        echo "Configuring interface $INTERFACE to network $PROFILE_ESSID with wlanctl-ng..."
        if [ "$HAVEX" = "yes" ]; then
        echo "NETWIZ_Connecting_DIALOG..."
          export NETWIZ_Connecting_DIALOG="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\"><input file stock=\"gtk-network\"></input></pixmap>
  <text><label>\"${L_MESSAGE_Configuring_Interface_p1}${INTERFACE}${L_MESSAGE_Configuring_Interface_p2}${PROFILE_ESSID}...
\"</label></text>
 </vbox></window>"
          gtkdialog3 --program NETWIZ_Connecting_DIALOG &
          local XPID=$!
        fi
        #killWpaSupplicant
        cleanUpInterface "$INTERFACE" >> $DEBUG_OUTPUT 2>&1
        #echo "X"
        # create code for running wlanctl-ng
        wlanctl-ng $INTERFACE lnxreq_ifstate ifstate=enable
        # need to check if PROFILE_KEY exists, to know if we're using WEP or not
        if [ "$PROFILE_KEY" ] ; then
          # need to split the key into pairs
          A=1
          WLAN_KEY=""
          for ONE in 1 2 3 4 5
          do
            WLAN_KEY="$WLAN_KEY$(expr substr $PROFILE_KEY $A 2):"
            A=$((A+2))
          done
          WLAN_KEY=${WLAN_KEY%:}
          #WLANNG_CODE="$WLANNG_CODE
          wlanctl-ng $INTERFACE lnxreq_hostwep decrypt=true encrypt=true
          wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11PrivacyInvoked=true
          wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11WEPDefaultKeyID=0
          wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11ExcludeUnencrypted=true
          wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11WEPDefaultKey0=$WLAN_KEY
          #"
        fi
        ## Dougal: probably need to change PROFILE_SECURE to right format
        ## (I'm leaving it the same everywhere else -- so gui looks the same)
        case "$PROFILE_SECURE" in
         open) WLAN_SECURE="opensystem" ;;
         restricted) WLAN_SECURE="sharedkey" ;;
        esac
        #WLANNG_CODE="$WLANNG_CODE
        wlanctl-ng $INTERFACE lnxreq_autojoin ssid=$PROFILE_ESSID authtype=$WLAN_SECURE
        #"

        #echo "X"
        if [ "$XPID" ] ;then
          kill $XPID #>/dev/null 2>&1
          clean_up_gtkdialog NETWIZ_Connecting_DIALOG
        fi
        unset NETWIZ_Connecting_DIALOG
        _debug "useWlanctl:'$*' end"
        return 0
  #) | Xdialog --title "Puppy Ethernet Wizard" --progress "Saving profile" 0 0 3
} # end useWlanctl

#=============================================================================
# function to validate that the wpa_supplicant authentication process was successful.
# $1: interface name
# $2: XPID of gtkdialog progressbar (so we can check if the user clicked "abort")
# (times in wicd were 15, 3, 1 (sleep), +5 (if rescan) )
validateWpaAuthentication()
{
        _debug "validateWpaAuthentication:'$*' start"
        # Max time we wait for connection to complete (+1 since loop checks at start)
        local MAX_TIME='31'
        # The max time after starting in which we allow the status to be "DISCONNECTED"
        local MAX_DISCONNECTED_TIME=4
        START_TIME=$(date +%s)
        # The elapsed time since starting (calculated at the bottom of the loop)
        ELAPSED=0
        while [ "$ELAPSED" -lt $MAX_TIME ] ; do
                sleep 1
                # see if user aborted
                if [ "$2" ] ; then
                  pidof gtkdialog3 2>&1 |grep $Q -w "$2" || return 2
                fi
                # change to lower case, to make it more clear when displayed
                RESULT=$(wpa_cli -i "$1" status 2>>$DEBUG_OUTPUT |grep 'wpa_state=' | tr A-Z a-z |tr '_' ' ')
                [ "$RESULT" ] || return 3
                RESULT=${RESULT#*=}
                #echo "$RESULT"
                echo "${L_ECHO_Status_p1}${ELAPSED}${L_ECHO_Status_p2}${RESULT}"
                case $RESULT in
                  *completed*) return 0 ;;
                  *disconnected*)
                    if [ "$ELAPSED" -gt $MAX_DISCONNECTED_TIME ] ; then
                      # Force a rescan to get wpa_supplicant moving again.
                      # Dougal: explanation from wicd:
                      # This works around authentication validation sometimes failing for
                      # wpa_supplicant because it remains in a DISCONNECTED state for
                      # quite a while, after which a rescan is required, and then
                      # attempting to authenticate.  This whole process takes a long
                      # time, so we manually speed it up if we see it happening.
                      echo "forcing wpa_supplicant to rescan:" >>$DEBUG_OUTPUT
                      wpa_cli -i "$1" scan >>$DEBUG_OUTPUT 2>&1
                      MAX_TIME=$((MAX_TIME+5))
                      MAX_DISCONNECTED_TIME=$((MAX_DISCONNECTED_TIME+4))
                    fi
                    ;;
                esac
                # echo X for progress dialog
                #echo "X"
                #sleep 1
                ELAPSED=$(($(date +%s)-$START_TIME))
        done
        _debug "validateWpaAuthentication:'$*' end"
        return 1
} # end validateWpaAuthentication

#=============================================================================
useWpaSupplicant ()
{
        _debug "useWpaSupplicant:'$*' start"
        [ "$INTERFACE" ] || return 1
        # add an option for running some parts only from the wizard
        if [ "$1" = "wizard" ] ; then
                # Dougal: moved all below code to a function
                getWpaPSK || return 1
                # Dougal: make wpa_supplicant config file match mac address
                #WPA_CONF="${WPA_SUPP_DIR}/${PROFILE_AP_MAC}.${PROFILE_ENCRYPTION}.conf"
                WPA_CONF="${WPA_SUPP_DIR}/${PROFILE_AP_MAC}.${PROFILE_MODE}.${PROFILE_SECURE}.${PROFILE_ENCRYPTION}.conf"
                if [ ! -e "$WPA_CONF" ] ; then
                        # copy template
                        #cp $VERB -a "${WPA_SUPP_DIR}/wpa_supplicant$PROFILE_WPA_TYPE.conf" "$WPA_CONF"
                        # no, now this is done while saving, give message if failed
                        giveErrorDialog "$L_MESSAGE_No_Wpaconfig_p1
$WPA_CONF
$L_MESSAGE_No_Wpaconfig_p2"
                        return 1
                fi
                #TMPLOG="/tmp/wag-profiles_tmp.log"
                #rm "$TMPLOG" >> $DEBUG_OUTPUT 2>&1
                cleanUpInterface "$INTERFACE" >> $DEBUG_OUTPUT 2>&1
        else # running from rc.network
        WPA_CONF="$1"
        fi #if [ "$1" = "wizard" ] ; then
        # Dougal: give the text message even when using dialog (for debugging)
        echo "Configuring interface $INTERFACE to network $PROFILE_ESSID with wpa_supplicant..." >> $DEBUG_OUTPUT

        ###### run dialog
        if [ "$HAVEX" = "yes" ]; then
                # Create a temporary fifo to pass messages to progressbar (can't just pipe to it)
                PROGRESS_OUTPUT=/tmp/progress-fifo$$
                mkfifo $PROGRESS_OUTPUT
                # The progressbar dialog
                # It contains a loop that starts from 1 and increments by 3, so 1+33*3=100%
                # (33= first three messages + 30 iterations of loop in validate...)
                # If it recieves "end" it will skip to 100.
                echo "running NETWIZ_Scan_Progress_Dialog..."
                export NETWIZ_Scan_Progress_Dialog="<window title=\"$L_TITLE_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
  <text><label>\"${L_TEXT_WPA_Progress_p1}${PROFILE_ENCRYPTION}${L_TEXT_WPA_Progress_p2}${PROFILE_ESSID}${L_TEXT_WPA_Progress_p3}\"</label></text>
  <frame $L_FRAME_Progress>
      <progressbar>
      <label>Connecting</label>
      <input>i=1 ; while read bla ; do i=\$((i+3)) ; case \$bla in end) i=100 ;; esac ; echo \$i ;echo \"\$bla\" ; done</input>
      <action type=\"exit\">Ready</action>
    </progressbar>
  </frame>
  <hbox>
   <button>
     <label>$L_BUTTON_Abort</label>
     <input file icon=\"gtk-stop\"></input>
     <action>EXIT:Abort</action>
   </button>
  </hbox>
 </vbox>
</window>"
                gtkdialog3 --program=NETWIZ_Scan_Progress_Dialog <$PROGRESS_OUTPUT &
                local XPID=$!
        else
                PROGRESS_OUTPUT=$DEBUG_OUTPUT
        fi
        # Use a subshell to redirect echoes to fifo
        # (need one subshell, since redirecting something like a function will
        #+ freeze the progress bar when it ends)
        ####################################################################
        (
                echo "$L_ECHO_Starting"
                # Dougal: add increasing of rate for ath5k
                case $INTMODULE in ath5k*) iwconfig "$INTERFACE" rate 11M >> $DEBUG_OUTPUT 2>&1;; esac
                echo "$L_ECHO_Initializing_Wpa"
                wpa_supplicant -i "$INTERFACE" -D "$PROFILE_WPA_DRV" -c "$WPA_CONF" -B >> $DEBUG_OUTPUT 2>&1
                [ $? = 0 ] || echo end
                echo "Waiting for connection... " >> $DEBUG_OUTPUT 2>&1

                echo "trying to connect"
                # Dougal: use function based on wicd code
                # (note that it echoes the X's for the progress dialog)
                # have different return values:
                validateWpaAuthentication "$INTERFACE" "$XPID"
                case $? in
                 0) # success
                   #WPA_STATUS="COMPLETED"
                   echo "COMPLETED" >/tmp/wpa_status.txt
                   echo "completed" >> $DEBUG_OUTPUT
                   # end the progress bar
                   echo end
                   ;;
                 1) # timeout
                   echo "timeout" >> $DEBUG_OUTPUT
                   # end the progress bar
                   echo end
                   ;;
                 2) # user aborted
                   echo aborted >>$DEBUG_OUTPUT
                   ;;
                 3) # error
                   echo "error while running:" >>$DEBUG_OUTPUT
                   echo "wpa_cli -i $INTERFACE status | grep 'wpa_state=' " >>$DEBUG_OUTPUT
                   # end the progress bar
                   echo end
                   ;;
                esac

                # Dougal: close the -n above
                echo >> $DEBUG_OUTPUT 2>&1
                #echo "$WPA_STATUS" >/tmp/wpa_status.txt
                #echo "---" >> ${TMPLOG} 2>&1
        ) >>$PROGRESS_OUTPUT
        ####################################################################
  #| Xdialog --title "Puppy Ethernet Wizard" --progress "Acquiring WPA connection\n\nThere may be a delay up to 60 seconds." 0 0 20
        if [ "$XPID" ] ;then
          kill $XPID #>/dev/null 2>&1
          clean_up_gtkdialog NETWIZ_Scan_Progress_Dialog
        fi
        unset NETWIZ_Scan_Progress_Dialog
        ###########
        if [ "$HAVEX" = "yes" ]; then # it's a pipe
                rm $PROGRESS_OUTPUT
        fi
        #cat $TMPLOG >> $DEBUG_OUTPUT
        WPA_STATUS="$(cat /tmp/wpa_status.txt)"
        rm /tmp/wpa_status.txt

        if [ "$WPA_STATUS" = "COMPLETED" ] ; then
                return 0
        fi
        # if we're here, it failed
        if [ "$1" = "wizard" ] && [ "$HAVEX" = "yes" ] ; then
        echo "running NETWIZ_No_WPA_Connection_Dialog..."
                export NETWIZ_No_WPA_Connection_Dialog="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-dialog-error\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\"><input file stock=\"gtk-dialog-error\"></input></pixmap>
  <text>
    <label>\"$L_MESSAGE_WPA_Failed\"</label>
  </text>
  <hbox>
   <button ok></button>
   <button>
    <label>$L_BUTTON_Details</label>
    <input file icon=\"gtk-info\"></input>
    <action>EXIT:Details</action>
   </button>
  </hbox>
 </vbox>
</window>"

                I=$IFS; IFS=""
                for STATEMENT in  $(gtkdialog3 --program NETWIZ_No_WPA_Connection_Dialog); do
                        eval $STATEMENT
                done
                IFS=$I
                clean_up_gtkdialog NETWIZ_No_WPA_Connection_Dialog
                unset NETWIZ_No_WPA_Connection_Dialog
                if [ "$EXIT" = "Details" ] ; then
                  EXIT="Refresh"
                  while [ "$EXIT" = "Refresh" ] ; do
                    # iwconfig info
                    IW_INFO="$(iwconfig $INTERFACE |grep -o 'Access Point: .*\|Link Quality:[0-9]* ' )"
                    echo "running NETWIZ_WPA_Status_Dialog..."
                    export NETWIZ_WPA_Status_Dialog="<window title=\"$L_TITLE_Puppy_Network_Wizard\" icon-name=\"gtk-network\" window-position=\"1\">
 <vbox>
  <frame $L_FRAME_Connection_Info >
  <text>
    <label>\"$IW_INFO\"</label>
  </text>
  </frame>
  <frame ${L_FRAME_wpa_cli_Outeput}'wpa_cli -i $INTERFACE status' >
   <edit cursor-visible=\"false\" accepts-tab=\"false\">
    <variable>EDITOR</variable>
    <width>300</width><height>150</height>
    <default>\"$(wpa_cli -i $INTERFACE status 2>&1)\"</default>
   </edit>
  </frame>
  <hbox>
   <button>
    <label>$L_BUTTON_Refresh</label>
    <input file icon=\"gtk-refresh\"></input>
    <action>EXIT:Refresh</action>
   </button>
   <button ok></button>
  </hbox>
 </vbox>
</window>"
                    I=$IFS; IFS=""
                    for STATEMENT in  $(gtkdialog3 --program NETWIZ_WPA_Status_Dialog); do
                          eval $STATEMENT
                    done
                    IFS=$I
                  done # while [ "$EXIT" = "Refresh" ]
                  clean_up_gtkdialog NETWIZ_WPA_Status_Dialog
                  unset NETWIZ_WPA_Status_Dialog
                fi #if [ "$EXIT" = "Details" ] ; then
        fi #if [ "$1" = "wizard" ] && [ "$HAVEX" = "yes" ] ; then
        # if we're here, connection failed -- kill wpa_supplicant!
        wpa_cli -i "$INTERFACE" terminate >>$DEBUG_OUTPUT
        _debug "useWpaSupplicant:'$*' end"
        return 1
} # end useWpaSupplicant

#=============================================================================
checkIsPCMCIA(){
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
  IsPCMCIA=""
  if PciSlot=$(grep -F 'PCI_SLOT_NAME=' /sys/class/net/$INTERFACE/device/uevent) ; then
    if [ -d /sys/class/pcmcia_socket/pcmcia_socket[0-9]/device/${PciSlot#PCI_SLOT_NAME=} ]
        then  IsPCMCIA=yes
    fi
  fi
}

#=============================================================================
waitForPCMCIA(){
        # see if this is a pcmcia device at all
        #grep $Q "^pcmcia:" /sys/class/net/$INTERFACE/device/modalias || return
        #case $INTMODULE in *_cs) ;; *) return ;; esac
        _debug "running NETWIZ_Wait_For_PCMCIA_Dialog..."
        export NETWIZ_Wait_For_PCMCIA_Dialog="<window title=\"$L_TITLE_Network_Wizard\" window-position=\"1\">
 <progressbar>
  <label>\"$L_PROGRESS_Waiting_For_PCMCIA\"</label>
  <input>i=0 ; while read bla ; do i=\$((i+20)) ; echo \$i ; done</input>
  <action type=\"exit\">Ready</action>
 </progressbar>
</window>"

        for i in 1 2 3 4 5 ; do
                sleep 1
                echo X
        done | gtkdialog3 --program=NETWIZ_Wait_For_PCMCIA_Dialog #>/dev/null
        clean_up_gtkdialog NETWIZ_Wait_For_PCMCIA_Dialog
} # end of waitForPCMCIA

#=============================================================================
showScanWindow()
{
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
        # do the cleanup here, so devices have a chance to "settle" before scanning
        cleanUpInterface "$INTERFACE" >> $DEBUG_OUTPUT 2>&1
        sleep 1
        checkIsPCMCIA # sets IsPCMCIA
        # Dougal: this replaces Xdialog at the end of the subshells in Build*ScanWindow
        echo "running NETWIZ_Scan_Progress_Dialog..."
        export NETWIZ_Scan_Progress_Dialog="<window title=\"$L_TITLE_Network_Wizard\" window-position=\"1\">
 <progressbar>
  <label>\"$L_PROGRESS_Scanning_Wireless\"</label>
  <input>i=1 ; while read bla ; do i=\$((i+33)) ; echo \$i ; done</input>
  <action type=\"exit\">Ready</action>
 </progressbar>
</window>"

        # add waiting for pcmcia to "settle"...
        [ -n "$IsPCMCIA" ] && waitForPCMCIA
        if [ "$USE_WLAN_NG" = "yes" ] ; then
          buildPrismScanWindow
        else
          buildScanWindow
        fi

        SCANWINDOW_RESPONSE="$(sh /tmp/net-setup_scanwindow)"
        # add support for trying again with pcmcia cards
        case $? in
         101)
          pccardctl eject
          pccardctl insert
          [ -n "$IsPCMCIA" ] && waitForPCMCIA
          if [ "$USE_WLAN_NG" = "yes" ] ; then
            buildPrismScanWindow retry
          else
            buildScanWindow retry
          fi
          SCANWINDOW_RESPONSE="$(sh /tmp/net-setup_scanwindow)"
          ;;
         111)
          [ -n "$IsPCMCIA" ] && waitForPCMCIA
          if [ "$USE_WLAN_NG" = "yes" ] ; then
            buildPrismScanWindow retry
          else
            buildScanWindow retry
          fi
          SCANWINDOW_RESPONSE="$(sh /tmp/net-setup_scanwindow)"
          ;;
        esac

        unset NETWIZ_Scan_Progress_Dialog

        CELL=$(echo "$SCANWINDOW_RESPONSE" | grep -Eo "[0-9]+")

        [ -n "$CELL" ] && setupScannedProfile

} # end of showScanWindow

#=============================================================================
# $1 might be "retry", to let us know we've already tried once...
buildScanWindow()
{
        _debug "buildScanWindow:'$*' INTERFACE='$INTERFACE' start"
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
        SCANWINDOW_BUTTONS=""

        (

                ifconfig "$INTERFACE" up >>$DEBUG_OUTPUT 2>&1
                #cleanUpInterface "$INTERFACE" >>$DEBUG_OUTPUT 2>&1

                #  Dougal: use files for the scan results, so we can try a few times
                #+ and see which is biggest (sometimes not all networks show)
                rm -f /tmp/net-setup_scan*.tmp >$OUT 2>&1

                iwlist "$INTERFACE" scan >/tmp/net-setup_scan1.tmp 2>>$DEBUG_OUTPUT
                echo "X"

                SCANALL=$(iwlist "$INTERFACE" scan 2>>$DEBUG_OUTPUT)
                sleep 1

                iwlist "$INTERFACE" scan >/tmp/net-setup_scan2.tmp 2>>$DEBUG_OUTPUT
                echo "X"

                ScanListFile=$(du -b /tmp/net-setup_scan*.tmp |sort -n | tail -n1 |cut -f2)
                echo "ScanListFile='$ScanListFile'" >&2

                # Dougal: if nothing found, try again!
                # (put the retry here, so progress is more even in bar...)
                #case "$SCANALL" in *'No scan results'*)
                #if grep -Fq 'No scan results' $ScanListFile ; then
                #  sleep 1
                  #SCANALL=$(iwlist "$INTERFACE" scan 2>>$DEBUG_OUTPUT)
                #  iwlist "$INTERFACE" scan >/tmp/net-setup_scan3.tmp 2>>$DEBUG_OUTPUT
                #  ScanListFile="/tmp/net-setup_scan3.tmp"
                  #;;
                #esac
                #fi

                SCAN_LIST=$(echo "$SCANALL" | grep 'Cell\|ESSID\|Mode\|Frequency\|Quality\|Encryption\|Channel\|IE:\|Extra:')
                echo "$SCAN_LIST" >/tmp/net-setup_scanlist

                echo "$ScanListFile" >/tmp/net-setup_scanlistfile

                CELL_LIST=$(grep -Eo "Cell [0-9]+" "$ScanListFile" | cut -f2 -d " ")
                #CELL_LIST=$(grep -Eo "Cell [0-9]+" /tmp/net-setup_scanlist | cut -f2 -d " ")
                echo "CELL_LIST='$CELL_LIST'" >&2

                #if [ -z "$SCAN_LIST" ]; then
                if [ -z "$CELL_LIST" ]; then
                echo "CELL_LIST no content" >&2
                        # Dougal: a little awkward... want to give an option to reset pcmcia card
                        FI_DRIVER=$(readlink /sys/class/net/$INTERFACE/device/driver)
                        if [ "$1" = "retry" ] ; then # we're on the second try already
                                echo "Running createNoNetworksDialog" >&2
                                createNoNetworksDialog
                        #       echo "Xdialog --left --title \"Puppy Network Wizard:\" \
                        # --msgbox \"No networks detected\" 0 0 " >/tmp/net-setup_scanwindow
                        # cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_buildScanWindow
                        elif [ -n "$IsPCMCIA" ] ; then
                                echo "Running createRetryPCMCIAScanDialog" >&2
                                createRetryPCMCIAScanDialog
                        else
                                echo "Running createRetryScanDialog" >&2
                                createRetryScanDialog
                        fi
                else
                _notice "CELL_LIST not zero"
                        # give each Cell its own button
                        #CELL_LIST=$(echo "$SCAN_LIST" | grep -Eo "Cell [0-9]+" | cut -f2 -d " ")
                        for CELL in $CELL_LIST ; do
                                _info "CELL='$CELL'"
                                #getCellParameters $CELL
                                Get_Cell_Parameters $CELL
                                [ -z "$CELL_ESSID" ] && CELL_ESSID="(hidden ESSID)"
# build list
#                                if test "$SCANWINDOW_BUTTONS"; then SCANWINDOW_BUTTONS="$SCANWINDOW_BUTTONS \\
#\"$CELL\" \"$CELL_ESSID (${CELL_MODE}; ${L_SCANWINDOW_Encryption}$CELL_ENC_TYPE)\" off \"${L_SCANWINDOW_Channel}${CELL_CHANNEL}; ${L_SCANWINDOW_Frequency}${CELL_FREQ}; ${L_SCANWINDOW_AP_MAC}${CELL_AP_MAC}; ${L_SCANWINDOW_Strength}${CELL_QUALITY}\""
#else SCANWINDOW_BUTTONS="\"$CELL\" \"$CELL_ESSID (${CELL_MODE}; ${L_SCANWINDOW_Encryption}$CELL_ENC_TYPE)\" off \"${L_SCANWINDOW_Channel}${CELL_CHANNEL}; ${L_SCANWINDOW_Frequency}${CELL_FREQ}; ${L_SCANWINDOW_AP_MAC}${CELL_AP_MAC}; ${L_SCANWINDOW_Strength}${CELL_QUALITY}\""
#				fi
# build list and sort
SCANWINDOW_BUTTONS="$SCANWINDOW_BUTTONS
\"$CELL\" \"$CELL_ESSID (${CELL_MODE}; ${L_SCANWINDOW_Encryption}$CELL_ENC_TYPE)\" off \"${L_SCANWINDOW_Channel}${CELL_CHANNEL}; ${L_SCANWINDOW_Frequency}${CELL_FREQ}; ${L_SCANWINDOW_AP_MAC}${CELL_AP_MAC}; ${L_SCANWINDOW_Strength}${CELL_QUALITY}\""
                        done
echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.0.lst
#SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | rev`
#echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.1.lst
#SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | sort -n -k1 -t':'`
#echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.2.lst
#SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | rev`
#echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.3.lst
#SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | sort -d -k2,3 -t' '` # sort by NAME
SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | /bin/sort -d -r -k5,6 -t';'`  # sort by strength
echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.1.lst
SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | sed '/^$/d'`
echo "$SCANWINDOW_BUTTONS" >/tmp/cell_scan_list.lst
SCANWINDOW_BUTTONS=`echo "$SCANWINDOW_BUTTONS" | sed 's/$/ \\\/'`

                        echo "Xdialog --left --item-help --stdout --title \"$L_TITLE_Puppy_Network_Wizard\" \
                    --radiolist \"$L_TEXT_Scanwindow\"  20 60 4  \
        ${SCANWINDOW_BUTTONS}
        2>$ERR" >/tmp/net-setup_scanwindow
        cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_buildScanWindow
                fi
                echo "X"
        )  | gtkdialog3 --program=NETWIZ_Scan_Progress_Dialog #>/dev/null
        clean_up_gtkdialog NETWIZ_Scan_Progress_Dialog

        #Xdialog --title "Puppy Ethernet Wizard" --progress "Scanning wireless networks" 0 0 3

        SCAN_LIST="$(cat /tmp/net-setup_scanlist)"
        read ScanListFile < /tmp/net-setup_scanlistfile
        # run ifconfig down/up, as apparently it is needed for actually configuring to work properly...
        ifconfig "$INTERFACE" down
        _debug "buildScanWindow:'$*' `date` $LINENO"
        ifconfig "$INTERFACE" up
        _debug "buildScanWindow:'$*' `date` $LINENO"
} #end of buildScanWindow

#=============================================================================
createNoNetworksDialog()
{
_debug "creating NETWIZ_SCAN_ERROR_DIALOG..."
cat >/tmp/net-setup_scanwindow <<EoI
clean_up_gtkdialog(){
 [ "\$1" ] || return
 for I in \$(/bin/ps -eo pid,command | grep "\$1" | grep -v grep | grep -F "gtkdialog3" | cut -d" " -f1)
 do kill \$I
 done
}

export NETWIZ_SCAN_ERROR_DIALOG='<window title="$L_TITLE_Puppy_Network_Wizard" icon-name="gtk-dialog-warning" window-position="1">
 <vbox>
  <pixmap icon_size="6">
      <input file stock="gtk-dialog-warning"></input>
    </pixmap>
  <text>
    <label>"$L_TEXT_No_Networks_Detected"</label>
  </text>
  <hbox>
    <button ok></button>
  </hbox>
 </vbox>
</window>'

gtkdialog3 --program NETWIZ_SCAN_ERROR_DIALOG
clean_up_gtkdialog NETWIZ_SCAN_ERROR_DIALOG
exit 0
EoI
cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_createNoNetworksDialog
}

#=============================================================================
createRetryScanDialog(){
_debug "creating NETWIZ_SCAN_ERROR_DIALOG..."
cat >/tmp/net-setup_scanwindow <<EoI
clean_up_gtkdialog(){
 [ "\$1" ] || return
 for I in \$(/bin/ps -eo pid,command | grep "\$1" | grep -v grep | grep -F "gtkdialog3" | cut -d" " -f1)
 do kill \$I
 done
}

export NETWIZ_SCAN_ERROR_DIALOG='<window title="$L_TITLE_Puppy_Network_Wizard" icon-name="gtk-dialog-warning" window-position="1">
 <vbox>
  <pixmap icon_size="6">
      <input file stock="gtk-dialog-warning"></input>
    </pixmap>
  <text>
    <label>"$L_TEXT_No_Networks_Retry"</label>
  </text>
  <hbox>
    <button>
      <label>"$L_BUTTON_Retry"</label>
      <input file stock="gtk-redo"></input>
      <action>EXIT:retry</action>
    </button>
    <button cancel></button>
  </hbox>
 </vbox>
</window>'

I=\$IFS; IFS=""
for STATEMENT in \$(gtkdialog3 --program NETWIZ_SCAN_ERROR_DIALOG); do
        eval \$STATEMENT
done
IFS=\$I
clean_up_gtkdialog NETWIZ_SCAN_ERROR_DIALOG

case \$EXIT in
Cancel) exit 0 ;;
retry) exit 111 ;;
esac
EoI
cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_createRetryScanDialog
}

#=============================================================================
_createRetryPCMCIAScanDialog(){
_debug "creating NETWIZ_SCAN_ERROR_DIALOG..."
  echo 'clean_up_gtkdialog(){
 [ "$1" ] || return
 for I in $(/bin/ps -eo pid,command | grep "$1" | grep -v grep | grep -F "gtkdialog3" | cut -d" " -f1)
 do kill $I
 done
}

export NETWIZ_SCAN_ERROR_DIALOG="<window title=\"'"$L_TITLE_Puppy_Network_Wizard"'\" icon-name=\"gtk-dialog-warning\" window-position=\"1\">
 <vbox>
  <pixmap icon_size=\"6\">
      <input file stock=\"gtk-dialog-warning\"></input>
    </pixmap>
  <text>
    <label>\"'"$L_TEXT_No_Networks_Retry_Pcmcia"'\"</label>
  </text>
  <hbox>
    <button>
      <label>'"$L_BUTTON_Retry"'</label>
      <input file stock=\"gtk-redo\"></input>
      <action>EXIT:retry</action>
    </button>
    <button cancel></button>
  </hbox>
 </vbox>
</window>"

I=$IFS; IFS=""
for STATEMENT in  $(gtkdialog3 --program NETWIZ_SCAN_ERROR_DIALOG); do
        eval $STATEMENT
done
IFS=$I
clean_up_gtkdialog NETWIZ_SCAN_ERROR_DIALOG

case $EXIT in
Cancel) exit 0 ;;
retry) exit 101 ;;
esac
' >/tmp/net-setup_scanwindow
cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow__createRetryPCMCIAScanDialog
}

createRetryPCMCIAScanDialog(){
_debug "creating NETWIZ_SCAN_ERROR_DIALOG..."
cat >/tmp/net-setup_scanwindow <<EoI
clean_up_gtkdialog(){
 [ "\$1" ] || return
 for I in $(/bin/ps -eo pid,command | grep "\$1" | grep -v grep | grep -F "gtkdialog3" | cut -d" " -f1)
 do kill \$I
 done
}

export NETWIZ_SCAN_ERROR_DIALOG='<window title="$L_TITLE_Puppy_Network_Wizard" icon-name="gtk-dialog-warning" window-position="1">
 <vbox>
  <pixmap icon_size="6">
      <input file stock="gtk-dialog-warning"></input>
    </pixmap>
  <text>
    <label>"$L_TEXT_No_Networks_Retry_Pcmcia"</label>
  </text>
  <hbox>
    <button>
      <label>"$L_BUTTON_Retry"</label>
      <input file stock="gtk-redo"></input>
      <action>EXIT:retry</action>
    </button>
    <button cancel></button>
  </hbox>
 </vbox>
</window>'

I=\$IFS; IFS=""
for STATEMENT in \$(gtkdialog3 --program NETWIZ_SCAN_ERROR_DIALOG); do
        eval \$STATEMENT
done
IFS=\$I
clean_up_gtkdialog NETWIZ_SCAN_ERROR_DIALOG

case \$EXIT in
Cancel) exit 0 ;;
retry) exit 101 ;;
esac
EoI
cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_createRetryPCMCIAScanDialog
}

#=============================================================================
# Dougal: put this into a function, so we can use it at boot time
# (note that it echoes Xs for the progress bar)
runPrismScan()
{
        _debug "runPrismScan:'$*' start"
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
        # enable interface
        wlanctl-ng "$INTERFACE" lnxreq_ifstate ifstate=enable >/tmp/wlan-up 2>&1
        # scan (first X echoed only afterwards!
        wlanctl-ng "$INTERFACE" dot11req_scan bsstype=any \
         bssid=ff:ff:ff:ff:ff:ff ssid="" scantype=both \
          channellist="00:01:02:03:04:05:06:07:08:09:0a:0b:00:00" \
           minchanneltime=200 maxchanneltime=250 >/tmp/prism-scan-all #2>/dev/null
        echo "X"
        # get number of access points (make sure we get integer)
        POINTNUM=$(grep -F 'numbss=' /tmp/prism-scan-all 2>$ERR | cut -d= -f2 | grep [0-9])
        rm /tmp/prism-scan-all #>/dev/null 2>&1
        ## Dougal: not sure about this -- need a way to make sure we get something
        #if grep -F 'resultcode=success' /tmp/prism-scan-all ; then
        if [ "$POINTNUM" ] ; then
          # get scan results for all access points
          for P in $(seq 0 $POINTNUM)
          do
            wlanctl-ng "$INTERFACE" dot11req_scan_results bssindex=$P >/tmp/prism-scan$P #2>/dev/null
          done
          echo "X"
        else # let us know it failed
_debug "runPrismScan:'$*' end 1"
          return 1
        fi
_debug "runPrismScan:'$*' end 0"
        return 0
} # end runPrismScan

#=============================================================================
buildPrismScanWindow()
{
        _debug "buildPrismScanWindow:'$*' start"
	INTERFACE=${INTERFACE:-"$1"}
	[ "$INTERFACE" ] || return 1
	SCANWINDOW_BUTTONS=""
  (
        # do a cleanup first (raises interface, so need to put it down after)
        cleanUpInterface "$INTERFACE" >> $DEBUG_OUTPUT 2>&1
        ifconfig "$INTERFACE" down
        if runPrismScan "$INTERFACE" ; then
          # create buttons (POINTNUM set in function)
          for P in $(seq 0 $POINTNUM)
          do
            grep -Fq 'resultcode=success' /tmp/prism-scan$P || continue
            getPrismCellParameters $P
            [ "$CELL_ESSID" ] || CELL_ESSID="$L_SCANWINDOW_Hidden_SSID"
                # might add test here for some params, then maybe skip
                SCANWINDOW_BUTTONS="${SCANWINDOW_BUTTONS}
                \"$P\" \"${CELL_ESSID} (${CELL_MODE}; ${L_SCANWINDOW_Encryption}${CELL_ENCRYPTION})\" off \"${L_SCANWINDOW_Channel}${CELL_CHANNEL}; ${L_SCANWINDOW_AP_MAC}${CELL_AP_MAC}\""
          done
        else
          echo "X"
        fi
        if [ "$SCANWINDOW_BUTTONS" ] ; then
                echo "Xdialog --left --item-help --stdout --title \"$L_TITLE_Puppy_Network_Wizard\" \
                --radiolist \"$L_TEXT_Prism_Scan\"  20 60 4  \
        ${SCANWINDOW_BUTTONS} 2>$ERR" >/tmp/net-setup_scanwindow
        cp /tmp/net-setup_scanwindow /tmp/net-setup_scanwindow_buildPrismScanWindow
        else
          #echo "Xdialog --left --title \"Puppy Network Wizard:\" --msgbox \"No networks detected\" 0 0 " >/tmp/net-setup_scanwindow
          if [ "$1" = "retry" ] ; then # we're on the second try already
                createNoNetworksDialog
          elif [ -n "$IsPCMCIA" ] ; then
                createRetryPCMCIAScanDialog
          else
                createRetryScanDialog
          fi
        fi
        echo "X"
  )  | gtkdialog3 --program=NETWIZ_Scan_Progress_Dialog #>/dev/null
        # clean up
        clean_up_gtkdialog NETWIZ_Scan_Progress_Dialog
_debug "buildPrismScanWindow:'$*' end"
} #end of buildPrismScanWindow

#=============================================================================
setupScannedProfile()
{
        _debug "setupScannedProfile:'$*' start"
        setupNewProfile
        if [ "$USE_WLAN_NG" = "yes" ] ; then
          getPrismCellParameters $CELL
          # clean up from earlier
          rm -f /tmp/prism-scan*
        else
          #getCellParameters $CELL
          Get_Cell_Parameters $CELL
        fi
        # Dougal: setupNewProfile always sets PROFILE_MODE to "ad-hoc"!
        case "$CELL_MODE" in
          Managed|infrastructure) PROFILE_MODE="managed" ;;
          Ad-Hoc) PROFILE_MODE="ad-hoc" ;;
        esac
        PROFILE_ESSID="$CELL_ESSID"
        PROFILE_TITLE="$CELL_ESSID"
        PROFILE_FREQ="$CELL_FREQ"
        PROFILE_CHANNEL="$CELL_CHANNEL"
        PROFILE_AP_MAC="$CELL_AP_MAC"

        case $CELL_ENCRYPTION in
          on|true) PROFILE_KEY="$L_TEXT_Provide_Key" ;;
          *) PROFILE_KEY="" ;;
        esac
        # Dougal: add this, so it defaults to "broadcast SSID" if we have an SSID...
        # add always using 2 with ndiswrapper
        if [ -n "$PROFILE_ESSID" -a "$INTMODULE" != "ndiswrapper" ] ;then
          PROFILE_WPA_AP_SCAN="1"
        else
          PROFILE_WPA_AP_SCAN="2"
        fi
        _debug "setupScannedProfile:'$*' end"
} # end of setupScannedProfile

#=============================================================================
getCellParameters()
{
        _debug "getCellParameters:'$*' start"
        CELL=$1
        #SCAN_CELL=`echo "$SCAN_LIST" | grep -F -A5 "Cell ${CELL}"`
        # Dougal: try and get exactly everything matching our cell
        START=$(echo "$SCAN_LIST" | grep -F -n "Cell $CELL" |cut -d: -f1)
        NEXT=$(expr $CELL + 1)
        [ ${#NEXT} -lt 2 ] && NEXT="0$NEXT"
        END=$(echo "$SCAN_LIST" | grep -F -n "Cell $NEXT" |cut -d: -f1)
        # there might not be one...
        if [ "$END" ] ; then
          END=$((END-1))
        else
          END=$(echo "$SCAN_LIST" | wc -l)
        fi
         SCAN_CELL=$(echo "$SCAN_LIST" | sed -n "${START},${END}p")
        CELL_ESSID=$(echo "$SCAN_CELL" | grep -E -o 'ESSID:".+"' | grep -E -o '".+"' | grep -E -o '[^"]+')
        [ "$CELL_ESSID" = "<hidden>" ] && CELL_ESSID=""
           CELL_FREQ=$(echo "$SCAN_CELL" | grep "Frequency" | grep -Eo '[0-9]+\.[0-9]+ +G' | sed -e 's/ G/G/')
        CELL_CHANNEL=$(echo "$SCAN_CELL" | grep "Frequency" | grep -Eo 'Channel [0-9]+' | cut -f2 -d" ")
        CELL_CHANNEL=${CELL_CHANNEL:-$(echo "$SCAN_CELL" | grep -F 'Channel:' | grep -Eo [0-9]+)}
        # Dougal: below was 'cut -d":" -f2-'
           CELL_QUALITY=$(echo "$SCAN_CELL" | grep 'Quality=' | cut -d'=' -f2 | cut -d' ' -f1)
        CELL_QUALITY=${CELL_QUALITY:-$(echo "$SCAN_CELL" | grep "Quality" | tr -s ' ')}
            CELL_AP_MAC=$(echo "$SCAN_CELL" | grep -E -o '[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}')
              CELL_MODE=$(echo "$SCAN_CELL" | grep -o 'Mode:Managed\|Mode:Ad-Hoc\|Mode:Master' | cut -d":" -f2)
        CELL_ENCRYPTION=$(echo "$SCAN_CELL" | grep -F 'Encryption key:' | cut -d: -f2 | tr -d ' ')
        CELL_ENC_TYPE="$CELL_ENCRYPTION"

	__set_enc_type__(){
        # comment out all below code: IE: output isn't reliable (reports WPA as WPA2 at times)
        # Dougal: add this to let the user know the type of encryption
        CELL_ENC_TYPE=$(echo "${SCAN_CELL}" | grep -F 'IE: ') # | grep -o 'WPA2\|WPA')
        # Need to also check for wpa_ie/rsn_ie
        if [ "$CELL_ENCRYPTION" = "on" ] ;then
          if [ "$CELL_ENC_TYPE" ] ; then # IE: might appear twice: with WPA and WPA2...
            case "$CELL_ENC_TYPE" in
              *WPA2*) CELL_ENC_TYPE="WPA2" ;;
              *WPA*) CELL_ENC_TYPE="WPA" ;;
              *) CELL_ENC_TYPE="on" ;; # this just in case...
            esac
          else
            CELL_ENC_TYPE=$(echo "${SCAN_CELL}" | grep -F 'Extra:')
            case "$CELL_ENC_TYPE" in
              *Extra:rsn_ie*) CELL_ENC_TYPE="WPA2" ;;
              *Extra:wpa_ie*) CELL_ENC_TYPE="WPA" ;;
              *) CELL_ENC_TYPE="WEP" ;; #else it's wep
            esac
          fi
        else
          CELL_ENC_TYPE="off"
        fi
	}

_debug "getCellParameters:'$*' end"
} # end of getCellParameters

#=============================================================================
# a modified version of the above, that uses a file rather than SCAN_LIST
## it sexpects the variable ScanListFile to be set (file containing scan output)
Get_Cell_Parameters()
{
        _debug "Get_Cell_Parameters:'$*' start"
        #CELL=$1
        #SCAN_CELL=`echo "$SCAN_LIST" | grep -F -A5 "Cell ${CELL}"`
        # Dougal: try and get exactly everything matching our cell
        #START=$(echo "$SCAN_LIST" | grep -F -n "Cell $CELL" |cut -d: -f1)

        START=$(grep -F -n "Cell $1" $ScanListFile |cut -d: -f1)
        #NEXT=$(expr $CELL + 1)
    # remove the 0 from the cell number, so the shell won't think it's hex or something
        case $1 in
         0[1-9]) Acell=${1#0} ;;
         *) Acell=$1 ;;
        esac
        NEXT=$((Acell+1))
        [ ${#NEXT} -lt 2 ] && NEXT="0$NEXT"
        #END=$(echo "$SCAN_LIST" | grep -F -n "Cell $NEXT" |cut -d: -f1)
        END=$(grep -F -n "Cell $NEXT" $ScanListFile |cut -d: -f1)
        # there might not be one...
        if [ -n "$END" ] ; then
          END=$((END-1))
        else
          END=$(wc -l $ScanListFile | awk '{print $1}')
        fi
        #SCAN_CELL=$(echo "$SCAN_LIST" | sed -n "${START},${END}p")
         SCAN_CELL=$(sed -n "${START},${END}p" $ScanListFile)
        CELL_ESSID=$(echo "$SCAN_CELL" | grep -E -o 'ESSID:".+"' | grep -E -o '".+"' | grep -E -o '[^"]+')
        [ "$CELL_ESSID" = "<hidden>" ] && CELL_ESSID=""
           CELL_FREQ=$(echo "$SCAN_CELL" | grep "Frequency" | grep -Eo '[0-9]+\.[0-9]+ +G' | sed -e 's/ G/G/')
        CELL_CHANNEL=$(echo "$SCAN_CELL" | grep "Frequency" | grep -Eo 'Channel [0-9]+' | cut -f2 -d" ")
        CELL_CHANNEL=${CELL_CHANNEL:-$(echo "$SCAN_CELL" | grep -F 'Channel:' | grep -Eo [0-9]+)}
        # Dougal: below was 'cut -d":" -f2-'
           CELL_QUALITY=$(echo "$SCAN_CELL" | grep 'Quality=' | cut -d'=' -f2 | cut -d' ' -f1)
        CELL_QUALITY=${CELL_QUALITY:-$(echo "$SCAN_CELL" | grep "Quality" | tr -s ' ')}
            CELL_AP_MAC=$(echo "$SCAN_CELL" | grep -E -o '[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}')
              CELL_MODE=$(echo "$SCAN_CELL" | grep -o 'Mode:Managed\|Mode:Ad-Hoc\|Mode:Master' | cut -d":" -f2)
        CELL_ENCRYPTION=$(echo "$SCAN_CELL" | grep -F 'Encryption key:' | cut -d: -f2 | tr -d ' ')
        CELL_ENC_TYPE="$CELL_ENCRYPTION"
_debug "Get_Cell_Parameters:'$*' end"
} # end of Get_Cell_Parameters

#=============================================================================
getPrismCellParameters()
{
        _debug "getPrismCellParameters:'$*' start"
        CELL=$1
          CELL_ESSID=$(grep -F 'ssid='      /tmp/prism-scan$CELL | grep -v 'bssid=' | cut -d"'" -f2)
        CELL_CHANNEL=$(grep -F 'dschannel=' /tmp/prism-scan$CELL | cut -d= -f2)
        ## Dougal: not sure about this: maybe skip ones without anything?
         CELL_AP_MAC=$(grep -F 'bssid=' /tmp/prism-scan$CELL | cut -d= -f2 | grep -E  '[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}')
        ## Dougal: might need to do something to fit this to checkboxes
           CELL_MODE=$(grep -F 'bsstype='    /tmp/prism-scan$CELL | cut -d= -f2)
        ## Dougal: maybe do something with "no_value"
        CELL_ENCRYPTION=$(grep -F 'privacy=' /tmp/prism-scan$CELL | cut -d= -f2)
        _debug "getPrismCellParameters:'$*' end"
} # end of getPrismCellParameters

#=============================================================================
#=============== START OF SCRIPT BODY ====================
#=============================================================================

# If ran by itself it shows the interface, Otherwise it's only used as a function library
CURRENT_CONTEXT=$(expr "$0" : '.*/\(.*\)$' )
if [ "${CURRENT_CONTEXT}" = "wag-profiles.sh" ] ; then
	#test "$1" || _exit 1 "Need network INTERFACE ( wlan0, ra0, ..) as parameter."
        INTERFACE=${INTERFACE:-"$1"}
	#[ "$INTERFACE" ] || { _notice "No parameter, defaulting to wlan0"; INTERFACE=wlan0; }

        MAYBE_WIRELESS=`iwconfig 2>&1| grep -vi 'no wireless extensions' | sed '/^[[:blank:]]*$/d ; /^$/d ; s/"//g'`
        INTERFACE=${INTERFACE:-`echo "$MAYBE_WIRELESS" | grep '^[[:alnum:]]\+' | awk '{print $1}' | head -n1`}
        [ "$INTERFACE" ] || { _notice "No active wireless, defaulting to wlan0"; INTERFACE=wlan0; }
	_debug "INTERFACE='$INTERFACE'"

	if test "$DISPLAY" && pidof X >>$OUT; then
	HAVEX=${HAVEX:-yes}
	fi
        DEBUG_OUTPUT="/dev/stderr"
        SHORT_LANG="${LANG%%_*}"
        if [ -f /usr/share/locale/$SHORT_LANG/LC_MESSAGES/net-setup.mo ] ; then
        . /usr/share/locale/$SHORT_LANG/LC_MESSAGES/net-setup.mo
        elif [ -f /usr/share/locale/en/LC_MESSAGES/net-setup.mo ] ; then
        . /usr/share/locale/en/LC_MESSAGES/net-setup.mo
        else
        echo "$0: Need net-setup.mo in /usr/share/locale/*/LC_MESSAGES/ ."
        echo "Please install net_setup-20111016.pet or net_setup-20121101.pet"
        echo "from ftp://ftp.nluug.nl/mirror/ibiblio/distributions/quirky/pet_packages-noarch/ ."
        exit 1
        fi
while :; do
        showProfilesWindow "$INTERFACE"
	case $? in
	255) break;; #Cancel or back button
	esac
done
fi
#DEBUG_OUTPUT="/dev/stdout"
DEBUG_OUTPUT="/dev/stderr"
DEBUG_OUTPUT=${DEBUG_OUTPUT:-"/dev/null"}

#=============================================================================
#=============== END OF SCRIPT BODY ====================
#=============================================================================

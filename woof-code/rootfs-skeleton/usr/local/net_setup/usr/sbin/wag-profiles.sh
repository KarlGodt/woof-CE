# This function library is a descendant of the Wifi Access Gadget
# created by Keenerd. It went to several modifications to finally 
# be fully integrated into the ethernet/network wizard.

# History of wag-profiles
# Dougal: port to gtkdialog3 and add icons
# Update: July 4th (rearrange the main window, add disabling of WPA button)
# Update: July 13th (add usage of wlanctl for prism2_usb module)
# Update: July 17th (fix broken pipe when running /tmp/wag-profiles_iwconfig.sh)
# Update: July 29th (split iwconfig commands into multiple lines, add security option)
# Update: July 31th (add security and scanning for prism2_usb)
# Update: August 1st (add usage of the scanned cell mode -- used to be ignored)
# Update: August 17th (fixed problem with "<hidden>" essid in WPA and made some improvements to parsing scan results)
# Update: August 21st (add WPA2 code)
# Update: August 23rd (fixed missing WPA2 instance)
# v3.95 1 jan 2008: bugfixes.
# v3.98 14 mar 2008: bugfix by 'urban soul', see also /etc/WAG/profile-conf.
#v4.00 tempestuous may08: wpa -D params for 2.6.25 kernel modules.
#v411 hack fix path. /usr/local/net_setup

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


## Dougal: put this into a variable
BLANK_IMAGE=/usr/share/pixmaps/net-setup_btnsize.png

#=============================================================================
showProfilesWindow()
{
	INTERFACE=$1
	# Dougal: find driver and set WPA driver from it
	INTMODULE=`readlink /sys/class/net/$INTERFACE/device/driver`
    INTMODULE=${INTMODULE##*/}
    #v4.00 tempestuous: 2.6.25 modules added
    # ath5k|b43|b43legacy|iwl3945|iwl4965|rndis_wlan|rt61pci|rt73usb for wext...
	case "$INTMODULE" in 
	 hostap*) PROFILE_WPA_DRV="hostap" ;;
	 rt61|rt73) PROFILE_WPA_DRV="ralink" ;;
	 bcm43xx|ipw2100|ipw2200|ipw3945|ath_pci|ndiswrapper|zd1211|zd1211b|zd1211rw|ath5k|b43|b43legacy|iwl3945|iwl4965|rndis_wlan|rt61pci|rt73usb) PROFILE_WPA_DRV="wext" ;;
	 r8180|r8187|rtl8180|rtl8187) PROFILE_WPA_DRV="ipw" ;;
	 *) # doesn't support WPA encryption
	   Xdialog --wrap --title "Wireless interface configuration" --msgbox "Note: The interface you have selected uses the module $INTMODULE,\nwhich does not support WPA encryption." 0 0
	   PROFILE_WPA_DRV="" ;;
	esac
	
	# Dougal: add usage of wlan-ng, for prism2_usb module
	case "$INTMODULE" in prism2_*) USE_WLAN_NG="yes" ;; esac
	
	refreshProfilesWindowInfo
	setupNewProfile
	EXIT=""
	while true
	do

		buildProfilesWindow

		I=$IFS; IFS=""
		for STATEMENTS in  $(gtkdialog3 --program Puppy_Network_Setup); do
			eval $STATEMENTS
		done
		IFS=$I
		unset Puppy_Network_Setup

		case "$EXIT" in
			"abort" | "19" ) # Back or close window
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
				saveProfiles
				refreshProfilesWindowInfo
				loadProfileData "${CURRENT_PROFILE}"
				;;
			"21" ) # Delete
				NEW_PROFILE_DATA=""
				saveProfiles
				refreshProfilesWindowInfo
				setupNewProfile
				;;
			"22" ) # Use This Profile
				useProfile
				break
				;;
			"40" ) # Advanced fields
				if [ "$ADVANCED" ] ; then
					unset -v ADVANCED
				else
					ADVANCED=1
				fi
				;;
			"50" ) # No encryption
				PROFILE_ENCRYPTION="Open"
				;;
			"51" ) # WEP
				PROFILE_ENCRYPTION="WEP"
				;;
			"52" ) # WPA
				PROFILE_ENCRYPTION="WPA"
				PROFILE_WPA_TYPE=""
				;;
			"53" ) # WPA2
				PROFILE_ENCRYPTION="WPA2"
				PROFILE_WPA_TYPE="2"
				;;
			load) # If it wasn't any other button, it must be a profile button
				PROFILE_TITLES="`echo "${PROFILE_TITLES}" | grep -v \"#NEW#\"`"
				CURRENT_PROFILE="$PROFILE_COMBO"
				loadProfileData "$CURRENT_PROFILE"
				
				;;
		esac

	done

	if [ "${EXIT}" == "22" ] ; then
		return 0
	else
		return 1
	fi

} # end showProfilesWindow

#=============================================================================
refreshProfilesWindowInfo()
{
#		SCANALL=`iwlist ${INTERFACE} scan`

		#PROFILE_CONF=`cat /etc/WAG/profile-conf`
		PROFILE_TITLES=`grep -E 'TITLE[0-9]+=' /usr/local/net_setup/etc/WAG/profile-conf | cut -d= -f2 | tr -d '"' | tr " " "_" `
} # end refreshProfilesWindowInfo

#=============================================================================
buildProfilesWindow()
{
	DEFAULT_TITLE=""
	DEFAULT_ESSID=""
	DEFAULT_KEY=""
	DEFAULT_NWID=""
	DEFAULT_FREQ=""
	DEFAULT_CHANNEL=""
	DEFAULT_AP_MAC=""

	if [ "${PROFILE_MODE}" == "ad-hoc" ] ; then
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
    if [ "${PROFILE_SECURE}" == "open" ] ; then
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
	#if [ "${PROFILE_WPA_DRV}" == "hostap" ] ; then #Prism 2-3
		#PROFILE_WPA_DRV_P="true"
		#PROFILE_WPA_DRV_R="false"		
		#PROFILE_WPA_DRV_O="false"
		#DEFAULT_WPA_DRV_P="<default>${PROFILE_WPA_DRV_P}</default>"
		#DEFAULT_WPA_DRV_R="<default>${PROFILE_WPA_DRV_P}</default><visible>disabled</visible>"		
		#DEFAULT_WPA_DRV_O="<default>${PROFILE_WPA_DRV_O}</default><visible>disabled</visible>"
	#elif [ "${PROFILE_WPA_DRV}" == "ralink" ] ; then #Ralink
		#PROFILE_WPA_DRV_P="false"
		#PROFILE_WPA_DRV_R="true"		
		#PROFILE_WPA_DRV_O="false"
		#DEFAULT_WPA_DRV_P="<default>${PROFILE_WPA_DRV_P}</default><visible>disabled</visible>"
		#DEFAULT_WPA_DRV_R="<default>${PROFILE_WPA_DRV_P}</default>"		
		#DEFAULT_WPA_DRV_O="<default>${PROFILE_WPA_DRV_O}</default><visible>disabled</visible>"
	#else # Other (wext)
		#PROFILE_WPA_DRV_P="false"
		#PROFILE_WPA_DRV_R="false"		
		#PROFILE_WPA_DRV_O="true"
		#DEFAULT_WPA_DRV_P="<default>${PROFILE_WPA_DRV_P}</default><visible>disabled</visible>"
		#DEFAULT_WPA_DRV_R="<default>${PROFILE_WPA_DRV_P}</default><visible>disabled</visible>"		
		#DEFAULT_WPA_DRV_O="<default>${PROFILE_WPA_DRV_O}</default>"
	#fi

	if [ "${PROFILE_WPA_AP_SCAN}" == "1" ] ; then # WPA Supplicant 
		PROFILE_WPA_AP_SCAN_S="true"
		PROFILE_WPA_AP_SCAN_D="false"
		PROFILE_WPA_AP_SCAN_H="false"
		DEFAULT_WPA_AP_SCAN_S="<default>${PROFILE_WPA_AP_SCAN_S}</default>"
		DEFAULT_WPA_AP_SCAN_D="<default>${PROFILE_WPA_AP_SCAN_D}</default><visible>disabled</visible>"
		DEFAULT_WPA_AP_SCAN_H="<default>${PROFILE_WPA_AP_SCAN_H}</default><visible>disabled</visible>"
	elif [ "${PROFILE_WPA_AP_SCAN}" == "0" ] ; then # Driver
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

	#echo $PROFILE_TITLE | grep -qE "^$" ;
	[ "$PROFILE_TITLE" ] && DEFAULT_TITLE="<default>${PROFILE_TITLE}</default>"
	#echo $PROFILE_ESSID | grep -qE "^$" ;
	[ "$PROFILE_ESSID" ] && DEFAULT_ESSID="<default>${PROFILE_ESSID}</default>"
	#echo $PROFILE_KEY | grep -qE "^$" ;
	[ "$PROFILE_KEY" ] && DEFAULT_KEY="<default>${PROFILE_KEY}</default>"
	#echo $PROFILE_NWID | grep -qE "^$" ;
	[ "$PROFILE_NWID" ] && DEFAULT_NWID="<default>${PROFILE_NWID}</default>"
	#echo $PROFILE_FREQ | grep -qE "^$" ;
	[ "$PROFILE_FREQ" ] && DEFAULT_FREQ="<default>${PROFILE_FREQ}</default>"
	#echo $PROFILE_CHANNEL | grep -qE "^$" ;
	[ "$PROFILE_CHANNEL" ] && DEFAULT_CHANNEL="<default>${PROFILE_CHANNEL}</default>"
	#echo $PROFILE_AP_MAC | grep -qE "^$" ;
	[ "$PROFILE_AP_MAC" ] && DEFAULT_AP_MAC="<default>${PROFILE_AP_MAC}</default>"

	buildProfilesWindowButtons
	
	setAdvancedFields
	
	case "$PROFILE_ENCRYPTION" in
		WEP)
			setWepFields
			;; 
		WPA|WPA2)
			setWpaFields
			;; 
		* ) 
			setNoEncryptionFields;; 
	esac
	# Dougal: disable the WPA button if interface doesn't support it.
	if [ "$PROFILE_WPA_DRV" ] ; then #disable button
		ENABLE_WPA_BUTTON='true'
	else
		ENABLE_WPA_BUTTON='false'
	fi
		
		export Puppy_Network_Setup="<window title=\"Puppy Network Wizrd\" icon-name=\"gtk-network\" window-position=\"1\">
<vbox>
	<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	<text><label>\"Create a new wireless profile or select an existing one.
if your driver supports scanning you can try scanning for available networks. 
The newly created networks will be saved for future use.\"</label></text>
	<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	<frame  Load profile >
			<hbox>
				<text>
					<label>Select a profile to load:</label>
				</text>
				<combobox>
					<variable>PROFILE_COMBO</variable>
					${PROFILE_BUTTONS}
				</combobox>
				<button>
					<label>Load</label>
					<input file stock=\"gtk-apply\"></input>
					<action>EXIT:load</action>
				</button>
			</hbox>
	</frame>
	<frame  Edit profile >
		<vbox>
			<hbox>
				<vbox>
					<text><label>Encryption:    </label></text>
					<pixmap><input file>$BLANK_IMAGE</input></pixmap>
				</vbox>
				<vbox>
				<button><label>Open</label><action>EXIT:50</action></button>
				<pixmap><input file>$BLANK_IMAGE</input></pixmap>
				</vbox>
				<vbox>
					<button>
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
					<button sensitive=\"$ENABLE_WPA_BUTTON\">
						<label>WPA2</label>
						<action>EXIT:53</action>
					</button>
					<pixmap><input file>$BLANK_IMAGE</input></pixmap>
				</vbox>
			</hbox>
			<hbox>
				<vbox>
					<text><label>\"Profile
Name:   \"</label></text>
					<pixmap><input file>$BLANK_IMAGE</input></pixmap>
				</vbox>
				<entry>
					<variable>PROFILE_TITLE</variable>
					${DEFAULT_TITLE}
				</entry>
			</hbox>
			<hbox>
				<vbox>
					<text><label>ESSID:    </label></text>
					<pixmap><input file>$BLANK_IMAGE</input></pixmap>
				</vbox>
				<entry>
					<variable>PROFILE_ESSID</variable>
					${DEFAULT_ESSID}
				</entry>
			</hbox>
			<hbox>
				
					<text><label>Mode:</label></text>
					
				
				<vbox>
					<checkbox>
						<label>Managed</label>
						<variable>PROFILE_MODE_M</variable>
						<action>if true disable:PROFILE_MODE_A</action>
						<action>if false enable:PROFILE_MODE_A</action>
						${DEFAULT_MODE_M}
					</checkbox>
					
				</vbox>
				<vbox>
					<checkbox>
						<label>Ad-hoc </label>
						<variable>PROFILE_MODE_A</variable>
						<action>if true disable:PROFILE_MODE_M</action>
						<action>if false enable:PROFILE_MODE_M</action>
						${DEFAULT_MODE_A}
					</checkbox>
					
				</vbox>
				
				
					<text><label>Security: </label></text>
					
				
				<vbox>
					<checkbox>
						<label>Open</label>
						<variable>PROFILE_SECURE_O</variable>
						<action>if true disable:PROFILE_SECURE_R</action>
						<action>if false enable:PROFILE_SECURE_R</action>
						${DEFAULT_SECURE_O}
					</checkbox>
					
				</vbox>
				<vbox>
					<checkbox>
						<label>Restricted</label>
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
					<label>Save</label>
					<input file icon=\"gtk-save\"></input>
					<action>EXIT:20</action>
				</button>
				<button>
					<label>Delete</label>
					<input file icon=\"gtk-delete\"></input>
					<action>EXIT:21</action>
				</button>
				<button>
					<label>Use This Profile</label>
					<action>EXIT:22</action>
				</button>
			</hbox>
		</vbox>
	</frame>
	<hbox>
		<button>
		  <label>New Profile</label>
		  <input file icon=\"gtk-new\"></input>
		  <action>EXIT:12</action>
		</button>				
		
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
		<button>
			<label>${ADVANCED_LABEL}</label>
			<input file icon=\"${ADVANCED_ICON}\"></input>
			<action>EXIT:40</action>
		</button>
		<button>
		  <label>Scan</label>
		  <input file stock=\"gtk-zoom-100\"></input>
		  <action>EXIT:11</action>
		</button>
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
setNoEncryptionFields()
{
	ENCRYPTION_FIELDS="${ADVANCED_FIELDS}"
}

#=============================================================================
setWepFields()
{
	ENCRYPTION_FIELDS="
<hbox>
	<vbox>
		<text><label>Key:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_KEY</variable>
		${DEFAULT_KEY}
	</entry>
</hbox>
${ADVANCED_FIELDS}
"
}

#=============================================================================
setWpaFields()
{
	ENCRYPTION_FIELDS="
<hbox>
	<vbox>
		<text><label>AP Scan:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<vbox>
		<checkbox>
			<label>Supplic.</label>
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
			<label>Driver</label>
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
		<checkbox>
			<label>Hidden</label>
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
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
</hbox>
<hbox>
	<vbox>
		<text><label>Shared Key:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_KEY</variable>
		${DEFAULT_KEY}
	</entry>
</hbox>
"
}

#=============================================================================
setAdvancedFields()
{
	if [ ! "${ADVANCED}" ] ; then
		ADVANCED_LABEL="Advanced"
		ADVANCED_ICON="gtk-add"
		ADVANCED_FIELDS=""
	else
		ADVANCED_LABEL="Basic"
		ADVANCED_ICON="gtk-remove"
		ADVANCED_FIELDS="
<hbox>
	<vbox>
		<text><label>Network Id:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_NWID</variable>
		${DEFAULT_NWID}
	</entry>
</hbox>
<hbox>
	<vbox>
		<text><label>Frequency:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_FREQ</variable>
		${DEFAULT_FREQ}
	</entry>
</hbox>
<hbox>
	<vbox>
		<text><label>Channel:</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_CHANNEL</variable>
		${DEFAULT_CHANNEL}
	</entry>
</hbox>
<hbox>
	<vbox>
		<text><label>\"Access Point
     MAC:\"</label></text>
		<pixmap><input file>$BLANK_IMAGE</input></pixmap>
	</vbox>
	<entry>
		<variable>PROFILE_AP_MAC</variable>
		${DEFAULT_AP_MAC}
	</entry>
</hbox>"	
	fi
}

#=============================================================================
buildProfilesWindowButtons()
{
	PROFILE_BUTTONS=""

	for PROFILE in ${PROFILE_TITLES}
	do
    if [ "${PROFILE}" != "#NEW#" ] ; then
		PROFILE_BUTTONS="${PROFILE_BUTTONS}<item>${PROFILE}</item>"
	fi
  done
} # end buildProfileWindowButtons

#=============================================================================
setupNewProfile ()
{
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

	PROFILE_TITLES="`echo "${PROFILE_TITLES}" | grep -v \"#NEW#\"`"
	PROFILE_TITLES="${PROFILE_TITLES}
#NEW#"
	CURRENT_PROFILE="#NEW#"

} # end clearProfileFields

#=============================================================================
loadProfileData()
{
	# Dougal: added "SECURE" param, increment the "-A" below
	PROFILE_TITLE=$1
	#PROFILE_DATA=`grep -A 10 -E "TITLE[0-9]+=\"${PROFILE_TITLE}\"" /etc/WAG/profile-conf`
	#v3.98 no, 'urban soul' reported need 'grep -A 11' here...
	PROFILE_DATA=`grep -A 11 -E "TITLE[0-9]+=\"${PROFILE_TITLE}\"" /usr/local/net_setup/etc/WAG/profile-conf`
	PROFILE_WPA_DRV=`echo "${PROFILE_DATA}" | grep 'WPA_DRV=' | cut -d= -f2 | tr -d '"'`
	PROFILE_WPA_TYPE=`echo "${PROFILE_DATA}" | grep 'WPA_TYPE=' | cut -d= -f2 | tr -d '"'`
	PROFILE_WPA_AP_SCAN=`echo "${PROFILE_DATA}" | grep 'WPA_AP_SCAN=' | cut -d= -f2 | tr -d '"'`
	PROFILE_ESSID=`echo "${PROFILE_DATA}" | grep 'ESSID=' | cut -d= -f2 | tr -d '"'`
	[ "$PROFILE_ESSID" = "<hidden>" ] && PROFILE_ESSID=""
	PROFILE_NWID=`echo "${PROFILE_DATA}" | grep 'NWID=' | cut -d= -f2 | tr -d '"'`
	PROFILE_KEY=`echo "${PROFILE_DATA}" | grep 'KEY=' | cut -d= -f2 | tr -d '"'`
	PROFILE_MODE=`echo "${PROFILE_DATA}" | grep 'MODE=' | cut -d= -f2 | tr -d '"'`
	PROFILE_SECURE=`echo "${PROFILE_DATA}" | grep 'SECURE=' | cut -d= -f2 | tr -d '"'`
	PROFILE_FREQ=`echo "${PROFILE_DATA}" | grep 'FREQ=' | cut -d= -f2 | tr -d '"'`
	PROFILE_CHANNEL=`echo "${PROFILE_DATA}" | grep 'CHANNEL=' | cut -d= -f2 | tr -d '"'`
	PROFILE_AP_MAC=`echo "${PROFILE_DATA}" | grep 'AP_MAC=' | cut -d= -f2 | tr -d '"'`

	if [ "x${PROFILE_KEY}" == "x" ] ; then
		PROFILE_ENCRYPTION="Open"
	elif [ "x${PROFILE_WPA_DRV}" == "x" ] ; then
		PROFILE_ENCRYPTION="WEP"
	elif [ "$PROFILE_WPA_TYPE" ] ; then # Dougal: add WPA2
		PROFILE_ENCRYPTION="WPA2"
	else
		PROFILE_ENCRYPTION="WPA"
	fi 

} # end loadProfileData

#=============================================================================
assembleProfileData()
{
	if [ "${PROFILE_MODE_A}" == "true" ] ; then
		PROFILE_MODE="ad-hoc"
	else
		PROFILE_MODE="managed"
	fi
	
	if [ "${PROFILE_SECURE_O}" == "true" ] ; then
		PROFILE_SECURE="open"
	else
		PROFILE_SECURE="restricted"
	fi

	#if [ "${PROFILE_WPA_DRV_P}" == "true" ] ; then
		#PROFILE_WPA_DRV="hostap"
	#elif [ "${PROFILE_WPA_DRV_R}" == "true" ] ; then
		#PROFILE_WPA_DRV="ralink"
	#else
		#PROFILE_WPA_DRV="wext"
	#fi

	if [ "${PROFILE_WPA_AP_SCAN_H}" == "true" ] ; then
		PROFILE_WPA_AP_SCAN="2"
	elif [ "${PROFILE_WPA_AP_SCAN_D}" == "true" ] ; then
		PROFILE_WPA_AP_SCAN="0"
	else # WPA supplicant does the scanning
		PROFILE_WPA_AP_SCAN="1"
	fi

	case ${PROFILE_ENCRYPTION} in
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

	PROFILE_TITLE="$(echo "${PROFILE_TITLE}" | tr " " "_")"
	NEW_PROFILE_DATA="TITLE1=\"${PROFILE_TITLE}\"
        WPA_DRV=\"${PROFILE_WPA_DRV}\"
        WPA_TYPE=\"$PROFILE_WPA_TYPE\"
        WPA_AP_SCAN=\"${PROFILE_WPA_AP_SCAN}\"
        ESSID=\"${PROFILE_ESSID}\"
        NWID=\"${PROFILE_NWID}\"
        KEY=\"${PROFILE_KEY}\"
        MODE=\"${PROFILE_MODE}\"
        SECURE=\"${PROFILE_SECURE}\"
        FREQ=\"${PROFILE_FREQ}\"
        CHANNEL=\"${PROFILE_CHANNEL}\"
        AP_MAC=\"${PROFILE_AP_MAC}\"
        "
}

#=============================================================================
saveProfiles ()
{
	NEW_PROFILE_TITLE=`echo "${NEW_PROFILE_DATA}" | grep -E "TITLE[0-9]+=" | cut -d= -f2 | tr -d '"'`

	NEW_PROFILE_CONF="
# This is the config file for WAG's profile management.
# It allows you to store the connection information for access points.
# For now you must set it up by hand.
# Two connections are supplied by default.
# The first is called 'autoconnect'.  It clears all settings
# and forces your card to connect to the best station it can find.
# The second is a template.  Copy it when making a new entry.

# WAG uses a combination of context search and line counting to
# find the required information.  Don't misspell a line or delete
# an unneeded line.  This will break the profile.  Settings not
# required should be set to ""
# TITLE must be sequentially numbered.
	"
	#Count the number of profiles to be able to show progress
	COUNT_PROFILES=0
	for PROFILE in ${PROFILE_TITLES}
  do
		let COUNT_PROFILES=COUNT_PROFILES+1
  done

	#Save all profiles reorganizing the title number. This is required because
	# standalon WAG requires those numbers.
	(
		TITLE_NUM=0
		for PROFILE in ${PROFILE_TITLES}
		do
			echo "X"
			if [ "${PROFILE}" == "${CURRENT_PROFILE}" ] ; then
				PROFILE_DATA="${NEW_PROFILE_DATA}"
			else
				loadProfileData ${PROFILE}
			fi

			if [ ! -z "${PROFILE_DATA}" ] ; then
				let TITLE_NUM=TITLE_NUM+1

				PROFILE_TITLE=`echo "${PROFILE_DATA}" | grep -E "TITLE[0-9]+=" | cut -d= -f2 | tr -d '"'`
				SAVE_PROFILE_DATA=`echo "${PROFILE_DATA}" | grep -v -E "TITLE[0-9]+=\"${PROFILE_TITLE}\""`
				NEW_PROFILE_CONF="${NEW_PROFILE_CONF}
TITLE${TITLE_NUM}=\"${PROFILE_TITLE}\"
${SAVE_PROFILE_DATA}"
			fi
		done
		echo "${NEW_PROFILE_CONF}" > /usr/local/net_setup/etc/WAG/profile-conf
  ) | Xdialog --title "Puppy Ethernet Wizard" --progress "Saving profile" 0 0 $COUNT_PROFILES

	CURRENT_PROFILE="${NEW_PROFILE_TITLE}"
} # end saveProfiles

#=============================================================================
useProfile ()
{
	case ${PROFILE_ENCRYPTION} in
		WPA|WPA2)
			useWpaSupplicant
			;;
		*)
			if [ "$USE_WLAN_NG" ] ; then
			  useWlanctl
			else 
			  useIwconfig
			fi
			;;		
	esac
} # end useProfile

#=============================================================================
killWpaSupplicant ()
{
	# If there are supplicant processes for the current interface, kill them
	
	SUPPLICANT_PIDS=$( ps -e | grep -v "grep" | grep -E "wpa_supplicant.+${INTERFACE}" | grep -oE "^ *[0-9]+")
	if [ -n "${SUPPLICANT_PIDS}" ]; then
		rm /var/run/wpa_supplicant/${INTERFACE}* &> /dev/null
		for SUPPLICANT_PID in ${SUPPLICANT_PIDS} ; do
			kill ${SUPPLICANT_PID} &> /dev/null
		done
		
		sleep 5 # to wait for the supplicant to shutdown
	fi
	
}
#=============================================================================
useIwconfig ()
{
  (
	killWpaSupplicant
	echo "X"
	RUN_IWCONFIG=""
	[ "$PROFILE_ESSID" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} essid \"${PROFILE_ESSID}\""
	[ "$PROFILE_NWID" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} nwid $PROFILE_NWID"
	[ "$PROFILE_FREQ" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} freq $PROFILE_FREQ"
	[ "$PROFILE_CHANNEL" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} channel $PROFILE_CHANNEL"
	[ "$PROFILE_MODE" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} mode $PROFILE_MODE"
	[ "$PROFILE_AP_MAC" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} ap $PROFILE_AP_MAC"
	[ "$PROFILE_KEY" ] && RUN_IWCONFIG="${RUN_IWCONFIG}\n iwconfig ${INTERFACE} key $PROFILE_SECURE $PROFILE_KEY"
	

	echo "X"
	echo -e "#Configure the wireless interface
echo \"Configuring wireless interface ${INTERFACE}\"
ifconfig ${INTERFACE} up
${RUN_IWCONFIG}" > /tmp/wag-profiles_iwconfig.sh
	sh /tmp/wag-profiles_iwconfig.sh >/tmp/wag-profiles_iwconfig-output.txt
	echo "X"
  ) | Xdialog --title "Puppy Ethernet Wizard" --progress "Saving profile" 0 0 3
} # end useIwconfig
#=============================================================================
# Dougal: add this for the prism2_usb module
useWlanctl(){
  (
    killWpaSupplicant
    echo "X"
    # create code for running wlanctl-ng
    WLANNG_CODE="wlanctl-ng $INTERFACE lnxreq_ifstate ifstate=enable"
    # need to check if PROFILE_KEY exists, to know if we're using WEP or not
    if [ "$PROFILE_KEY" ] ; then
      # need to split the key into pairs
      A=0
      WLAN_KEY=""
      for ONE in 1 2 3 4 5
      do
        WLAN_KEY="$WLAN_KEY${PROFILE_KEY:$A:2}:"
        let A=A+2
      done
      WLAN_KEY=${WLAN_KEY%:}
      WLANNG_CODE="$WLANNG_CODE
wlanctl-ng $INTERFACE lnxreq_hostwep decrypt=true encrypt=true
wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11PrivacyInvoked=true
wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11WEPDefaultKeyID=0
wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11ExcludeUnencrypted=true
wlanctl-ng $INTERFACE dot11req_mibset mibattribute=dot11WEPDefaultKey0=$WLAN_KEY"
    fi
    ## Dougal: probably need to change PROFILE_SECURE to right format
    ## (I'm leaving it the same everywhere else -- so gui looks the same)
    case "$PROFILE_SECURE" in
     open) WLAN_SECURE="opensystem" ;;
     restricted) WLAN_SECURE="sharedkey" ;;
    esac 
    WLANNG_CODE="$WLANNG_CODE
wlanctl-ng $INTERFACE lnxreq_autojoin ssid=$PROFILE_ESSID authtype=$WLAN_SECURE"
    
    echo "X"
    echo -e "#Configure the wireless interface
echo \"Configuring wireless interface ${INTERFACE}\"
$WLANNG_CODE" > /tmp/wag-profiles_iwconfig.sh
	sh /tmp/wag-profiles_iwconfig.sh >/tmp/wag-profiles_iwconfig-output.txt
    echo "X"
  ) | Xdialog --title "Puppy Ethernet Wizard" --progress "Saving profile" 0 0 3
} # end useWlanctl
#=============================================================================
useWpaSupplicant ()
{
	# If key is not hex, then convert to hex
	echo "${PROFILE_KEY}" | grep -E "^[0-9a-fA-F]{64}$"
	if [ $? -eq 0 ] ; then
		PSK=${PROFILE_KEY}
	else
		#KEY_SIZE=`echo "${PROFILE_KEY}" | wc -c`
		KEY_SIZE=${#PROFILE_KEY}
		#v3.95 dougal suggests change 9 to 8...
		#if [ ${KEY_SIZE} -lt 9 ] || [ ${KEY_SIZE} -gt 64 ] ; then
		if [ ${KEY_SIZE} -lt 8 ] || [ ${KEY_SIZE} -gt 64 ] ; then
			Xdialog --left --title "Puppy Network Wizard" --msgbox "Shared key must be either\n- Alphanumeric betwen 8 and 63 characters or\n- 64 characters hexadecimal " 0 0 		
			EXIT=0
			return 0
		else
			PSK=`wpa_passphrase "${PROFILE_ESSID}" "${PROFILE_KEY}" | \
						grep -v "#psk" | \
						grep "psk" | \
						cut -d"=" -f2`
		fi
	fi

	rm -f /tmp/wpa_status.txt
	rm -f /tmp/wag-profiles_iwconfig.sh

	TMPLOG="/tmp/wag-profiles_tmp.log"
	rm "${TMPLOG}" &> ${DEBUG_OUTPUT}
	(
#		killWpaSupplicant
		wpa_supplicant -i ${INTERFACE} -D ${PROFILE_WPA_DRV} -c /usr/local/net_setup/etc/wpa_supplicant$PROFILE_WPA_TYPE.conf -B >> ${TMPLOG} 2>&1
		wpa_cli ap_scan ${PROFILE_WPA_AP_SCAN} >> ${TMPLOG} 2>&1
		wpa_cli set_network 0 ssid "\"${PROFILE_ESSID}\"" >> ${TMPLOG} 2>&1
		wpa_cli set_network 0 psk "${PSK}" >> ${TMPLOG} 2>&1
		wpa_cli save_config >> ${TMPLOG} 2>&1
#v3.95 pizzasgood suggested comment out this line...
#		wpa_cli reconfigure >> ${TMPLOG} 2>&1
		killWpaSupplicant
		echo "X"

		wpa_supplicant -i ${INTERFACE} -D ${PROFILE_WPA_DRV} -c /usr/local/net_setup/etc/wpa_supplicant$PROFILE_WPA_TYPE.conf -B >> ${TMPLOG} 2>&1

		COUNT=0
		MAX_COUNT=12
		DELAY=5
		echo "Waiting for connection" >> ${TMPLOG} 2>&1
		while [ ${COUNT} -lt ${MAX_COUNT} ] ; do  
			sleep ${DELAY}
			WPA_STATUS=`wpa_cli status | grep "wpa_state" | cut -d"=" -f2`
			echo "---" >> ${TMPLOG} 2>&1
			echo "$(wpa_cli status)" >> ${TMPLOG} 2>&1
			if [ "${WPA_STATUS}" == "COMPLETED" ] ; then
				COUNT=${MAX_COUNT}
			fi
			let COUNT=COUNT+1
			echo "X"
		done
		echo -n "${WPA_STATUS}" > /tmp/wpa_status.txt
		echo "---" >> ${TMPLOG} 2>&1
  ) | Xdialog --title "Puppy Ethernet Wizard" --progress "Acquiring WPA connection\n\nThere may be a delay up to 60 seconds." 0 0 13
	cat ${TMPLOG} > ${DEBUG_OUTPUT}
	WPA_STATUS="$(cat /tmp/wpa_status.txt)"
	
	if [ "${WPA_STATUS}" == "COMPLETED" ] ; then
		echo -e "#!/bin/sh
#Configure the wireless interface through WPA
/usr/local/net_setup/usr/sbin/wpa_connect.sh ${INTERFACE} ${PROFILE_WPA_DRV} $PROFILE_WPA_TYPE" > /tmp/wag-profiles_iwconfig.sh
	else
		Xdialog --left --title "Puppy Network Wizard" --msgbox "Unable to establish WPA connection" 0 0 		
	fi

} # end useWpaSupplicant

#=============================================================================
showScanWindow()
{
	if [ "$USE_WLAN_NG" = "yes" ] ; then
	  buildPrismScanWindow
	else
	  buildScanWindow
	fi

	SCANWINDOW_RESPONSE="`sh /tmp/net-setup_scanwindow`"

	CELL=`echo ${SCANWINDOW_RESPONSE} | grep -Eo "[0-9]+"`

	[ "$CELL" ] && setupScannedProfile 

} # end of showScanWindow

#=============================================================================
buildScanWindow()
{
	SCANWINDOW_BUTTONS=""
	(
		ifconfig ${INTERFACE} up

		echo "X"
		SCANALL=`iwlist ${INTERFACE} scan`

		echo "X"
		SCAN_LIST=`echo "$SCANALL" | grep 'Cell\|ESSID\|Mode\|Frequency\|Quality\|Encryption\|Channel'`
		echo "${SCAN_LIST}" > /tmp/net-setup_scanlist
		if [ "$SCAN_LIST" == "" ]; then
			echo "Xdialog --left --title \"Puppy Network Wizard:\" --msgbox \"No networks detected\" 0 0 " > /tmp/net-setup_scanwindow
		else
			# give each Cell its own button
			CELL_LIST=`echo "$SCAN_LIST" | grep -Eo "Cell [0-9]+" | cut -f2 -d " "`
			for CELL in ${CELL_LIST} ; do
				getCellParameters ${CELL}
				[ "$CELL_ESSID" = "" ] && CELL_ESSID="(hidden ESSID)"
				SCANWINDOW_BUTTONS="${SCANWINDOW_BUTTONS} \"${CELL}\" \"${CELL_ESSID} (${CELL_MODE}; Encryption:${CELL_ENCRYPTION})\" off \"Channel:${CELL_CHANNEL}; Frequency:${CELL_FREQ}; AP MAC:${CELL_AP_MAC};
Strength:${CELL_QUALITY}\"" 
			done
			echo "Xdialog --left --item-help --stdout --title \"Puppy Network Wizard:\" --radiolist \"Select one of the available networks
	Move the mouse over to see more details.\"  20 60 4  \
	${SCANWINDOW_BUTTONS} 2> /dev/null" > /tmp/net-setup_scanwindow
		fi
		echo "X"
	)  | Xdialog --title "Puppy Ethernet Wizard" --progress "Scanning wireless networks" 0 0 3
	
	SCAN_LIST="$(cat /tmp/net-setup_scanlist)"
	
} #end of buildScanWindow

#=============================================================================
buildPrismScanWindow()
{
  SCANWINDOW_BUTTONS=""
  (
	#ifconfig ${INTERFACE} up
	# enable interface
	wlanctl-ng ${INTERFACE} lnxreq_ifstate ifstate=enable >/tmp/wlan-up 2>&1
	# scan (first X echoed only afterwards!
	wlanctl-ng ${INTERFACE} dot11req_scan bsstype=any bssid=ff:ff:ff:ff:ff:ff ssid="" scantype=both channellist="00:01:02:03:04:05:06:07:08:09:0a:0b:00:00" minchanneltime=200 maxchanneltime=250 >/tmp/prism-scan-all #2>&1
	echo "X"
	#SCANALL=`iwlist ${INTERFACE} scan`
	# get number of access points (make sure we get integer)
	POINTNUM=`grep -F 'numbss=' /tmp/prism-scan-all | cut -d= -f2 | grep [0-9]`
	## Dougal: not sure about this -- need a way to make sure we get something
	#if grep -F 'resultcode=success' /tmp/prism-scan-all ; then
	if [ "$POINTNUM" ] ; then
	  # get scan results for all access points
	  for P in `seq 0 $POINTNUM`
	  do
	    wlanctl-ng ${INTERFACE} dot11req_scan_results bssindex=$P >/tmp/prism-scan$P #2>&1
	  done
	  echo "X"
	  # create buttons
	  for P in `seq 0 $POINTNUM`
	  do
	    grep -Fq 'resultcode=success' /tmp/prism-scan$P || continue
	    getPrismCellParameters $P
	    [ "$CELL_ESSID" = "" ] && CELL_ESSID="(hidden SSID)"
		# might add test here for some params, then maybe skip
		SCANWINDOW_BUTTONS="${SCANWINDOW_BUTTONS} \"$P\" \"${CELL_ESSID} (${CELL_MODE}; Encryption:${CELL_ENCRYPTION})\" off \"Channel:${CELL_CHANNEL}; AP MAC:${CELL_AP_MAC}\"" 
	  done
	else
	  echo "X"
	fi
	if [ "$SCANWINDOW_BUTTONS" ] ; then
		echo "Xdialog --left --item-help --stdout --title \"Puppy Network Wizard:\" --radiolist \"Select one of the available networks
	Move the mouse over to see more details.\"  20 60 4  \
	${SCANWINDOW_BUTTONS} 2> /dev/null" > /tmp/net-setup_scanwindow
	else
	  echo "Xdialog --left --title \"Puppy Network Wizard:\" --msgbox \"No networks detected\" 0 0 " > /tmp/net-setup_scanwindow
	fi
	echo "X"
  )  | Xdialog --title "Puppy Ethernet Wizard" --progress "Scanning wireless networks" 0 0 3
	
  #SCAN_LIST="$(cat /tmp/net-setup_scanlist)"
	
} #end of buildPrismScanWindow

#=============================================================================
setupScannedProfile()
{
	setupNewProfile
	if [ "$USE_WLAN_NG" = "yes" ] ; then
	  getPrismCellParameters $CELL
	  # clean up from earlier
	  rm -f /tmp/prism-scan*
	else
	  getCellParameters ${CELL}
	fi
	# Dougal: setupNewProfile always sets PROFILE_MODE to "ad-hoc"!
	case "$CELL_MODE" in
	  Managed|infrastructure) PROFILE_MODE="managed" ;;
	  Ad-Hoc) PROFILE_MODE="ad-hoc" ;;
	esac
	PROFILE_ESSID="${CELL_ESSID}"
	PROFILE_TITLE="${CELL_ESSID}"
	PROFILE_FREQ="${CELL_FREQ}"
	PROFILE_CHANNEL="${CELL_CHANNEL}"
	PROFILE_AP_MAC="${CELL_AP_MAC}"

	case ${CELL_ENCRYPTION} in 
	  on|true) PROFILE_KEY="Provide a key" ;;
	  *) PROFILE_KEY="" ;;
	esac
	
} # end of setupScannedProfile

#=============================================================================
getCellParameters()
{
	CELL=$1
	SCAN_CELL=`echo "$SCAN_LIST" | grep -A 5 "Cell ${CELL}"`
	CELL_ESSID=`echo "$SCAN_CELL" | grep -E -o 'ESSID:".+"' | grep -E -o '".+"' | grep -E -o '[^"]+'`
	[ "$CELL_ESSID" = "<hidden>" ] && CELL_ESSID=""
	CELL_FREQ=`echo "$SCAN_CELL" | grep "Frequency" | grep -Eo '[0-9]+\.[0-9]+ +G' | sed -e 's/ G/G/'` 
	CELL_CHANNEL=`echo "$SCAN_CELL" | grep "Frequency" | grep -Eo 'Channel [0-9]+' | cut -f2 -d" "`
	[ ! "$CELL_CHANNEL" ] && CELL_CHANNEL=`echo "$SCAN_CELL" | grep -F 'Channel:' | grep -Eo [0-9]+`
	CELL_QUALITY=`echo "$SCAN_CELL" | grep "Quality=" | cut -d":" -f2-`
	[ ! "$CELL_QUALITY" ] && CELL_QUALITY=`echo "$SCAN_CELL" | grep "Quality" | tr -s ' '`
	CELL_AP_MAC=`echo "$SCAN_CELL" | grep -E -o '[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}'`
	CELL_MODE=`echo "$SCAN_CELL" | grep -o 'Mode:Managed\|Mode:Ad-Hoc' | cut -d":" -f2`
	CELL_ENCRYPTION=`echo "${SCAN_CELL}" | grep -Eo "Encryption key:[a-zA-Z]+" | cut -d":" -f2`
} # end of getCellParameters

#=============================================================================
getPrismCellParameters()
{
	CELL=$1
	#SCAN_CELL=`echo "$SCAN_LIST" | grep -A 5 "Cell ${CELL}"`
	CELL_ESSID=`grep -F 'ssid=' /tmp/prism-scan$CELL | grep -v 'bssid=' | cut -d"'" -f2`
	#CELL_FREQ=`echo "$SCAN_CELL" | grep "Frequency" | grep -Eo '[0-9]+\.[0-9]+ +G' | sed -e 's/ G/G/'` 
	CELL_CHANNEL=`grep -F 'dschannel=' /tmp/prism-scan$CELL | cut -d= -f2`
	#CELL_QUALITY=`echo "$SCAN_CELL" | grep "Quality:" | cut -d":" -f2-`
	## Dougal: not sure about this: maybe skip ones without anything?
	CELL_AP_MAC=`grep -F 'bssid=' /tmp/prism-scan$CELL | cut -d= -f2 | grep -E  '[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}'`
	## Dougal: might need to do something to fit this to checkboxes
	CELL_MODE=`grep -F 'bsstype=' /tmp/prism-scan$CELL | cut -d= -f2`
	## Dougal: maybe do something with "no_value"
	CELL_ENCRYPTION=`grep -F 'privacy=' /tmp/prism-scan$CELL | cut -d= -f2`
} # end of getCellParameters



#=============================================================================
#=============== START OF SCRIPT BODY ====================
#=============================================================================

# If ran by itself it shows the interface, Otherwise it's only used as a function library
CURRENT_CONTEXT=`expr "$0" : '.*/\(.*\)$' `
if [ "${CURRENT_CONTEXT}" == "wag-profiles.sh" ] ; then
	INTERFACE=${1}
	DEBUG_OUTPUT="/dev/stdout"
	showProfilesWindow $1
fi 
DEBUG_OUTPUT="/dev/stdout"
#[ ! ${DEBUG_OUTPUT} ] && DEBUG_OUTPUT="/dev/null"

#=============================================================================
#=============== END OF SCRIPT BODY ====================
#=============================================================================

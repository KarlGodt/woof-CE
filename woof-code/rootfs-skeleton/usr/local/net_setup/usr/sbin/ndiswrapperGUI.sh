#!/bin/sh
#(c) copyright Raul Suarez 2006
#Puppy ndiswrapper GUI setup script.
#v4.00 BK 29apr2008: bugfix.

#=============================================================================
#============= FUNCTIONS USED IN THE SCRIPT ==============
#=============================================================================

selectDriverFile()
{
    CONTINUE="false"
    while [ $CONTINUE == "false" ] ; do
        # REM: Xdialog fselect
      INF_FILE_NAME="`Xdialog --left --title \"Select the driver information file (.INF)\" \
       --stdout --no-buttons --fselect \"${PREV_LOCATION}/*\" 0 0`"
      if [ $? -eq 0 ] ; then
        PREV_LOCATION="`expr "$INF_FILE_NAME" : '\(.*\)/'`"
        echo $PREV_LOCATION > "$CONFIG_DIR/prev_location"
        echo $INF_FILE_NAME | grep -Eiq "\.inf$"
        if [ $? -eq 0 ] ; then
                selectDriverFile_RC=0
                CONTINUE="true"
        else
        # REM: Xdialog msgbox
          Xdialog --screen-center --title "Puppy Ethernet Wizard: ndiswrapper" \
                  --msgbox "The file name should end in \".inf\"" 0 0
        fi
      else
        selectDriverFile_RC=1
        CONTINUE="true"
      fi
    done

    return $selectDriverFile_RC
} # end of selectDriverFile

#=============================================================================
showNdiswrapperGUI()
{
  CONFIG_DIR=/root/.config/ndiswrapperGUI

  mkdir -p $CONFIG_DIR
  PREV_LOCATION="`cat "$CONFIG_DIR/prev_location"`"
  if [ "$PREV_LOCATION" = "" ] ; then #v4.00 bugfix
    INF_FILE_NAME=""
  fi

  showNdiswrapperGUI_RC=1
  selectDriverFile
  if [ $? -eq 0 ] ; then

    echo "INF_FILE_NAME=$INF_FILE_NAME" #TEST

    #v4.00 fails if space in path, need quotes...
    expr "$INF_FILE_NAME" : '.*/\(.*\).inf' | tr "[A-Z]" "[a-z]"

    echo "INF_FILE_NAME=$INF_FILE_NAME" #TEST

    #v4.00 fails if space in path, need quotes...
    ndiswrapper -i "$INF_FILE_NAME" > /tmp/net-setup_NDISWRAPPER_LOAD.txt
    NDISWRAPPER_RESULT=$?
        case ${NDISWRAPPER_RESULT} in
            0 | 25 | 255)
                # REM: Xdialog msgbox
                    Xdialog --left --screen-center --title "Puppy Ethernet Wizard: ndiswrapper" \
              --msgbox "`ndiswrapper -l`" 0 0
              showNdiswrapperGUI_RC=0
          ;;
            *) # REM: Xdialog msgbox
             Xdialog --left --screen-center --title "Puppy Ethernet Wizard: ndiswrapper" \
              --msgbox "`cat /tmp/net-setup_NDISWRAPPER_LOAD.txt`" 0 0
          ;;
        esac
  fi
  return $showNdiswrapperGUI_RC
} # end of showNdiswrapperGUI


#=============================================================================
#=============== START OF SCRIPT BODY ====================
#=============================================================================

# If ran by itself it shows the interface, Otherwise it's only used as a function library
CURRENT_CONTEXT=`expr "$0" : '.*/\(.*\)$' `
if [ "${CURRENT_CONTEXT}" == "ndiswrapperGUI.sh" ] ; then
    showNdiswrapperGUI
fi

#=============================================================================
#=============== END OF SCRIPT BODY ====================
#=============================================================================

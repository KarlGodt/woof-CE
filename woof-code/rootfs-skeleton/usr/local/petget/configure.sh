#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/pkg_chooser.sh
#configure package manager

export LANG=C
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS
. /root/.packages/DISTRO_PET_REPOS
. /root/.packages/PKGS_MANAGEMENT #has PKG_REPOS_ENABLED

#find what repos are currently in use...
CHECKBOXES_REPOS=""
for ONEREPO in `ls -1 /root/.packages/Packages-*`
do
 BASEREPO="`basename $ONEREPO`"
 bPATTERN=' '"$BASEREPO"' '
 DEFAULT='true'
 [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && DEFAULT='false'
 DBNAME="`echo -n "$BASEREPO" | sed -e 's%Packages\-%%'`"
 CHECKBOXES_REPOS="${CHECKBOXES_REPOS}<checkbox><default>${DEFAULT}</default><label>${DBNAME}</label><variable>CHECK_${DBNAME}</variable></checkbox>"
done


export CONFIG_DIALOG="<window title=\"Puppy Package Manager: configure\" icon-name=\"gtk-about\">
<hbox>

<vbox>
 <frame Update database>
  <hbox>
   <text><label>Puppy has a database file for each package repository. Click this button to download the latest information on what packages are in the repository:</label></text>
   <button><label>Update now</label><action>rxvt -bg yellow -title 'download databases' -e /usr/local/petget/0setup</action></button>
  </hbox>
  <text><label>Note: some repositories are 'fixed' and do not need to be updated. An example of this is the Slackware official version 12.2 repo. An example that does change is the Slackware 'slacky' 12.2 repo which has extra packages for Slackware 12.2. Anyway, to be on the safe side, clicking the above button will update all database files.</label></text>
  <text><label>Warning: The database information for some repositories is quite large, about 1.5MB for 'slacky' and several MB for Ubuntu/Debian. If you are on dialup, be prepared for this.</label></text>
  <text><label>Technical note: if you would like to see the package databases, they are at /root/.packages/Packages-*. These are in a standardised format, regardless of which distribution they were obtained from. This format is considerably smaller than that of the original distro.</label></text>
 </frame>
</vbox>

<vbox>
 <text use-markup=\"true\"><label>\"<b>Requires restart of PPM to see changes</b>\"</label></text>
 <frame Choose repositories>
  <text><label>Choose what repositories you would like to have appear in the main GUI window (tick a maximum of 5 boxes):</label></text>
  ${CHECKBOXES_REPOS}
  <hbox>
   <text><label>Adding a new repository currently requires manual editing of some text files. Click this button for further information:</label></text>
   <button><label>Add repo help</label>
   <action>nohup defaulthtmlviewer file:///usr/local/petget/README-add-repo.htm & </action>
   </button>
  </hbox>
 </frame>
 <hbox>
  <button ok></button>
  <button cancel></button>
 </hbox>
</vbox>

</hbox>
</window>"

RETPARAMS="`gtkdialog3 --program=CONFIG_DIALOG`"
#ex:
#  CHECK_puppy-2-official="false"
#  CHECK_puppy-3-official="true"
#  CHECK_puppy-4-official="true"
#  CHECK_puppy-woof-official="false"
#  CHECK_ubuntu-intrepid-main="true"
#  CHECK_ubuntu-intrepid-multiverse="true"
#  CHECK_ubuntu-intrepid-universe="true"
#  EXIT="OK"

[ "`echo -n "$RETPARAMS" | grep 'EXIT' | grep 'OK'`" = "" ] && exit

enabledrepos=" "
repocnt=1
for ONEREPO in `ls -1 /root/.packages/Packages-*`
do
 REPOBASE="`basename $ONEREPO`"
 repoPATTERN="`echo -n "$REPOBASE" | sed -e 's%Packages\\-%%' | sed -e 's%\\-%\\\\-%g'`"
 if [ "`echo "$RETPARAMS" | grep "$repoPATTERN" | grep 'false'`" = "" ];then
  enabledrepos="${enabledrepos}${REPOBASE} "
  repocnt=`expr $repocnt + 1`
  [ $repocnt -gt 5 ] && break #only allow 5 active repos in PPM.
 fi
done
grep -v '^PKG_REPOS_ENABLED' /root/.packages/PKGS_MANAGEMENT > /tmp/PetGet/pkgs_management_tmp2
mv -f /tmp/PetGet/pkgs_management_tmp2 /root/.packages/PKGS_MANAGEMENT
echo "PKG_REPOS_ENABLED='${enabledrepos}'" >> /root/.packages/PKGS_MANAGEMENT



###END###

#!/bin/sh

for i in {1..25};do echo;done
echo -e "\\033[1;36m""
############
# Wrapper  #
# Type \"$0 help\" #
# for info #
############
""\\033[0;39m" >&2

usage (){
MSG="
S0:
Wrapper for ./autogen.sh in extracted git archives

Usage:
$0 [info|debug|force|help]
"
echo "$MSG"
exit $1
}

if [ "`echo "$@" |grep -w help`" ];then
usage 0
fi
if [ "`echo "$@" |grep -w info`" ];then
INFO=1
fi
if [ "`echo "$@" |grep -w debug`" ];then
DEBUG=1
fi
if [ "`echo "$@" |grep -w force`" ];then
FORCE=1
fi

#

rm -rf autom4te*
rm -f aclocal*
#

#
mFOURcmd=m4
#

#
aclocalcmd=aclocal

libtoolizecmd=libtoolize

autoheadercmd=autoheader

autoconfcmd=autoconf

automakecmd=automake  #--add-missing
#

#

if [ "$INFO" ];then
for command in $aclocalcmd $libtoolizecmd $autoheadercmd $autoconfcmd $automakecmd ;do
POOL=`type -a $command`
POOL=`echo "$POOL" |awk '{print $3}'`

#echo "
#$POOL
#"

#eval "pool_${command}"="$POOL"
#eval echo "pool_${command}"="$POOL"
#eval echo "pool_${command}=${POOL}"

pool_[${command}]="$POOL"
echo "
${pool_[$command]}"

#for n in {1..9};do
n=0
while [ 1 ];do ((n++))
[ "`echo "${pool_[$command]}" | sed -n "$n p"`" ] || break
echo ""
echo -e "\\033[1;35m""$n:" `echo "${pool_[$command]}" | sed -n "$n p"` "\\033[0;39m"
echo ""

file_whole_name=`echo  "${pool_[$command]}" | sed -n "$n p"`
echo file_whole_name=$file_whole_name
file_whole_name_arr[$n]="$file_whole_name"
[ "$n" -gt 1 ] && diff -q ${file_whole_name_arr[$n]} ${file_whole_name_arr[$((n-1))]}

dir_name="${file_whole_name%/*}"
echo dir_name=$dir_name
file_name="${file_whole_name##*/}"
echo file_name=$file_name
echo ""

FILE=`find "$dir_name" -iname "${file_name}*" -exec file {} \;`
echo "$FILE"
FILE=`echo "$FILE" |cut -f1 -d:`
echo ""
 m=0
 for f in $FILE ;do ((m++))
  file_arr[$m]="$f"
  echo -n "	diff $m $((m-1)) ${file_arr[$m]} "
  [ -L "${file_arr[$m]}" ] && { echo '*LINK* ';echo;continue; }
  [ "$m" -gt 1 ] && { diff -q ${file_arr[$m]} ${file_arr[$((m-1))]} && echo -e  "Same.\n"; } || echo -e " \n"
 done #f in FILE

done #while 1

done #command in .. ..
exit $?
fi
#

#
if [ "$FORCE" ];then

rm -f *.cache
rm -rf autom4te.*
rm -f *.aclocal
rm -f aclocal.m4


aclocalcmd_EXE=$aclocalcmd

libtoolizecmd_EXE=$libtoolizecmd

autoheadercmd_EXE=$autoheadercmd

autoconfcmd_EXE=$autoconfcmd

automakecmd_EXE=$automakecmd

else #force


for command in $aclocalcmd $libtoolizecmd $autoheadercmd $autoconfcmd $automakecmd ;do
POOL=`type -a $command`
POOL=`echo "$POOL" |awk '{print $3}'`
pool_[${command}]="$POOL"
echo "
${pool_[$command]}"

#"pool_${command}"=`echo "$POOL" |awk '{print $3}'`
done


#if [ "`type -a $aclocalcmd |wc -l`" -gt 1 ];then
#type -a $aclocalcmd
#pool_aclocalcmd=`type -a $aclocalcmd |awk '{print $3}'`
#fi


#if [ "`type -a $libtoolizecmd |wc -l`" -gt 1 ];then
#type -a $libtoolizecmd
#pool_libtoolizecmd=`type -a $libtoolizecmd |awk '{print $3}'`
#fi


#if [ "`type -a $autoheadercmd |wc -l`" -gt 1 ];then
#type -a $autoheadercmd
#pool_autoheadercmd=`type -a $autoheadercmd |awk '{print $3}'`
#fi


#if [ "`type -a $autoconfcmd |wc -l`" -gt 1 ];then
#type -a  $autoconfcmd
#pool_autoconfcmd=`type -a $autoconfcmd |awk '{print $3}'`
#fi


#if [ "`type -a $automakecmd |wc -l`" -gt 1 ];then
#type -a  $automakecmd
#pool_automakecmd=`type -a  $automakecmd |awk '{print $3}'`
#fi


[ "$DEBUG" ] && find /usr -path "*/bin/$aclocalcmd*" -exec file {} \;

pool_aclocalcmd="${pool_aclocalcmd[@]}
`find /usr -path \"*/bin/$aclocalcmd*\"`"
pool_aclocalcmd=`echo "$pool_aclocalcmd" |sort -u`

[ "$DEBUG" ] && find /usr -path "*/bin/$libtoolizecmd*" -exec file {} \;

pool_libtoolizecmd="${pool_libtoolizecmd[@]}
`find /usr -path \"*/bin/$libtoolizecmd*\"`"
pool_libtoolizecmd=`echo "$pool_libtoolizecmd" |sort -u`

[ "$DEBUG" ] && find /usr -path "*/bin/$autoheadercmd*" -exec file {} \;

pool_autoheadercmd="${pool_autoheadercmd[@]}
`find /usr -path \"*/bin/$autoheadercmd*\"`"
pool_autoheadercmd=`echo "$pool_autoheadercmd" |sort -u`

[ "$DEBUG" ] && find /usr -path "*/bin/$autoconfcmd*" -exec file {} \;

pool_autoconfcmd="${pool_autoconfcmd[@]}
`find /usr -path \"*/bin/$autoconfcmd*\"`"
pool_autoconfcmd=`echo "$pool_autoconfcmd" |sort -u`

[ "$DEBUG" ] && find /usr -path "*/bin/$automakecmd*" -exec file {} \;

pool_automakecmd="${pool_automakecmd[@]}
`find /usr -path \"*/bin/$automakecmd*\"`"
pool_automakecmd=`echo "$pool_automakecmd" | sort -u`

echo "
              *** MENU ***
"

select aclocalcmd_EXE in ${pool_aclocalcmd[@]};do echo "CHOICE:$aclocalcmd_EXE";break;done
echo
select libtoolizecmd_EXE in ${pool_libtoolizecmd[@]};do echo "CHOICE:$libtoolizecmd_EXE";break;done
echo
select autoheadercmd_EXE in ${pool_autoheadercmd[@]};do echo "CHOICE:$autoheadercmd_EXE";break;done
echo
select autoconfcmd_EXE in ${pool_autoconfcmd[@]};do echo "CHOICE:$autoconfcmd_EXE";break;done
echo
select automakecmd_EXE in ${pool_automakecmd[@]};do echo "CHOICE:$automakecmd_EXE";break;done
echo

fi #force
#

#
$aclocalcmd_EXE --verbose 1>autogen_krg.log 2>&1
RV=$?
tail autogen_krg.log
echo -e "\\033[1;35m$aclocalcmd_EXE:$RV\\033[0;39m
"

$libtoolizecmd_EXE -c --debug 1>>autogen_krg.log 2>&1
RV=$?
tail autogen_krg.log
echo -e "\\033[1;35m$libtoolizecmd_EXE:$RV\\033[0;39m
"

$autoheadercmd_EXE --verbose 1>>autogen_krg.log 2>&1
RV=$?
tail autogen_krg.log
echo -e "\\033[1;35m$autoheadercmd_EXE:$RV\\033[0;39m
"

$autoconfcmd_EXE --verbose 1>>autogen_krg.log 2>&1
RV=$?
tail autogen_krg.log
echo -e "\\033[1;35m$autoconfcmd_EXE:$RV\\033[0;39m
"

$automakecmd_EXE --add-missing -c --verbose 1>>autogen_krg.log 2>&1
RV=$?
tail autogen_krg.log
echo -e "\\033[1;35m$automakecmd_EXE:$RV\\033[0;39m
"

#

#
echo -e "\\033[1;36m
       *** WARNINGS ***
\\033[0;39m"
grep warning autogen_krg.log
#

#OUTPUT="
#              *** MENU ***
#
#1) /usr/bin/aclocal		3) /usr/local/bin/aclocal
#2) /usr/bin/aclocal-1.9		4) /usr/local/bin/aclocal-1.11
##? 4
#CHOICE:/usr/local/bin/aclocal-1.11
#
#1) /usr/bin/libtoolize
#2) /usr/local/bin/libtoolize
#? 2
#CHOICE:/usr/local/bin/libtoolize
#
#1) /usr/bin/autoheader
#2) /usr/local/bin/autoheader
#? 2
#CHOICE:/usr/local/bin/autoheader
#
#1) /usr/bin/autoconf
#2) /usr/local/bin/autoconf
#? 2
#CHOICE:/usr/local/bin/autoconf
#
#1) /usr/bin/automake		 4) /usr/local/bin/automake-1.10
#2) /usr/bin/automake-1.9	 5) /usr/local/bin/automake-1.11
#3) /usr/local/bin/automake
#? 4
#CHOICE:/usr/local/bin/automake-1.10
#
#acinclude.m4:12: warning: underquoted definition of AS_AC_EXPAND
#acinclude.m4:12:   run info '(automake)Extending aclocal'
#acinclude.m4:12:   or see http://sources.redhat.com/automake/automake.html#Extending-aclocal
#configure.in:469: warning: macro `AM_GLIB_GNU_GETTEXT' not found in library
#libtoolize: putting auxiliary files in `.'.
#libtoolize: linking file `./ltmain.sh'
#libtoolize: Consider adding `AC_CONFIG_MACRO_DIR([m4])' to configure.in and
#libtoolize: rerunning libtoolize, to keep the correct libtool macros in-tree.
#libtoolize: Consider adding `-I m4' to ACLOCAL_AMFLAGS in Makefile.am.
#aclocal.m4:16: warning: this file was generated for autoconf 2.67.
#You have another version of autoconf.  It may work, but is not guaranteed to.
#If you have problems, you may need to regenerate the build system entirely.
#To do so, use the procedure documented by the package, typically `autoreconf'.
#configure.in:474: error: possibly undefined macro: AC_PROG_INTLTOOL
#      If this token and others are legitimate, please use m4_pattern_allow.
#      See the Autoconf documentation.
#configure.in:475: error: possibly undefined macro: AM_GLIB_GNU_GETTEXT
#hald/Makefile.am:17: variable `hald_test_SOURCES' is defined but no program or
#hald/Makefile.am:17: library has `hald_test' as canonical name (possible typo)
#hald/Makefile.am:28: variable `hald_test_LDADD' is defined but no program or
#hald/Makefile.am:28: library has `hald_test' as canonical name (possible typo)
#[17:15 0 /bin/sh 26750 3 hal-0.5.5.1 ]
#[puppypc]# ./configure
#./configure: line 13664: syntax error near unexpected token `PACKAGE,'
#./configure: line 13664: `PKG_CHECK_MODULES(PACKAGE, $pkg_modules)'
#[17:18 2 /bin/sh 26750 4 hal-0.5.5.1 ]
#
#"

#Mo 16. Jul 22:41:05 GMT+1 2012 --add-missing --copy --no-force
#/bin/automake '--add-missing --copy --no-force'
#/root/Downloads/NOUVEAU/0.0.16/xf86-video-nouveau-dc89dac734167bcbc667b39ca6ee2043871a60bf:/root/Downloads/NOUVEAU/0.0.16/xf86-video-nouveau-dc89dac734167bcbc667b39ca6ee2043871a60bf
#[1;36m
#############
## Wrapper  #
## Type "/bin/autoconf --wrapper=help" #
## for info #
##############
#[0;39m
#automake: ####################
#automake: ## Internal Error ##
#automake: ####################
#automake: unrequested trace `$n'
#automake: Please contact <bug-automake@gnu.org>.
# at /usr/local/share/automake-1.9/Automake/Channels.pm line 562
#	Automake::Channels::msg('automake', '', 'unrequested trace `$n\'') called at /usr/local/share/automake-1.9/Automake/ChannelDefs.pm line 191
#	Automake::ChannelDefs::prog_error('unrequested trace `$n\'') called at /usr/bin/automake line 4673
#	Automake::scan_autoconf_traces('configure.ac') called at /usr/bin/automake line 4875
#	Automake::scan_autoconf_files() called at /usr/bin/automake line 7491
#

#!/bin/ash
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_rxvt"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/bin/rxvt"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || . /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP='1'; TWO_VERSION='1'; TWO_VERBOSE='1'; TWO_DEBUG='1'; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap

}
# End new header
#

_install(){
(
MY_SELF=`realpath "$0"`
for x in rxvt
do
test -x "$x" || continue
URXVT=`which "$x"`

case `file "$URXVT"` in
*shell*script*|*script*text*) :;;

*ELF*LSB*GNU/Linux*)
BNBIN=`basename "$URXVT"`
DNBIN=`dirname "$URXVT"`
cp -af "$URXVT" /tmp/"$BNBIN".bin
BNWRP=`basename "$MY_SELF"`
DNWRP=`dirname "$MY_SELF"`
cp -af "$MY_SELF" /tmp/"$BNWRP"

cp -af /tmp/"$BNBIN".bin "$DNBIN"/
cp -af /tmp/"$BNWRP" "$DNBIN"/jwm

;;

*)
: echo TODO
;;
esac
done
)
}

_install

which rxvt.bin >>$OUT || exit 3

case $@ in *-font*|*-fn*) exec rxvt.bin "$@";;

*)
FONTS=`xlsfonts`
_debugx "$FONTS"
NR_FONTS=`echo "$FONTS" |wc -l`
_debug "NR_FONTS='$NR_FONTS'"
RANDOM_FONT=`echo $(((RANDOM%$NR_FONTS)+1))`
_debug "RANDOM_FONT='$RANDOM_FONT'"
FONT_USE=`echo "$FONTS" | sed -n "$RANDOM_FONT p"`
_debug "FONT_USE='$FONT_USE'"

if test "$FONT_USE"; then
exec rxvt.bin -font "$FONT_USE" -name "$FONT_USE" "$@"
else
exec rxvt.bin -font '-*-*-*-*-*-*-*-*-*-*-*-*-*-*' "$@"
fi
;;

esac

#exit $?
# Very End of this file 'usr/bin/rxvt' #
###END###
#*** here come the fonts :
Di 31. Dez 07:00:47 GMT+1 2013 : -adobe-utopia-bold-i-normal--17-120-100-100-p-93-iso8859-9
Tue Dec 31 13:27:15 GMT+1 2013 : -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-7
Tue Dec 31 17:07:24 GMT+1 2013 : -b&h-lucidabright-medium-i-normal--11-80-100-100-p-63-iso8859-2
Tue Dec 31 17:33:55 GMT+1 2013 : -b&h-lucidabright-demibold-i-normal--0-0-100-100-p-0-iso8859-13
Tue Dec 31 18:07:02 GMT+1 2013 : -adobe-times-medium-r-normal--24-240-75-75-p-124-iso8859-15
Wed Jan  1 17:50:10 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--13-120-75-75-c-60-iso8859-15
Thu Jan  2 15:45:00 GMT+1 2014 : -adobe-helvetica-bold-r-normal--14-100-100-100-p-82-iso8859-14
Fri Jan  3 18:33:01 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--8-80-75-75-p-45-iso8859-13
Sat Jan  4 17:31:01 GMT+1 2014 : -adobe-utopia-bold-r-normal--19-180-75-75-p-105-iso8859-14
Sat Jan  4 23:55:46 GMT+1 2014 : -b&h-luxi serif-medium-o-normal--0-0-0-0-p-0-iso8859-9
Sun Jan  5 09:30:52 GMT+1 2014 : -adobe-helvetica-medium-o-normal--24-240-75-75-p-130-iso8859-1
Sun Jan  5 17:10:58 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-34-240-100-100-p-191-iso8859-15
Sun Jan  5 20:04:44 GMT+1 2014 : -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-16
Sun Jan  5 23:36:44 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-25-180-100-100-m-150-iso8859-9
Mon Jan  6 02:00:16 GMT+1 2014 : -adobe-helvetica-medium-o-normal--12-120-75-75-p-67-iso10646-1
Mon Jan  6 03:15:27 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso10646-1
Mon Jan  6 14:35:53 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--17-120-100-100-p-99-iso8859-2
Mon Jan  6 17:04:58 GMT+1 2014 : -adobe-utopia-bold-r-normal--10-100-75-75-p-59-iso8859-3
Mon Jan  6 17:52:16 GMT+1 2014 : -b&h-luxi serif-medium-o-normal--0-0-0-0-p-0-iso8859-1
Mon Jan  6 18:19:50 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--10-100-75-75-p-66-iso10646-1
Mon Jan  6 21:16:01 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--24-240-75-75-p-137-iso8859-13
Tue Jan  7 23:58:08 GMT+1 2014 : -b&h-luxi mono-medium-o-normal--0-0-0-0-m-0-iso8859-1
Wed Jan  8 08:03:42 GMT+1 2014 : -mutt-clearlyu ligature-medium-r-normal--0-0-100-100-p-0-fontspecific-0
Wed Jan  8 16:31:47 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--25-180-100-100-p-142-iso8859-2
Thu Jan  9 23:19:26 GMT+1 2014 : -b&h-luxi mono-medium-r-normal--0-0-0-0-m-0-iso8859-1
Fri Jan 10 16:17:14 GMT+1 2014 : -b&h-luxi serif-bold-r-normal--0-0-0-0-p-0-iso8859-3
Fri Jan 10 20:32:09 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--20-140-100-100-p-111-iso10646-1
Sat Jan 11 16:05:32 GMT+1 2014 : -adobe-times-bold-r-normal--10-100-75-75-p-57-iso8859-3
Sat Jan 11 18:53:07 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-8-80-75-75-m-50-iso8859-15
Sun Jan 12 01:08:01 GMT+1 2014 : -adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1
Sun Jan 12 13:10:26 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-70-iso8859-9
Sun Jan 12 18:33:51 GMT+1 2014 : -adobe-times-medium-i-normal--20-140-100-100-p-94-iso10646-1
Sun Jan 12 19:09:02 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-75-75-c-0-jisx0201.1976-0
Sun Jan 12 19:13:43 GMT+1 2014 : -adobe-courier-medium-o-normal--14-100-100-100-m-90-iso8859-14
Sun Jan 12 19:17:26 GMT+1 2014 : -schumacher-clean-medium-r-normal--0-0-75-75-c-0-iso8859-3
Sun Jan 12 19:23:32 GMT+1 2014 : -adobe-helvetica-bold-o-normal--0-0-100-100-p-0-iso8859-1
Sun Jan 12 19:32:50 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-11-80-100-100-p-62-iso8859-14
Sun Jan 12 19:37:42 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-14-100-100-100-p-90-iso8859-3
Sun Jan 12 19:40:35 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--12-110-75-75-c-60-iso8859-3
Sun Jan 12 19:48:43 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--10-100-75-75-p-60-iso8859-2
Sun Jan 12 19:59:54 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--0-0-100-100-p-0-iso8859-4
Sun Jan 12 20:07:33 GMT+1 2014 : -adobe-times-medium-r-normal--0-0-75-75-p-0-iso10646-1
Sun Jan 12 20:15:27 GMT+1 2014 : -adobe-utopia-bold-r-normal--14-100-100-100-p-78-iso8859-14
Mon Jan 13 01:10:21 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--34-240-100-100-p-193-iso8859-2
Mon Jan 13 02:35:47 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-8-80-75-75-m-50-iso8859-4
Mon Jan 13 18:13:22 GMT+1 2014 : -misc-fixed-medium-r-normal--18-120-100-100-c-90-iso8859-2
Mon Jan 13 20:27:40 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-0-0-75-75-p-0-iso8859-14
Mon Jan 13 20:53:29 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-20-140-100-100-p-114-iso8859-15
Mon Jan 13 22:36:00 GMT+1 2014 : -adobe-helvetica-bold-o-normal--8-80-75-75-p-50-iso8859-4
Mon Jan 13 23:52:49 GMT+1 2014 : -adobe-utopia-regular-r-normal--33-240-100-100-p-180-iso8859-1
Tue Jan 14 02:41:02 GMT+1 2014 : -adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-3
Tue Jan 14 12:01:57 GMT+1 2014 : -adobe-helvetica-medium-r-normal--10-100-75-75-p-56-iso8859-10
Tue Jan 14 14:57:41 GMT+1 2014 : -adobe-courier-bold-o-normal--0-0-100-100-m-0-iso8859-14
Wed Jan 15 02:29:23 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-20-140-100-100-p-127-iso10646-1
Wed Jan 15 19:58:16 GMT+1 2014 : -adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-15
Thu Jan 16 01:27:25 GMT+1 2014 : -adobe-courier-medium-o-normal--34-240-100-100-m-200-iso8859-15
Thu Jan 16 06:35:07 GMT+1 2014 : -adobe-courier-medium-r-normal--17-120-100-100-m-100-iso10646-1
Thu Jan 16 10:59:35 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-17-120-100-100-p-96-iso8859-2
Thu Jan 23 14:04:57 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--26-190-100-100-p-156-iso8859-4
Fri Jan 24 00:31:09 GMT+1 2014 : -adobe-courier-medium-r-normal--24-240-75-75-m-150-iso8859-15
Fri Jan 24 07:53:13 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-0-0-75-75-p-0-iso8859-13
Fri Jan 24 15:13:55 GMT+1 2014 : -misc-nil-medium-r-normal--2-20-75-75-c-10-misc-fontspecific
Sat Jan 25 08:05:45 GMT+1 2014 : -adobe-utopia-regular-r-normal--25-180-100-100-p-135-iso8859-4
Sun Jan 26 10:32:49 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-24-240-75-75-p-151-iso8859-3
Mon Jan 27 10:09:48 GMT+1 2014 : -adobe-times-bold-i-normal--34-240-100-100-p-170-iso10646-1
Tue Jan 28 16:56:07 GMT+1 2014 : -adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-2
Wed Jan 29 12:24:51 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-8-80-75-75-m-50-iso8859-2
Fri Jan 31 02:51:14 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--0-0-100-100-p-0-iso8859-2
Fri Jan 31 13:04:52 GMT+1 2014 : -adobe-helvetica-bold-r-normal--20-140-100-100-p-105-iso8859-2
Sat Feb  1 13:09:33 GMT+1 2014 : -adobe-utopia-bold-r-normal--33-240-100-100-p-186-iso8859-10
Sat Feb  1 13:49:01 GMT+1 2014 : -adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso10646-1
Sat Feb  1 18:08:02 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--13-120-75-75-c-60-iso10646-1
Sat Feb  1 20:47:11 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-20-140-100-100-p-114-iso8859-4
Sun Feb  2 04:20:30 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--26-190-100-100-p-155-iso8859-14
Sun Feb  2 13:06:09 GMT+1 2014 : -adobe-times-medium-r-normal--25-180-100-100-p-125-iso8859-10
Sun Feb  2 16:04:21 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--24-240-75-75-p-143-iso8859-4
Mon Feb  3 03:12:36 GMT+1 2014 : -adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-9
Mon Feb  3 19:15:44 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--13-120-75-75-c-60-iso8859-9
Sun Jul  6 22:08:44 GMT+1 2014 : -adobe-times-bold-r-normal--0-0-75-75-p-0-iso8859-10
Sun Jul  6 22:39:38 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--34-240-100-100-p-193-iso8859-3
Mon Jul  7 01:19:30 GMT+1 2014 : -bitstream-charter-medium-i-normal--15-140-75-75-p-82-iso8859-1
Mon Jul  7 01:19:38 GMT+1 2014 : -adobe-utopia-regular-r-normal--14-100-100-100-p-75-iso8859-13
Mon Jul  7 11:03:15 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-100-100-c-0-iso8859-13
Mon Jul  7 11:36:57 GMT+1 2014 : -schumacher-clean-bold-r-normal--10-100-75-75-c-80-iso646.1991-irv
Mon Jul  7 20:50:05 GMT+1 2014 : -adobe-helvetica-medium-o-normal--0-0-75-75-p-0-iso8859-9
Mon Jul  7 23:08:19 GMT+1 2014 : -misc-fixed-medium-o-semicondensed--13-120-75-75-c-60-iso8859-7
Mon Jul  7 23:22:50 GMT+1 2014 : -adobe-helvetica-bold-r-normal--14-100-100-100-p-82-iso8859-9
Tue Jul  8 00:44:55 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--20-140-100-100-p-119-iso8859-15
Tue Jul  8 01:48:20 GMT+1 2014 : -adobe-courier-medium-o-normal--8-80-75-75-m-50-iso8859-1
Tue Jul  8 11:34:39 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-75-75-c-0-iso8859-10
Tue Jul  8 12:41:55 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-20-140-100-100-p-127-iso8859-2
Tue Jul  8 12:55:23 GMT+1 2014 : -adobe-helvetica-medium-o-normal--10-100-75-75-p-57-iso8859-1
Tue Jul  8 13:52:14 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--34-240-100-100-p-193-iso8859-13
Tue Jul  8 14:04:25 GMT+1 2014 : -adobe-utopia-regular-i-normal--25-240-75-75-p-133-iso8859-14
Tue Jul  8 20:25:46 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--17-120-100-100-p-96-iso8859-15
Tue Jul  8 20:51:55 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--17-120-100-100-p-92-iso8859-15
Tue Jul  8 21:19:22 GMT+1 2014 : -misc-serto jerusalem-bold-r-normal--0-0-0-0-p-0-iso10646-1
Wed Jul  9 08:48:03 GMT+1 2014 : -mutt-clearlyu devanagari-medium-r-normal--15-120-90-90-p-104-fontspecific-0
Wed Jul  9 12:10:50 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-8
Wed Jul  9 17:04:07 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--18-180-75-75-p-107-iso8859-15
Wed Jul  9 17:05:46 GMT+1 2014 : -adobe-times-medium-r-normal--8-80-75-75-p-44-iso8859-15
Wed Jul  9 17:08:43 GMT+1 2014 : -misc-fixed-medium-r-normal--15-140-75-75-c-90-iso8859-5
Wed Jul  9 17:09:33 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-14-100-100-100-p-90-iso8859-4
Wed Jul  9 17:18:26 GMT+1 2014 : -misc-fixed-bold-r-normal--0-0-75-75-c-0-iso8859-4
Wed Jul  9 17:27:26 GMT+1 2014 : -mutt-clearlyu ligature-medium-r-normal--17-120-100-100-p-141-fontspecific-0
Wed Jul  9 17:30:01 GMT+1 2014 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-9
Wed Jul  9 17:31:44 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--17-120-100-100-p-92-iso8859-10
Wed Jul  9 17:49:32 GMT+1 2014 : -adobe-utopia-bold-i-normal--14-100-100-100-p-78-iso8859-9
Thu Jul 10 00:23:48 GMT+1 2014 : -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-5
Thu Jul 10 10:18:01 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-14-140-75-75-m-90-iso8859-3
Thu Jul 10 21:31:20 GMT+1 2014 : -adobe-helvetica-bold-o-normal--20-140-100-100-p-103-iso10646-1
Fri Jul 11 17:10:10 GMT+1 2014 : -adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-9
Fri Jul 11 23:05:00 GMT+1 2014 : -adobe-times-bold-i-normal--17-120-100-100-p-86-iso8859-10
Sat Jul 12 07:06:02 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--25-180-100-100-p-149-iso8859-1
Sat Jul 12 07:51:16 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--14-100-100-100-p-84-iso8859-9
Sat Jul 12 08:05:21 GMT+1 2014 : -sun-open look glyph-----0-0-75-75-p-0-sunolglyph-1
Sat Jul 12 08:50:04 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--0-0-75-75-c-0-iso8859-13
Mon Jul 14 11:51:19 GMT+1 2014 : -adobe-courier-bold-o-normal--25-180-100-100-m-150-iso8859-14
Tue Jul 15 07:36:24 GMT+1 2014 : -misc-fixed-bold-r-normal--15-120-100-100-c-90-iso8859-1
Tue Jul 15 11:38:45 GMT+1 2014 : -adobe-courier-bold-o-normal--14-140-75-75-m-90-iso8859-2
Tue Jul 15 19:16:39 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--17-120-100-100-p-101-iso8859-10
Wed Jul 16 16:52:26 GMT+1 2014 : -bitstream-courier 10 pitch-medium-r-normal--0-0-0-0-m-0-iso10646-1
Wed Jul 16 16:56:19 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--12-120-75-75-p-77-iso8859-15
Thu Jul 17 00:05:05 GMT+1 2014 : -adobe-times-bold-r-normal--0-0-100-100-p-0-iso8859-2
Thu Jul 17 15:50:43 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--0-0-75-75-c-0-iso10646-1
Fri Jul 18 08:45:24 GMT+1 2014 : -adobe-courier-bold-o-normal--17-120-100-100-m-100-iso8859-2
Fri Jul 18 12:42:52 GMT+1 2014 : -mutt-clearlyu arabic extra-medium-r-normal--17-120-100-100-p-101-fontspecific-0
Fri Jul 18 20:29:57 GMT+1 2014 : -b&h-luxi sans-bold-o-normal--0-0-0-0-p-0-iso10646-1
Sat Jul 19 08:42:49 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-75-75-c-0-iso8859-1
Sat Jul 19 14:26:11 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-3
Sun Jul 20 08:35:27 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-5
Mon Jul 21 08:41:16 GMT+1 2014 : olglyph-12
Mon Jul 21 15:13:09 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-3
Tue Jul 22 09:48:44 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--10-100-75-75-p-57-iso8859-13
Tue Jul 22 10:13:24 GMT+1 2014 : -b&h-luxi serif-medium-o-normal--0-0-0-0-p-0-iso8859-2
Tue Jul 22 23:37:22 GMT+1 2014 : -adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-3
Thu Jul 24 14:27:21 GMT+1 2014 : -adobe-times-medium-r-normal--25-180-100-100-p-125-iso8859-9
Fri Jul 25 16:09:38 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-5
Sat Jul 26 16:25:40 GMT+1 2014 : -adobe-times-bold-r-normal--0-0-75-75-p-0-iso8859-10
Sat Jul 26 19:41:41 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--19-190-75-75-p-114-iso8859-3
Mon Jul 28 10:03:27 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-17-120-100-100-m-100-iso8859-4
Mon Jul 28 13:25:38 GMT+1 2014 : -adobe-utopia-bold-r-normal--10-100-75-75-p-59-iso8859-10
Mon Jul 28 13:25:50 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-14-100-100-100-p-90-iso8859-1
Mon Jul 28 13:25:59 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--17-120-100-100-p-99-iso8859-3
Tue Jul 29 05:31:39 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-20-140-100-100-p-127-iso8859-4
Tue Jul 29 07:22:14 GMT+1 2014 : -adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-10
Tue Jul 29 07:23:13 GMT+1 2014 : -adobe-times-medium-r-normal--12-120-75-75-p-64-iso8859-3
Wed Jul 30 18:03:44 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-8-80-75-75-p-45-iso8859-13
Thu Jul 31 15:09:52 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-80-iso8859-16
Fri Aug  1 11:22:38 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--10-100-75-75-p-59-iso8859-3
Sat Aug  2 11:54:11 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--10-100-75-75-p-57-iso8859-3
Sun Aug  3 20:26:37 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--0-0-100-100-p-0-iso8859-1
Mon Aug  4 11:30:07 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-17-120-100-100-m-100-iso8859-2
Mon Aug  4 16:55:36 GMT+1 2014 : -adobe-utopia-bold-i-normal--15-140-75-75-p-82-iso8859-2
Mon Aug  4 19:22:41 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-20-140-100-100-p-127-iso8859-3
Tue Aug  5 11:27:55 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--10-100-75-75-p-60-iso8859-3
Tue Aug  5 11:28:40 GMT+1 2014 : -adobe-courier-medium-r-normal--24-240-75-75-m-150-iso8859-15
Tue Aug  5 11:30:00 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-14-100-100-100-p-80-iso8859-1
Tue Aug  5 17:25:07 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--34-240-100-100-p-181-iso8859-3
Wed Aug  6 08:49:59 GMT+1 2014 : -misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-7
Sat Aug  9 17:54:38 GMT+1 2014 : -adobe-courier-medium-o-normal--25-180-100-100-m-150-iso8859-4
Sat Aug  9 18:16:51 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-8-80-75-75-p-45-iso8859-10
Mon Aug 11 07:57:01 GMT+1 2014 : -b&h-luxi serif-medium-r-normal--0-0-0-0-p-0-iso8859-2
Mon Aug 11 12:57:21 GMT+1 2014 : -b&h-luxi sans-bold-r-normal--0-0-0-0-p-0-iso8859-10
Mon Aug 11 12:59:52 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--17-120-100-100-p-91-iso8859-9
Tue Aug 12 18:44:25 GMT+1 2014 : kanji24
Tue Aug 12 18:45:10 GMT+1 2014 : -misc-serto jerusalem-medium-r-normal--0-0-0-0-p-0-iso10646-1
Wed Aug 13 12:13:56 GMT+1 2014 : -adobe-helvetica-medium-r-normal--8-80-75-75-p-46-iso8859-9
Wed Aug 13 13:20:14 GMT+1 2014 : -adobe-times-medium-i-normal--14-100-100-100-p-73-iso8859-15
Wed Aug 13 18:04:32 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--0-0-100-100-p-0-iso8859-1
Wed Aug 13 18:14:33 GMT+1 2014 : -misc-fixed-medium-r-normal--14-130-75-75-c-70-koi8-r
Wed Aug 13 19:33:03 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--0-0-75-75-p-0-iso8859-9
Wed Aug 13 19:53:09 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-18-180-75-75-p-120-iso8859-10
Wed Aug 13 20:01:26 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-12-120-75-75-p-71-iso8859-14
Wed Aug 13 20:10:40 GMT+1 2014 : -b&h-luxi mono-bold-o-normal--0-0-0-0-m-0-iso8859-9
Fri Aug 15 14:23:44 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-100-100-100-c-60-iso8859-1
Fri Aug 15 14:31:54 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-koi8-r
Fri Aug 15 14:57:10 GMT+1 2014 : -adobe-utopia-regular-i-normal--33-240-100-100-p-179-iso8859-4
Fri Aug 15 14:02:37 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-10
Fri Aug 15 14:11:36 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--25-180-100-100-p-136-iso8859-1
Fri Aug 15 16:48:17 GMT+1 2014 : -adobe-courier-medium-r-normal--24-240-75-75-m-150-iso8859-15
Sat Aug 16 07:25:13 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-0-0-100-100-m-0-iso8859-1
Sat Aug 16 10:03:41 GMT+1 2014 : -adobe-courier-bold-r-normal--12-120-75-75-m-70-iso10646-1
Mon Aug 18 21:43:41 GMT+1 2014 : rk24
Tue Aug 19 19:06:55 GMT+1 2014 : -adobe-utopia-bold-r-normal--14-100-100-100-p-78-iso8859-14
Tue Aug 19 20:37:13 GMT+1 2014 : -adobe-courier-medium-o-normal--34-240-100-100-m-200-iso8859-9
Wed Aug 20 03:47:32 GMT+1 2014 : -adobe-helvetica-bold-r-normal--34-240-100-100-p-182-iso8859-9
Wed Aug 20 04:08:16 GMT+1 2014 : -schumacher-clean-bold-r-normal--10-100-75-75-c-80-iso646.1991-irv
Wed Aug 20 11:46:31 GMT+1 2014 : kanji24
Wed Aug 20 12:32:06 GMT+1 2014 : -adobe-utopia-bold-i-normal--17-120-100-100-p-93-iso8859-10
Wed Aug 20 12:44:41 GMT+1 2014 : -adobe-times-bold-i-normal--0-0-100-100-p-0-iso8859-3
Wed Aug 20 13:31:22 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--24-240-75-75-p-136-iso8859-10
Wed Aug 20 17:27:23 GMT+1 2014 : -adobe-utopia-regular-r-normal--15-140-75-75-p-79-iso8859-14
Wed Aug 20 17:49:08 GMT+1 2014 : -adobe-utopia-regular-r-normal--10-100-75-75-p-56-iso8859-15
Wed Aug 20 19:07:41 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-34-240-100-100-m-200-iso8859-9
Wed Aug 20 20:47:39 GMT+1 2014 : -adobe-helvetica-medium-r-normal--10-100-75-75-p-56-iso8859-13
Wed Aug 20 21:44:13 GMT+1 2014 : -adobe-courier-bold-o-normal--14-100-100-100-m-90-iso8859-9
Fri Aug 22 09:51:58 GMT+1 2014 : -adobe-times-medium-r-normal--14-140-75-75-p-74-iso8859-13
Fri Aug 22 21:19:45 GMT+1 2014 : -b&h-luxi mono-medium-r-normal--0-0-0-0-m-0-iso8859-9
Mon Aug 25 08:50:04 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--12-120-75-75-p-76-iso8859-9
Mon Aug 25 10:02:35 GMT+1 2014 : -sun-open look glyph-----0-0-75-75-p-0-sunolglyph-1
Mon Aug 25 12:28:15 GMT+1 2014 : -adobe-courier-bold-o-normal--12-120-75-75-m-70-iso8859-3
Mon Aug 25 16:37:44 GMT+1 2014 : -adobe-courier-medium-r-normal--10-100-75-75-m-60-iso10646-1
Tue Aug 26 19:14:15 GMT+1 2014 : -adobe-utopia-bold-i-normal--15-140-75-75-p-82-iso8859-15
Thu Aug 28 13:02:07 GMT+1 2014 : -adobe-helvetica-medium-o-normal--14-100-100-100-p-78-iso8859-2
Tue Sep  2 08:48:00 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--0-0-100-100-p-0-iso8859-3
Wed Sep  3 09:55:16 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--11-80-100-100-p-66-iso8859-3
Fri Sep  5 00:16:01 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-0-0-75-75-p-0-iso8859-13
Fri Sep  5 07:18:07 GMT+1 2014 : 7x13bold
Sat Sep  6 10:17:11 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--12-120-75-75-p-70-iso8859-3
Sat Sep  6 10:18:31 GMT+1 2014 : -adobe-utopia-regular-r-normal--10-100-75-75-p-56-iso8859-2
Sat Sep  6 10:20:28 GMT+1 2014 : -adobe-times-bold-i-normal--14-100-100-100-p-77-iso8859-15
Sat Sep  6 10:48:18 GMT+1 2014 : -adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-4
Sat Sep  6 10:57:36 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--20-140-100-100-p-113-iso8859-4
Sun Sep 14 19:28:59 GMT+1 2014 : lucidasans-bold-14
Sun Sep 14 23:04:40 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--12-120-75-75-p-72-iso8859-2
Mon Sep 15 13:22:34 GMT+1 2014 : -bitstream-charter-bold-r-normal--19-180-75-75-p-119-iso8859-1
Mon Oct 13 18:10:26 GMT+1 2014 : -adobe-times-bold-i-normal--0-0-75-75-p-0-iso8859-4
Mon Oct 13 18:11:28 GMT+1 2014 : -adobe-helvetica-bold-r-normal--0-0-100-100-p-0-iso8859-10
Di 14. Okt 06:24:40 GMT+1 2014 : -sun-open look cursor-----12-120-75-75-p-160-sunolcursor-1
Di 14. Okt 07:12:18 GMT+1 2014 : -adobe-times-medium-i-normal--25-180-100-100-p-125-iso10646-1
Di 14. Okt 10:55:27 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--18-180-75-75-p-113-iso8859-2
Tue Oct 14 11:49:52 GMT+1 2014 : -adobe-courier-medium-r-normal--20-140-100-100-m-110-iso8859-1
Di 14. Okt 14:08:22 GMT+1 2014 : -adobe-utopia-bold-i-normal--0-0-0-0-p-0-iso10646-1
Tue Oct 14 15:22:22 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-34-240-100-100-p-216-iso8859-3
Tue Oct 14 20:42:34 GMT+1 2014 : -adobe-times-medium-i-normal--24-240-75-75-p-125-iso8859-3
Di 14. Okt 22:23:23 GMT+1 2014 : -adobe-courier-bold-r-normal--17-120-100-100-m-100-iso8859-13
Wed Oct 15 09:35:06 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-18-180-75-75-p-105-iso8859-13
Thu Oct 16 12:09:39 GMT+1 2014 : -adobe-helvetica-medium-o-normal--17-120-100-100-p-88-iso10646-1
Thu Oct 16 14:30:50 GMT+1 2014 : -adobe-utopia-bold-r-normal--10-100-75-75-p-59-iso8859-13
Thu Oct 16 14:35:38 GMT+1 2014 : -adobe-utopia-regular-i-normal--15-140-75-75-p-79-iso8859-4
Fr 17. Okt 04:18:10 GMT+1 2014 : -adobe-times-medium-r-normal--25-180-100-100-p-125-iso8859-4
Fri Oct 17 08:57:41 GMT+1 2014 : -adobe-courier-bold-o-normal--34-240-100-100-m-200-iso8859-1
Fri Oct 17 11:22:13 GMT+1 2014 : -adobe-helvetica-medium-o-normal--18-180-75-75-p-98-iso8859-9
Fri Oct 17 21:33:29 GMT+1 2014 : -adobe-times-bold-i-normal--20-140-100-100-p-98-iso8859-14
Fr 17. Okt 22:18:34 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--11-80-100-100-p-66-iso8859-1
Fr 17. Okt 22:40:34 GMT+1 2014 : -b&h-luxi mono-medium-r-normal--0-0-0-0-c-0-iso8859-10
Sa 18. Okt 04:12:11 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-70-iso8859-7
Tue Oct 21 05:26:31 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--8-80-75-75-p-50-iso8859-2
Di 21. Okt 06:19:17 GMT+1 2014 : k14
Di 21. Okt 08:31:40 GMT+1 2014 : -adobe-times-medium-r-normal--11-80-100-100-p-54-iso8859-2
Di 21. Okt 08:38:51 GMT+1 2014 : -adobe-utopia-regular-i-normal--0-0-100-100-p-0-iso8859-13
Tue Oct 21 09:25:13 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-25-180-100-100-p-159-iso8859-15
Tue Oct 21 09:37:10 GMT+1 2014 : -adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-14
Tue Oct 21 09:37:22 GMT+1 2014 : -misc-fixed-medium-r-normal--6-60-75-75-c-40-iso8859-15
Tue Oct 21 09:58:06 GMT+1 2014 : -adobe-helvetica-medium-r-normal--11-80-100-100-p-56-iso10646-1
Di 21. Okt 10:01:37 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--14-140-75-75-p-80-iso8859-9
Di 21. Okt 10:09:38 GMT+1 2014 : -adobe-times-bold-r-normal--0-0-100-100-p-0-iso10646-1
Tue Oct 21 12:20:22 GMT+1 2014 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-13
Tue Oct 21 15:19:35 GMT+1 2014 : -misc-fixed-bold-r-semicondensed--13-120-75-75-c-60-iso8859-2
Di 21. Okt 16:01:16 GMT+1 2014 : -adobe-times-medium-i-normal--14-100-100-100-p-73-iso10646-1
Di 21. Okt 19:39:28 GMT+1 2014 : -adobe-times-bold-i-normal--0-0-75-75-p-0-iso10646-1
Tue Oct 21 20:18:08 GMT+1 2014 : -schumacher-clean-medium-r-normal--12-120-75-75-c-60-iso8859-8
Tue Oct 21 21:11:48 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-10-100-75-75-p-67-iso8859-13
Mi 22. Okt 09:37:26 GMT+1 2014 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-11
Wed Oct 22 11:19:49 GMT+1 2014 : -adobe-utopia-regular-i-normal--0-0-75-75-p-0-iso8859-2
Mi 22. Okt 23:12:35 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--18-180-75-75-p-103-iso8859-2
Thu Oct 23 00:50:52 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--18-180-75-75-p-103-iso8859-9
Thu Oct 23 17:59:51 GMT+1 2014 : -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso10646-1
Thu Oct 23 21:38:50 GMT+1 2014 : -adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-10
Fri Oct 24 00:00:16 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-19-190-75-75-p-108-iso8859-4
Fri Oct 24 00:26:10 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-75-75-c-0-iso8859-10
Fri Oct 24 01:13:46 GMT+1 2014 : -adobe-times-medium-i-normal--17-120-100-100-p-84-iso8859-4
Sun Oct 26 11:40:52 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-80-iso8859-16
Mon Oct 27 03:30:46 GMT+1 2014 : -schumacher-clean-bold-r-normal--10-100-75-75-c-80-iso646.1991-irv
Mo 27. Okt 11:23:15 GMT+1 2014 : -adobe-helvetica-bold-o-normal--8-80-75-75-p-50-iso8859-15
Tue Oct 28 08:31:30 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--11-80-100-100-p-60-iso8859-1
Tue Oct 28 10:18:47 GMT+1 2014 : -adobe-helvetica-medium-r-normal--20-140-100-100-p-100-iso10646-1
Tue Oct 28 10:32:37 GMT+1 2014 : -bitstream-charter-bold-i-normal--19-140-100-100-p-117-iso8859-1
Tue Oct 28 10:48:03 GMT+1 2014 : lucidasans-bold-12
Tue Oct 28 12:43:47 GMT+1 2014 : -adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-2
Tue Oct 28 23:03:19 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--14-140-75-75-p-80-iso8859-3
Di 28. Okt 23:06:46 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-20-140-100-100-p-114-iso8859-4
Di 28. Okt 23:17:08 GMT+1 2014 : -adobe-times-bold-i-normal--20-140-100-100-p-98-iso8859-2
Di 28. Okt 23:20:09 GMT+1 2014 : -adobe-utopia-bold-i-normal--25-180-100-100-p-139-iso8859-3
Di 28. Okt 23:36:01 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-26-190-100-100-m-159-iso10646-1
Mi 29. Okt 01:15:15 GMT+1 2014 : -adobe-helvetica-medium-r-normal--20-140-100-100-p-100-iso8859-15
Wed Oct 29 02:39:34 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-12-120-75-75-p-71-iso8859-3
Mi 29. Okt 14:17:41 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-18-180-75-75-m-110-iso8859-15
Wed Oct 29 22:08:06 GMT+1 2014 : 6x13bold
Fri Oct 31 16:12:35 GMT+1 2014 : -adobe-utopia-regular-r-normal--19-180-75-75-p-101-iso8859-9
Sa 1. Nov 03:22:04 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--20-140-100-100-p-104-iso8859-10
So 2. Nov 01:59:31 GMT+1 2014 : -misc-fixed-medium-r-normal--13-120-75-75-c-70-iso8859-9
Sat Nov  8 18:39:09 GMT+1 2014 : -adobe-courier-bold-r-normal--17-120-100-100-m-100-iso8859-2
Sat Nov  8 21:54:01 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--14-100-100-100-p-88-iso8859-10
Sun Nov  9 02:46:30 GMT+1 2014 : -b&h-luxi serif-medium-o-normal--0-0-0-0-p-0-iso8859-10
So 9. Nov 13:41:53 GMT+1 2014 : -adobe-times-medium-r-normal--0-0-75-75-p-0-iso8859-4
Sun Nov  9 15:06:21 GMT+1 2014 : -adobe-courier-bold-r-normal--12-120-75-75-m-70-iso8859-13
Mon Nov 10 03:55:55 GMT+1 2014 : -adobe-utopia-regular-i-normal--14-100-100-100-p-74-iso8859-1
Mon Nov 10 11:41:20 GMT+1 2014 : -misc-serto batnan-bold-r-normal--0-0-0-0-p-0-iso10646-1
Mon Nov 10 19:10:42 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-14-140-75-75-m-90-iso10646-1
Mon Nov 10 19:47:56 GMT+1 2014 : -b&h-luxi sans-medium-r-normal--0-0-0-0-p-0-iso8859-2
Mo 10. Nov 20:17:54 GMT+1 2014 : -misc-fixed-bold-r-normal--0-0-75-75-c-0-iso8859-9
Mon Nov 10 20:49:55 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--0-0-100-100-p-0-iso8859-3
Mon Nov 10 21:11:28 GMT+1 2014 : -adobe-times-bold-i-normal--0-0-100-100-p-0-iso10646-1
Mon Nov 10 21:23:54 GMT+1 2014 : -adobe-courier-medium-o-normal--34-240-100-100-m-200-iso8859-15
Mon Nov 10 22:57:20 GMT+1 2014 : -adobe-times-medium-r-normal--20-140-100-100-p-96-iso8859-14
Di 11. Nov 11:04:59 GMT+1 2014 : -adobe-helvetica-bold-r-normal--20-140-100-100-p-105-iso8859-13
Di 11. Nov 11:33:50 GMT+1 2014 : -adobe-helvetica-bold-r-normal--8-80-75-75-p-50-iso8859-15
Tue Nov 11 13:14:43 GMT+1 2014 : -adobe-utopia-regular-r-normal--33-240-100-100-p-180-iso8859-9
Tue Nov 11 14:35:42 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--11-80-100-100-p-60-iso8859-9
Tue Nov 11 18:52:04 GMT+1 2014 : -adobe-utopia-bold-r-normal--19-140-100-100-p-108-iso8859-13
Tue Nov 11 19:23:36 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--12-110-75-75-c-60-iso8859-5
Tue Nov 11 20:17:28 GMT+1 2014 : -adobe-times-medium-i-normal--25-180-100-100-p-125-iso8859-15
Di 11. Nov 21:34:55 GMT+1 2014 : -adobe-helvetica-medium-o-normal--0-0-75-75-p-0-iso8859-4
Tue Nov 11 21:53:45 GMT+1 2014 : -adobe-courier-medium-r-normal--12-120-75-75-m-70-iso8859-1
Tue Nov 11 22:15:15 GMT+1 2014 : -ibm-courier-bold-r-normal--0-0-0-0-m-0-iso8859-3
Tue Nov 11 22:27:09 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--14-100-100-100-p-88-iso8859-10
Wed Nov 12 00:16:10 GMT+1 2014 : -adobe-courier-medium-r-normal--11-80-100-100-m-60-iso10646-1
Wed Nov 12 10:20:41 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-100-100-c-0-iso10646-1
Mi 12. Nov 10:35:03 GMT+1 2014 : -adobe-utopia-regular-r-normal--10-100-75-75-p-56-iso8859-9
Mi 12. Nov 10:42:53 GMT+1 2014 : -adobe-utopia-regular-r-normal--19-140-100-100-p-105-iso8859-4
Mi 12. Nov 11:54:54 GMT+1 2014 : -misc-fixed-medium-o-normal--0-0-75-75-c-0-iso8859-16
Mi 12. Nov 11:57:52 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-20-140-100-100-p-127-iso8859-15
Mi 12. Nov 12:02:28 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-17-120-100-100-p-97-iso8859-4
Mi 12. Nov 12:03:46 GMT+1 2014 : -adobe-times-bold-r-normal--34-240-100-100-p-177-iso8859-13
Mi 12. Nov 12:05:10 GMT+1 2014 : -misc-fixed-bold-r-normal--18-120-100-100-c-90-iso8859-1
Wed Nov 12 15:03:01 GMT+1 2014 : -adobe-times-bold-i-normal--12-120-75-75-p-68-iso10646-1
Wed Nov 12 19:37:35 GMT+1 2014 : -misc-fixed-bold-r-normal--18-120-100-100-c-90-iso8859-7
Wed Nov 12 20:24:12 GMT+1 2014 : -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-11
Mi 12. Nov 20:41:14 GMT+1 2014 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-2
Mi 12. Nov 21:34:50 GMT+1 2014 : -adobe-courier-bold-r-normal--0-0-75-75-m-0-iso8859-9
Mi 12. Nov 21:44:16 GMT+1 2014 : -mutt-clearlyu pua-medium-r-normal--17-120-100-100-p-110-iso10646-1
Wed Nov 12 22:03:49 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-34-240-100-100-p-216-iso8859-14
Thu Nov 13 01:43:39 GMT+1 2014 : -adobe-helvetica-medium-o-normal--0-0-75-75-p-0-iso8859-4
Thu Nov 13 15:07:08 GMT+1 2014 : -adobe-utopia-regular-i-normal--25-180-100-100-p-134-iso8859-3
Do 13. Nov 15:50:54 GMT+1 2014 : -adobe-courier-bold-o-normal--8-80-75-75-m-50-iso8859-15
Sat Nov 15 01:10:54 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-100-100-c-0-iso8859-1
Sat Nov 15 02:57:31 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-9
Sat Nov 15 03:57:49 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--26-190-100-100-p-148-iso8859-9
Sat Nov 15 04:18:38 GMT+1 2014 : -adobe-times-bold-r-normal--12-120-75-75-p-67-iso8859-9
Sat Nov 15 05:35:50 GMT+1 2014 : -bitstream-bitstream charter-bold-i-normal--0-0-0-0-p-0-iso10646-1
Sat Nov 15 14:06:17 GMT+1 2014 : -schumacher-clean-medium-r-normal--12-120-75-75-c-60-iso8859-10
Sun Nov 16 21:28:54 GMT+1 2014 : olglyph-19
Mon Nov 17 16:32:56 GMT+1 2014 : -adobe-helvetica-bold-r-normal--0-0-75-75-p-0-iso8859-14
Mon Nov 17 17:14:49 GMT+1 2014 : -sony-fixed-medium-r-normal--16-150-75-75-c-80-iso8859-1
Fri Nov 21 21:16:12 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-10-100-75-75-m-60-iso8859-2
Di 25. Nov 16:20:50 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--10-100-75-75-p-57-iso8859-4
Mi 26. Nov 19:50:11 GMT+1 2014 : hanzigb16st
Mi 26. Nov 20:05:48 GMT+1 2014 : -adobe-utopia-regular-i-normal--25-240-75-75-p-133-iso8859-2
Thu Nov 27 01:03:55 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-80-iso8859-3
Thu Nov 27 13:26:57 GMT+1 2014 : -adobe-times-bold-r-normal--20-140-100-100-p-100-iso8859-14
Thu Nov 27 17:15:27 GMT+1 2014 : -misc-fixed-bold-r-normal--0-0-100-100-c-0-iso8859-14
Thu Nov 27 21:08:59 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-14-100-100-100-m-80-iso8859-15
Fri Nov 28 00:22:44 GMT+1 2014 : -b&h-luxi sans-medium-o-normal--0-0-0-0-p-0-iso8859-1
Fri Nov 28 11:38:34 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--12-120-75-75-p-77-iso8859-10
Fri Nov 28 12:15:58 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--17-120-100-100-p-92-iso8859-2
Fri Nov 28 20:27:18 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--14-100-100-100-p-80-iso10646-1
Fri Nov 28 23:30:21 GMT+1 2014 : -adobe-times-medium-r-normal--17-120-100-100-p-84-iso8859-2
Sun Nov 30 14:25:28 GMT+1 2014 : -adobe-times-bold-i-normal--14-100-100-100-p-77-iso8859-13
Sun Nov 30 20:04:18 GMT+1 2014 : -adobe-times-bold-r-normal--17-120-100-100-p-88-iso8859-2
Sun Nov 30 22:35:14 GMT+1 2014 : -adobe-utopia-regular-r-normal--15-140-75-75-p-79-iso10646-1
Mon Dec  1 03:56:43 GMT+1 2014 : -adobe-utopia-regular-i-normal--14-100-100-100-p-74-iso8859-10
Mon Dec  1 04:23:32 GMT+1 2014 : -adobe-courier-medium-o-normal--20-140-100-100-m-110-iso10646-1
Mon Dec  1 06:05:46 GMT+1 2014 : -adobe-times-bold-i-normal--18-180-75-75-p-98-iso8859-10
Fri Dec  5 07:01:26 GMT+1 2014 : -bitstream-charter-bold-i-normal--15-140-75-75-p-93-iso8859-1
Fri Dec  5 09:06:34 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-20-140-100-100-p-127-iso8859-10
Fri Dec  5 10:45:16 GMT+1 2014 : -adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-2
Fri Dec  5 12:13:12 GMT+1 2014 : -b&h-lucidabright-medium-i-normal--19-190-75-75-p-109-iso8859-9
Mon Dec  8 22:16:54 GMT+1 2014 : -adobe-courier-medium-r-normal--18-180-75-75-m-110-iso8859-10
Mon Dec  8 23:37:58 GMT+1 2014 : -adobe-utopia-bold-i-normal--0-0-100-100-p-0-iso8859-9
Tue Dec  9 00:56:28 GMT+1 2014 : -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-9
Tue Dec  9 01:16:22 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--0-0-100-100-p-0-iso8859-3
Tue Dec  9 01:47:47 GMT+1 2014 : -bitstream-bitstream charter-medium-i-normal--0-0-0-0-p-0-iso10646-1
Tue Dec  9 07:29:15 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--18-180-75-75-p-103-iso8859-4
Wed Dec 10 02:42:04 GMT+1 2014 : -schumacher-clean-medium-r-normal--10-100-75-75-c-80-iso646.1991-irv
Thu Dec 11 01:59:41 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--20-140-100-100-p-113-iso10646-1
Thu Dec 11 02:23:16 GMT+1 2014 : -adobe-times-medium-i-normal--17-120-100-100-p-84-iso8859-9
Thu Dec 11 02:46:00 GMT+1 2014 : -adobe-helvetica-medium-r-normal--14-100-100-100-p-76-iso8859-3
Thu Dec 11 03:51:03 GMT+1 2014 : -adobe-helvetica-medium-r-normal--14-100-100-100-p-76-iso8859-4
Thu Dec 11 05:33:49 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--17-120-100-100-p-92-iso8859-15
Thu Dec 11 06:54:59 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--8-80-75-75-p-45-iso8859-2
Thu Dec 11 07:17:56 GMT+1 2014 : -adobe-helvetica-bold-o-normal--14-100-100-100-p-82-iso10646-1
Thu Dec 11 07:39:14 GMT+1 2014 : lucidasans-bold-18
Thu Dec 11 08:11:04 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--14-140-75-75-p-80-iso8859-13
Thu Dec 11 09:22:59 GMT+1 2014 : -adobe-helvetica-medium-o-normal--25-180-100-100-p-130-iso8859-15
Thu Dec 11 23:53:40 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--11-80-100-100-p-66-iso8859-10
Sat Dec 13 01:57:13 GMT+1 2014 : -sun-open look glyph-----19-190-75-75-p-154-sunolglyph-1
Sat Dec 13 21:07:28 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-11-80-100-100-p-62-iso8859-14
Sun Dec 14 06:12:05 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--10-100-75-75-p-60-iso8859-2
Sun Dec 14 09:39:37 GMT+1 2014 : -adobe-helvetica-medium-r-normal--17-120-100-100-p-88-iso8859-10
Tue Dec 16 08:45:33 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-26-190-100-100-p-166-iso8859-4
Di 16. Dez 13:48:31 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-34-240-100-100-m-200-iso8859-13
Tue Dec 16 15:03:09 GMT+1 2014 : -misc-fixed-medium-o-semicondensed--0-0-75-75-c-0-iso8859-16
Tue Dec 16 15:09:34 GMT+1 2014 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-9
Tue Dec 16 17:54:41 GMT+1 2014 : -adobe-times-bold-r-normal--12-120-75-75-p-67-iso10646-1
Wed Dec 17 14:53:11 GMT+1 2014 : -schumacher-clean-medium-r-normal--12-120-75-75-c-60-iso10646-1
Thu Dec 18 12:39:18 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-26-190-100-100-p-147-iso8859-4
Fri Dec 19 21:05:55 GMT+1 2014 : -adobe-helvetica-bold-o-normal--0-0-75-75-p-0-iso8859-13
Fri Dec 19 21:22:07 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-15
Fri Dec 19 21:45:20 GMT+1 2014 : -schumacher-clean-medium-r-normal--12-120-75-75-c-60-iso8859-4
Fri Dec 19 21:45:50 GMT+1 2014 : -adobe-utopia-bold-i-normal--15-140-75-75-p-82-iso8859-2
Fri Dec 19 22:08:12 GMT+1 2014 : -adobe-times-medium-i-normal--10-100-75-75-p-52-iso8859-14
Sat Dec 20 06:07:22 GMT+1 2014 : -misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-11
Sat Dec 20 18:23:54 GMT+1 2014 : -adobe-helvetica-bold-o-normal--25-180-100-100-p-138-iso8859-10
Sat Dec 20 23:10:35 GMT+1 2014 : -adobe-utopia-bold-i-normal--12-120-75-75-p-70-iso8859-3
Sat Dec 20 23:32:23 GMT+1 2014 : lucidasans-12
Sa 20. Dez 23:39:37 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--17-120-100-100-p-92-iso8859-15
Sa 20. Dez 23:40:18 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--34-240-100-100-p-193-iso8859-9
Sa 20. Dez 23:41:50 GMT+1 2014 : -misc-fixed-bold-r-normal--0-0-100-100-c-0-iso8859-15
Sa 20. Dez 23:42:35 GMT+1 2014 : -adobe-utopia-bold-i-normal--33-240-100-100-p-186-iso8859-1
Sa 20. Dez 23:43:41 GMT+1 2014 : -adobe-times-medium-r-normal--14-140-75-75-p-74-iso8859-15
Sun Dec 21 05:51:22 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--0-0-75-75-p-0-iso8859-14
Sun Dec 21 05:52:36 GMT+1 2014 : -adobe-helvetica-medium-o-normal--20-140-100-100-p-98-iso8859-15
Sun Dec 21 08:16:26 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-18-180-75-75-p-119-iso8859-9
Sun Dec 21 08:16:39 GMT+1 2014 : -b&h-lucidabright-demibold-i-normal--34-240-100-100-p-203-iso8859-2
Sun Dec 21 08:17:09 GMT+1 2014 : -b&h-luxi serif-bold-r-normal--0-0-0-0-p-0-iso8859-4
So 21. Dez 13:09:01 GMT+1 2014 : -adobe-utopia-bold-r-normal--12-120-75-75-p-70-iso8859-15
So 21. Dez 13:20:07 GMT+1 2014 : -adobe-utopia-bold-r-normal--33-240-100-100-p-186-iso8859-2
So 21. Dez 13:33:03 GMT+1 2014 : -b&h-luxi mono-bold-r-normal--0-0-0-0-m-0-iso8859-9
So 21. Dez 13:45:07 GMT+1 2014 : -adobe-new century schoolbook-medium-i-normal--34-240-100-100-p-182-iso8859-4
So 21. Dez 14:11:45 GMT+1 2014 : -misc-fixed-medium-r-normal--20-140-100-100-c-100-iso8859-1
So 21. Dez 14:20:52 GMT+1 2014 : -adobe-utopia-bold-i-normal--33-240-100-100-p-186-iso8859-9
So 21. Dez 14:31:34 GMT+1 2014 : -adobe-helvetica-medium-r-normal--11-80-100-100-p-56-iso8859-4
So 21. Dez 15:09:11 GMT+1 2014 : -mutt-clearlyu-medium-r-normal--17-120-100-100-p-123-iso10646-1
Sun Dec 21 15:58:50 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--12-120-75-75-p-77-iso8859-2
Sun Dec 21 20:35:43 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-18-180-75-75-p-119-iso8859-13
Mon Dec 22 11:29:54 GMT+1 2014 : -adobe-helvetica-bold-o-normal--24-240-75-75-p-138-iso8859-3
Di 23. Dez 06:42:40 GMT+1 2014 : -schumacher-clean-bold-r-normal--12-120-75-75-c-60-iso646.1991-irv
Tue Dec 23 11:32:05 GMT+1 2014 : -schumacher-clean-medium-r-normal--16-160-75-75-c-80-iso646.1991-irv
Tue Dec 23 14:17:35 GMT+1 2014 : -adobe-utopia-bold-i-normal--19-140-100-100-p-109-iso8859-13
Tue Dec 23 15:29:08 GMT+1 2014 : -misc-fixed-medium-r-normal--15-140-75-75-c-90-iso8859-15
Di 23. Dez 15:31:15 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--0-0-100-100-p-0-iso8859-1
Tue Dec 23 17:37:45 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-18-180-75-75-p-119-iso8859-1
Tue Dec 23 19:36:59 GMT+1 2014 : -b&h-lucida-bold-i-normal-sans-24-240-75-75-p-151-iso10646-1
Di 23. Dez 20:17:45 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--17-120-100-100-p-99-iso8859-3
Di 23. Dez 20:26:32 GMT+1 2014 : -adobe-times-medium-r-normal--12-120-75-75-p-64-iso8859-2
Tue Dec 23 21:20:37 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-20-140-100-100-m-120-iso8859-4
Mi 24. Dez 07:57:50 GMT+1 2014 : -adobe-times-bold-r-normal--0-0-75-75-p-0-iso10646-1
Mi 24. Dez 08:36:36 GMT+1 2014 : -misc-fixed-medium-o-normal--13-120-75-75-c-70-iso10646-1
Mi 24. Dez 08:43:45 GMT+1 2014 : -adobe-helvetica-medium-r-normal--24-240-75-75-p-130-iso8859-15
Mi 24. Dez 08:51:50 GMT+1 2014 : -adobe-courier-medium-r-normal--10-100-75-75-m-60-iso8859-10
Mi 24. Dez 09:02:27 GMT+1 2014 : -adobe-courier-medium-o-normal--12-120-75-75-m-70-iso8859-2
Wed Dec 24 09:29:50 GMT+1 2014 : -adobe-times-medium-i-normal--8-80-75-75-p-42-iso8859-14
Mi 24. Dez 09:51:41 GMT+1 2014 : -adobe-courier-medium-r-normal--14-140-75-75-m-90-iso8859-13
Mi 24. Dez 09:55:45 GMT+1 2014 : -adobe-helvetica-medium-o-normal--11-80-100-100-p-57-iso8859-1
Mi 24. Dez 09:58:06 GMT+1 2014 : -misc-fixed-medium-r-normal--0-0-75-75-c-0-iso10646-1
Mi 24. Dez 10:06:49 GMT+1 2014 : -b&h-lucidabright-medium-r-normal--19-190-75-75-p-109-iso8859-9
Mi 24. Dez 10:09:03 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-20-140-100-100-m-120-iso8859-15
Mi 24. Dez 10:12:03 GMT+1 2014 : -adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-9
Mi 24. Dez 10:20:31 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--14-140-75-75-p-88-iso8859-4
Mi 24. Dez 10:27:00 GMT+1 2014 : -adobe-new century schoolbook-bold-r-normal--17-120-100-100-p-99-iso8859-4
Mi 24. Dez 10:30:38 GMT+1 2014 : -misc-fixed-medium-r-normal--14-130-75-75-c-70-jisx0201.1976-0
Mi 24. Dez 11:06:07 GMT+1 2014 : -adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-3
Mi 24. Dez 11:39:32 GMT+1 2014 : -adobe-helvetica-medium-r-normal--24-240-75-75-p-130-iso8859-1
Mi 24. Dez 16:51:10 GMT+1 2014 : -adobe-new century schoolbook-bold-i-normal--0-0-75-75-p-0-iso8859-13
Mi 24. Dez 17:06:59 GMT+1 2014 : -adobe-helvetica-medium-o-normal--14-140-75-75-p-78-iso8859-4
Mi 24. Dez 17:26:46 GMT+1 2014 : -adobe-helvetica-medium-o-normal--18-180-75-75-p-98-iso10646-1
Thu Dec 25 11:18:42 GMT+1 2014 : -adobe-courier-medium-r-normal--0-0-100-100-m-0-iso8859-10
Thu Dec 25 11:26:15 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--24-240-75-75-p-137-iso8859-15
Do 25. Dez 18:16:13 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-0-0-100-100-p-0-iso8859-3
Thu Dec 25 20:08:55 GMT+1 2014 : -adobe-utopia-bold-r-normal--17-120-100-100-p-93-iso8859-10
Do 25. Dez 20:30:41 GMT+1 2014 : -bitstream-charter-medium-r-normal--0-0-75-75-p-0-iso8859-1
Fri Dec 26 18:46:43 GMT+1 2014 : -b&h-lucida-medium-i-normal-sans-8-80-75-75-p-45-iso8859-14
Fri Dec 26 21:08:09 GMT+1 2014 : -misc-fixed-medium-r-normal--13-120-75-75-c-70-iso8859-8
Sat Dec 27 17:07:38 GMT+1 2014 : -adobe-utopia-regular-r-normal--33-240-100-100-p-180-iso10646-1
Sa 27. Dez 17:09:16 GMT+1 2014 : -adobe-helvetica-medium-o-normal--20-140-100-100-p-98-iso8859-10
Sun Dec 28 15:09:01 GMT+1 2014 : -bitstream-charter-bold-r-normal--17-120-100-100-p-107-iso8859-1
Sun Dec 28 15:31:07 GMT+1 2014 : -b&h-lucida-medium-r-normal-sans-24-240-75-75-p-136-iso8859-4
Sun Dec 28 15:43:21 GMT+1 2014 : -b&h-lucidatypewriter-medium-r-normal-sans-26-190-100-100-m-159-iso8859-4
Sun Dec 28 17:42:13 GMT+1 2014 : -misc-fixed-medium-r-normal--10-100-75-75-c-60-iso8859-10
Sun Dec 28 20:25:07 GMT+1 2014 : -adobe-utopia-regular-r-normal--25-240-75-75-p-135-iso8859-4
Sun Dec 28 22:43:50 GMT+1 2014 : -b&h-lucidabright-demibold-r-normal--12-120-75-75-p-71-iso8859-14
Mon Dec 29 13:19:07 GMT+1 2014 : -b&h-lucidatypewriter-bold-r-normal-sans-11-80-100-100-m-70-iso10646-1
Mon Dec 29 14:44:42 GMT+1 2014 : -b&h-lucida-bold-r-normal-sans-0-0-75-75-p-0-iso8859-15
Mon Dec 29 15:31:57 GMT+1 2014 : -misc-fixed-medium-r-normal--13-120-75-75-c-80-iso8859-8
Wed Dec 31 13:51:56 GMT+1 2014 : -adobe-new century schoolbook-medium-r-normal--17-120-100-100-p-91-iso8859-2
Thu Jan  1 16:02:35 GMT+1 2015 : -schumacher-clean-medium-r-normal--12-120-75-75-c-60-iso8859-16
Thu Jan  1 23:07:26 GMT+1 2015 : -adobe-helvetica-bold-o-normal--11-80-100-100-p-60-iso8859-3
Fri Jan  2 20:01:39 GMT+1 2015 : -adobe-times-medium-r-normal--0-0-75-75-p-0-iso8859-15
Sat Jan  3 18:29:06 GMT+1 2015 : -b&h-lucidatypewriter-medium-r-normal-sans-19-190-75-75-m-110-iso8859-4
Sun Jan  4 10:29:39 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--17-120-100-100-p-99-iso10646-1
Tue Jan  6 00:59:40 GMT+1 2015 : -b&h-lucidatypewriter-medium-r-normal-sans-18-180-75-75-m-110-iso8859-15
Tue Jan  6 16:40:16 GMT+1 2015 : 8x16romankana
Tue Jan  6 17:22:23 GMT+1 2015 : -adobe-times-bold-r-normal--11-80-100-100-p-57-iso8859-10
Tue Jan  6 22:00:27 GMT+1 2015 : -b&h-lucidabright-demibold-i-normal--14-140-75-75-p-84-iso8859-2
Wed Jan  7 03:34:50 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--14-140-75-75-p-87-iso8859-9
Wed Jan  7 13:21:55 GMT+1 2015 : -b&h-lucidatypewriter-medium-r-normal-sans-20-140-100-100-m-120-iso10646-1
Thu Jan  8 20:45:39 GMT+1 2015 : -mutt-clearlyu alternate glyphs-medium-r-normal--0-0-100-100-p-0-iso10646-1
Thu Jan  8 21:48:11 GMT+1 2015 : 7x13
Fri Jan  9 03:25:10 GMT+1 2015 : -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-10
Sa 10. Jan 07:48:18 GMT+1 2015 : -adobe-utopia-bold-i-normal--0-0-0-0-p-0-iso8859-1
So 11. Jan 11:18:11 GMT+1 2015 : -adobe-courier-bold-r-normal--11-80-100-100-m-60-iso10646-1
So 11. Jan 15:22:25 GMT+1 2015 : -adobe-utopia-regular-i-normal--15-140-75-75-p-79-iso10646-1
So 11. Jan 15:30:07 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--0-0-100-100-p-0-iso8859-4
Mo 12. Jan 18:24:34 GMT+1 2015 : -b&h-lucida-medium-i-normal-sans-17-120-100-100-p-97-iso8859-14
Di 13. Jan 14:29:48 GMT+1 2015 : -misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-8
Wed Jan 14 18:39:38 GMT+1 2015 : -b&h-lucida-bold-r-normal-sans-25-180-100-100-p-158-iso8859-4
Sun Jan 18 14:51:03 GMT+1 2015 : -adobe-utopia-regular-r-normal--10-100-75-75-p-56-iso8859-10
So 18. Jan 14:58:01 GMT+1 2015 : -b&h-lucida-medium-r-normal-sans-26-190-100-100-p-147-iso8859-3
Fri Jan 23 21:14:58 GMT+1 2015 : -b&h-lucidatypewriter-bold-r-normal-sans-0-0-75-75-m-0-iso8859-9
Fri Jan 23 21:16:27 GMT+1 2015 : -adobe-new century schoolbook-bold-i-normal--18-180-75-75-p-111-iso8859-1
Sat Jan 24 15:34:53 GMT+1 2015 : -adobe-helvetica-medium-o-normal--0-0-75-75-p-0-iso10646-1
Mon Jan 26 12:37:03 GMT+1 2015 : -adobe-courier-bold-o-normal--20-140-100-100-m-110-iso8859-13
Mon Jan 26 13:16:19 GMT+1 2015 : -adobe-utopia-bold-i-normal--25-240-75-75-p-140-iso8859-4
Mon Jan 26 13:42:53 GMT+1 2015 : -adobe-courier-bold-o-normal--34-240-100-100-m-200-iso8859-2
Wed Feb 18 18:10:10 GMT+1 2015 : -b&h-lucida-bold-i-normal-sans-18-180-75-75-p-119-iso10646-1
Wed Feb 18 19:39:01 GMT+1 2015 : -b&h-lucidatypewriter-medium-r-normal-sans-8-80-75-75-m-50-iso8859-9
Wed Feb 18 19:53:29 GMT+1 2015 : -b&h-luxi sans-medium-o-normal--0-0-0-0-p-0-iso8859-4
Wed Feb 18 19:57:51 GMT+1 2015 : -adobe-new century schoolbook-medium-i-normal--10-100-75-75-p-60-iso8859-15
Wed Feb 18 19:59:30 GMT+1 2015 : -b&h-lucidatypewriter-medium-r-normal-sans-0-0-75-75-m-0-iso8859-4
Fri Feb 20 17:17:49 GMT+1 2015 : -b&h-lucidabright-demibold-r-normal--8-80-75-75-p-47-iso8859-10
Mon Mar  2 23:32:52 GMT+1 2015 : r16
Thu Mar  5 17:39:14 GMT+1 2015 : -b&h-luxi mono-bold-r-normal--0-0-0-0-m-0-iso8859-3
Fri Mar  6 21:58:51 GMT+1 2015 : -b&h-lucidabright-medium-i-normal--26-190-100-100-p-148-iso8859-4
Fri Mar 13 10:49:27 GMT+1 2015 : -b&h-luxi mono-medium-r-normal--0-0-0-0-m-0-iso8859-1
Thu Mar 19 02:16:28 GMT+1 2015 : -adobe-helvetica-bold-r-normal--8-80-75-75-p-50-iso10646-1
Do 19. Mär 02:56:50 GMT+1 2015 : -misc-fixed-medium-o-normal--13-120-75-75-c-80-iso8859-3
Thu Mar 19 11:20:16 GMT+1 2015 : -adobe-times-bold-r-normal--0-0-100-100-p-0-iso8859-14
Thu Mar 19 14:21:38 GMT+1 2015 : -misc-fixed-medium-r-normal--14-130-75-75-c-70-iso8859-16
Fri Mar 20 16:39:30 GMT+1 2015 : -b&h-lucida-bold-r-normal-sans-0-0-75-75-p-0-iso8859-14
Sat Mar 21 15:59:44 GMT+1 2015 : -adobe-utopia-regular-i-normal--0-0-100-100-p-0-iso8859-15
Sun Mar 22 15:49:20 GMT+1 2015 : -b&h-lucidabright-medium-i-normal--18-180-75-75-p-102-iso8859-9
Sun Mar 22 21:08:05 GMT+1 2015 : -b&h-lucidabright-demibold-i-normal--12-120-75-75-p-72-iso8859-4
Sun Mar 22 22:20:56 GMT+1 2015 : -b&h-luxi sans-medium-r-normal--0-0-0-0-p-0-iso8859-2
Mon Mar 23 10:57:03 GMT+1 2015 : -b&h-lucida-medium-i-normal-sans-0-0-100-100-p-0-iso10646-1
Tue Mar 24 01:06:03 GMT+1 2015 : -misc-fixed-medium-r-normal--13-120-75-75-c-70-iso8859-16
Fri Mar 27 03:36:08 GMT+1 2015 : -adobe-new century schoolbook-medium-r-normal--14-100-100-100-p-82-iso8859-2
Mon Mar 30 01:39:30 GMT+1 2015 : -misc-fixed-bold-r-normal--0-0-75-75-c-0-iso8859-2
Mon Mar 30 22:24:34 GMT+1 2015 : -mutt-clearlyu-medium-r-normal--17-120-100-100-p-123-iso10646-1
Sat Apr 11 16:42:46 GMT+1 2015 : -adobe-new century schoolbook-medium-i-normal--24-240-75-75-p-136-iso8859-9
Sat Apr 11 17:38:57 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--10-100-75-75-p-66-iso8859-4
Sat Apr 11 18:17:31 GMT+1 2015 : -misc-fixed-medium-r-normal--15-140-75-75-c-90-iso8859-13
Sat Apr 11 18:47:00 GMT+1 2015 : -adobe-utopia-bold-r-normal--17-120-100-100-p-93-iso8859-15
Tue Apr 14 20:50:22 GMT+1 2015 : -adobe-courier-bold-r-normal--10-100-75-75-m-60-iso10646-1
Wed Apr 15 14:45:27 GMT+1 2015 : -b&h-luxi serif-bold-o-normal--0-0-0-0-p-0-iso10646-1
Thu Apr 16 11:57:19 GMT+1 2015 : -b&h-lucida-bold-r-normal-sans-0-0-100-100-p-0-iso8859-4
So 26. Apr 15:47:28 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--34-240-100-100-p-193-iso8859-9
So 26. Apr 16:10:48 GMT+1 2015 : -adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-9
Sun Apr 26 16:50:18 GMT+1 2015 : -adobe-courier-bold-o-normal--24-240-75-75-m-150-iso8859-3
Sun Apr 26 16:53:43 GMT+1 2015 : -adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-2
Sun Apr 26 17:57:35 GMT+1 2015 : -adobe-courier-medium-o-normal--34-240-100-100-m-200-iso8859-15
Sun Apr 26 18:07:58 GMT+1 2015 : -b&h-lucida-bold-r-normal-sans-0-0-100-100-p-0-iso8859-13
Sun Apr 26 19:45:07 GMT+1 2015 : -adobe-symbol-medium-r-normal--25-180-100-100-p-142-adobe-fontspecific
Do 30. Apr 21:41:19 GMT+1 2015 : -adobe-utopia-bold-r-normal--17-120-100-100-p-93-iso8859-2
Fri May  1 08:34:35 GMT+1 2015 : -adobe-utopia-regular-r-normal--17-120-100-100-p-91-iso8859-1
Fri May  1 22:48:43 GMT+1 2015 : -adobe-helvetica-medium-o-normal--0-0-75-75-p-0-iso8859-2
Sat May  2 17:41:01 GMT+1 2015 : -adobe-times-medium-r-normal--11-80-100-100-p-54-iso8859-4
Sat May  2 18:28:43 GMT+1 2015 : -adobe-new century schoolbook-bold-i-normal--10-100-75-75-p-66-iso10646-1
Sat May  2 19:41:21 GMT+1 2015 : -adobe-courier-medium-r-normal--34-240-100-100-m-200-iso8859-15
Sun May  3 01:11:03 GMT+1 2015 : -b&h-lucidabright-demibold-i-normal--11-80-100-100-p-66-iso8859-4
Sun May  3 05:42:17 GMT+1 2015 : -adobe-times-medium-r-normal--17-120-100-100-p-84-iso8859-13
Sun May  3 17:46:35 GMT+1 2015 : -adobe-helvetica-medium-r-normal--25-180-100-100-p-130-iso10646-1
Mon May  4 11:44:17 GMT+1 2015 : -misc-fixed-bold-r-semicondensed--0-0-75-75-c-0-iso8859-16
Mon May  4 17:00:10 GMT+1 2015 : -adobe-new century schoolbook-bold-r-normal--14-140-75-75-p-87-iso8859-13
Mon May  4 17:02:21 GMT+1 2015 : -misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-16
Mon May  4 19:40:50 GMT+1 2015 : -adobe-new century schoolbook-medium-r-normal--14-100-100-100-p-82-iso8859-13
Tue May  5 02:51:09 GMT+1 2015 : -misc-fixed-medium-o-normal--13-120-75-75-c-70-iso8859-14
Wed May  6 10:58:19 GMT+1 2015 : -adobe-times-bold-i-normal--24-240-75-75-p-128-iso8859-4
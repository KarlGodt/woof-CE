#!/bin/bash


#bash-3.2# ./configure --help
#`configure' configures xorg-server 1.4.99.906 to adapt to many kinds of systems.
#
#Usage: ./configure [OPTION]... [VAR=VALUE]...
#
#To assign environment variables (e.g., CC, CFLAGS...), specify them as
#VAR=VALUE.  See below for descriptions of some of the useful variables.
#
#Defaults for the options are specified in brackets.
#
#Configuration:
#  -h, --help              display this help and exit
#      --help=short        display options specific to this package
#      --help=recursive    display the short help of all the included packages
#  -V, --version           display version information and exit
#  -q, --quiet, --silent   do not print `checking...' messages
#      --cache-file=FILE   cache test results in FILE [disabled]
#  -C, --config-cache      alias for `--cache-file=config.cache'
#  -n, --no-create         do not create output files
#      --srcdir=DIR        find the sources in DIR [configure dir or `..']
#
#Installation directories:
#  --prefix=PREFIX         install architecture-independent files in PREFIX
#                          [/usr/local]
#  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
#                          [PREFIX]
#
#By default, `make install' will install all the files in
#`/usr/local/bin', `/usr/local/lib' etc.  You can specify
#an installation prefix other than `/usr/local' using `--prefix',
#for instance `--prefix=$HOME'.
#
#For better control, use the options below.
#
#Fine tuning of the installation directories:
#  --bindir=DIR            user executables [EPREFIX/bin]
#  --sbindir=DIR           system admin executables [EPREFIX/sbin]
#  --libexecdir=DIR        program executables [EPREFIX/libexec]
#  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#  --libdir=DIR            object code libraries [EPREFIX/lib]
#  --includedir=DIR        C header files [PREFIX/include]
#  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#  --infodir=DIR           info documentation [DATAROOTDIR/info]
#  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#  --mandir=DIR            man documentation [DATAROOTDIR/man]
#  --docdir=DIR            documentation root [DATAROOTDIR/doc/xorg-server]
#  --htmldir=DIR           html documentation [DOCDIR]
#  --dvidir=DIR            dvi documentation [DOCDIR]
#  --pdfdir=DIR            pdf documentation [DOCDIR]
#  --psdir=DIR             ps documentation [DOCDIR]
#

DIRES='--bindir=/usr/X11R7/bin
--sbindir=/usr/sbin
--libexecdir=/usr/X11R7/libexec
--sysconfdir=/etc
--sharedstatedir=/usr/X11R7/com
--localstatedir=/var
--libdir=/usr/X11R7/lib
--includedir=/usr/X11R7/include
--oldincludedir=/usr/X11R7/include
--datarootdir=/usr/share
--datadir=/usr/share
--infodir=/usr/share/info
--localedir=/usr/share/locale
--mandir=/usr/share/man
--docdir=/usr/share/doc
--htmldir=/usr/share/html
--dvidir=/usr/share/dvi
--pdfdir=/usr/share/pdf
--psdir=/usr/share/ps
'

#Program names:
#  --program-prefix=PREFIX            prepend PREFIX to installed program names
#  --program-suffix=SUFFIX            append SUFFIX to installed program names
#  --program-transform-name=PROGRAM   run sed PROGRAM on installed program names
#
#System types:
#  --build=BUILD     configure for building on BUILD [guessed]
#  --host=HOST       cross-compile to build programs to run on HOST [BUILD]
#
BUILD='--build=i486-pc-linux-gnu'
#Optional Features:
#  --disable-option-checking  ignore unrecognized --enable/--with options
#  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
#  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
#  --enable-maintainer-mode  enable make rules and dependencies not useful
#			  (and sometimes confusing) to the casual installer
#  --disable-dependency-tracking  speeds up one-time build
#  --enable-dependency-tracking   do not reject slow dependency extractors
#  --enable-static[=PKGS]  build static libraries [default=no]
#  --enable-shared[=PKGS]  build shared libraries [default=yes]
#  --enable-fast-install[=PKGS]
#                          optimize for fast installation [default=yes]
#  --disable-libtool-lock  avoid locking (might break parallel builds)
#  --disable-largefile     omit support for large files
#  --enable-werror         Treat warnings as errors (default: disabled)
#  --enable-debug          Enable debugging (default: disabled)
#  --enable-builddocs      Build docs (default: disabled)
#  --enable-install-libxf86config
#                          Install libxf86config (default: disabled)
#  --enable-builtin-fonts  Use only built-in fonts (default: use external)
#  --enable-null-root-cursor
#                          Use an empty root cursor (default: use core cursor)
#  --enable-aiglx          Build accelerated indirect GLX (default: enabled)
#  --enable-glx-tls        Build GLX with TLS support (default: disabled)
#  --disable-registry      Build string registry module (default: enabled)
#  --disable-composite     Build Composite extension (default: enabled)
#  --disable-shm           Build SHM extension (default: enabled)
#  --disable-xres          Build XRes extension (default: enabled)
#  --disable-xtrap         Build XTrap extension (default: enabled)
#  --disable-record        Build Record extension (default: disabled)
#  --disable-xv            Build Xv extension (default: enabled)
#  --disable-xvmc          Build XvMC extension (default: enabled)
#  --disable-dga           Build DGA extension (default: auto)
#  --disable-screensaver   Build ScreenSaver extension (default: enabled)
#  --disable-xdmcp         Build XDMCP extension (default: auto)
#  --disable-xdm-auth-1    Build XDM-Auth-1 extension (default: auto)
#  --disable-glx           Build GLX extension (default: enabled)
#  --enable-dri            Build DRI extension (default: auto)
#  --enable-dri2           Build DRI2 extension (default: auto)
#  --disable-xinerama      Build Xinerama extension (default: enabled)
#  --disable-xf86vidmode   Build XF86VidMode extension (default: auto)
#  --disable-xf86misc      Build XF86Misc extension (default: auto)
#  --disable-xace          Build X-ACE extension (default: enabled)
#  --disable-xselinux      Build SELinux extension (default: disabled)
#  --disable-xcsecurity    Build Security extension (default: disabled)
#  --disable-appgroup      Build XC-APPGROUP extension (default: disabled)
#  --enable-xcalibrate     Build XCalibrate extension (default: disabled)
#  --enable-tslib          Build kdrive tslib touchscreen support (default:
#                          disabled)
#  --disable-xevie         Build XEvIE extension (default: enabled)
#  --disable-cup           Build TOG-CUP extension (default: enabled)
#  --disable-evi           Build Extended-Visual-Information extension
#                          (default: enabled)
#  --enable-multibuffer    Build Multibuffer extension (default: disabled)
#  --enable-fontcache      Build FontCache extension (default: disabled)
#  --disable-dbe           Build DBE extension (default: enabled)
#  --disable-xf86bigfont   Build XF86 Big Font extension (default: enabled)
#  --disable-dpms          Build DPMS extension (default: enabled)
#  --enable-config-dbus    Build D-BUS API support (default: no)
#  --disable-config-hal    Build HAL support (default: auto)
#  --enable-xfree86-utils  Build xfree86 DDX utilities (default: enabled)
#  --enable-xorg           Build Xorg server (default: auto)
#  --enable-dmx            Build DMX server (default: no)
#  --enable-xvfb           Build Xvfb server (default: yes)
#  --enable-xnest          Build Xnest server (default: auto)
#  --enable-xquartz        Build Xquartz server for OS-X (default: auto)
#  --enable-x11app         Build Apple's X11.app for Xquartz (default: auto)
#  --enable-xwin           Build XWin server (default: auto)
#  --enable-xprint         Build Xprint extension and server (default: no)
#  --enable-xgl            Build Xgl server (default: no)
#  --enable-xglx           Build Xglx xgl module (default: no)
#  --enable-xegl           Build Xegl xgl module (default: no)
#  --enable-mfb            Build legacy mono framebuffer support (default:
#                          enabled)
#  --enable-cfb            Build legacy color framebuffer support (default:
#                          enabled)
#  --enable-afb            Build legacy advanced framebuffer support (default:
#                          enabled)
#  --enable-kdrive         Build kdrive servers (default: no)
#  --enable-xephyr         Build the kdrive Xephyr server (default: auto)
#  --enable-xsdl           Build the kdrive Xsdl server (default: auto)
#  --enable-xfake          Build the kdrive 'fake' server (default: auto)
#  --enable-xfbdev         Build the kdrive framebuffer device server (default:
#                          auto)
#  --enable-kdrive-vesa    Build the kdrive VESA-based servers (default: auto)
#   --enable-freetype      Build Xprint FreeType backend (default: no)
#  --enable-install-setuid Install Xorg server as owned by root with setuid bit
#                          (default: auto)
#  --enable-secure-rpc     Enable Secure RPC
#  --enable-xorgcfg        Build xorgcfg GUI configuration utility (default:
#                          no)
#  --enable-kbd_mode       Build kbd_mode utility (default: auto)
#
#Optional Packages:
#  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
#  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
#  --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
#  --with-pic              try to use only PIC/non-PIC objects [default=use
#                          both]
#  --with-tags[=TAGS]      include additional configurations [automatic]
#  --with-dtrace=PATH      Enable dtrace probes (default: enabled if dtrace
#                          found)
#  --with-release-version=STRING
#                          Use release version string in package name
#  --with-int10=BACKEND    int10 backend: vm86, x86emu or stub
#  --with-vendor-name=VENDOR
#                          Vendor string reported by the server
#  --with-vendor-name-short=VENDOR
#                          Short version of vendor string reported by the
#                          server
#  --with-vendor-web=URL   Vendor web address reported by the server
#  --with-module-dir=DIR   Directory where modules are installed (default:
#                          $libdir/xorg/modules)
#  --with-log-dir=DIR      Directory where log files are kept (default:
#                          $localstatedir/log)
#  --with-builder-addr=ADDRESS
#                          Builder address (default:
#                          xorg@lists.freedesktop.org)
#  --with-os-name=OSNAME   Name of OS (default: output of "uname -srm")
#  --with-os-vendor=OSVENDOR
#                          Name of OS vendor
#  --with-builderstring=BUILDERSTRING
#                          Additional builder string
#  --with-fontdir=FONTDIR  Path to top level dir where fonts are installed
#                          (default: ${libdir}/X11/fonts)
#  --with-default-font-path=PATH
#                          Comma separated list of font dirs
#  --with-xkb-path=PATH    Path to XKB base dir (default: ${datadir}/X11/xkb)
#  --with-xkb-output=PATH  Path to XKB output dir (default:
#                          ${datadir}/X11/xkb/compiled)
#  --with-serverconfig-path=PATH
#                          Directory where ancillary server config files are
#                          installed (default: ${libdir}/xorg)
#  --with-apple-applications-dir=PATH
#                          Path to the Applications directory (default:
#                          /Applications/Utilities)
#  --with-launchd          Build with support for Apple's launchd (default:
#                          auto)
#  --with-launchagents-dir=PATH
#                          Path to launchd's LaunchAgents directory (default:
#                          /Library/LaunchAgents)
#  --with-mesa-source=MESA_SOURCE
#                          Path to Mesa source tree
#  --with-dri-driver-path=PATH
#                          Path to DRI drivers (default: ${libdir}/dri)
#  --with-x11app-archs=ARCHS
#                          Architectures to build X11.app for, space delimeted
#                          (default: "ppc i386")
#   --with-freetype-config=PROG
#                          Use FreeType configuration program PROG (default:
#                          auto)
#
#Some influential environment variables:
#  CC          C compiler command
#  CFLAGS      C compiler flags
#  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#              nonstandard directory <lib dir>
#  LIBS        libraries to pass to the linker, e.g. -l<library>
#  CPPFLAGS    C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#              you have headers in a nonstandard directory <include dir>
#  CCAS        assembler compiler command (defaults to CC)
#  CCASFLAGS   assembler compiler flags (defaults to CFLAGS)
#  CPP         C preprocessor
#  CXX         C++ compiler command
#  CXXFLAGS    C++ compiler flags
#  CXXCPP      C++ preprocessor
#  F77         Fortran 77 compiler command
#  FFLAGS      Fortran 77 compiler flags
#  PKG_CONFIG  path to pkg-config utility
#  YACC        The `Yet Another C Compiler' implementation to use. Defaults to
#              the first program found out of: `bison -y', `byacc', `yacc'.
#  YFLAGS      The list of arguments that will be passed by default to $YACC.
#              This script will default YFLAGS to the empty string to avoid a
#              default value of `-d' given by some make applications.
#  DBUS_CFLAGS C compiler flags for DBUS, overriding pkg-config
#  DBUS_LIBS   linker flags for DBUS, overriding pkg-config
#  HAL_CFLAGS  C compiler flags for HAL, overriding pkg-config
#  HAL_LIBS    linker flags for HAL, overriding pkg-config
#  XLIB_CFLAGS C compiler flags for XLIB, overriding pkg-config
#  XLIB_LIBS   linker flags for XLIB, overriding pkg-config
#  GL_CFLAGS   C compiler flags for GL, overriding pkg-config
#  GL_LIBS     			linker flags for GL, overriding pkg-config
#  DRIPROTO_CFLAGS 		C compiler flags for DRIPROTO, overriding pkg-config
#  DRIPROTO_LIBS 		linker flags for DRIPROTO, overriding pkg-config
#  LIBDRM_CFLAGS 		C compiler flags for LIBDRM, overriding pkg-config
#  LIBDRM_LIBS 			linker flags for LIBDRM, overriding pkg-config
#  DRI2PROTO_CFLAGS 	C compiler flags for DRI2PROTO, overriding pkg-config
#  DRI2PROTO_LIBS 		linker flags for DRI2PROTO, overriding pkg-config
#  XPRINTPROTO_CFLAGS 	C compiler flags for XPRINTPROTO, overriding pkg-config
#  XPRINTPROTO_LIBS linker flags for XPRINTPROTO, overriding pkg-config
#  XDMCP_CFLAGS 	C compiler flags for XDMCP, overriding pkg-config
#  XDMCP_LIBS  		linker flags for XDMCP, overriding pkg-config
#  XSERVERCFLAGS_CFLAGS C compiler flags for XSERVERCFLAGS, overriding pkg-config
#  XSERVERCFLAGS_LIBS 	linker flags for XSERVERCFLAGS, overriding pkg-config
#  XSERVERLIBS_CFLAGS 	C compiler flags for XSERVERLIBS, overriding pkg-config
#  XSERVERLIBS_LIBS 	linker flags for XSERVERLIBS, overriding pkg-config
#  OPENSSL_CFLAGS 	C compiler flags for OPENSSL, overriding pkg-config
#  OPENSSL_LIBS 	linker flags for OPENSSL, overriding pkg-config
#  XNESTMODULES_CFLAGS 	C compiler flags for XNESTMODULES, overriding pkg-config
#  XNESTMODULES_LIBS 	linker flags for XNESTMODULES, overriding pkg-config
#  XGLMODULES_CFLAGS 	C compiler flags for XGLMODULES, overriding pkg-config
#  XGLMODULES_LIBS 		linker flags for XGLMODULES, overriding pkg-config
#  XGLXMODULES_CFLAGS 	C compiler flags for XGLXMODULES, overriding pkg-config
#  XGLXMODULES_LIBS linker flags for XGLXMODULES, overriding pkg-config
#  PCIACCESS_CFLAGS C compiler flags for PCIACCESS, overriding pkg-config
#  PCIACCESS_LIBS 	linker flags for PCIACCESS, overriding pkg-config
#  DGA_CFLAGS  		C compiler flags for DGA, overriding pkg-config
#  DGA_LIBS    		linker flags for DGA, overriding pkg-config
#  XF86MISC_CFLAGS 		C compiler flags for XF86MISC, overriding pkg-config
#  XF86MISC_LIBS 		linker flags for XF86MISC, overriding pkg-config
#  XF86VIDMODE_CFLAGS 	C compiler flags for XF86VIDMODE, overriding pkg-config
#  XF86VIDMODE_LIBS 	linker flags for XF86VIDMODE, overriding pkg-config
#  XORG_MODULES_CFLAGS 	C compiler flags for XORG_MODULES, overriding pkg-config
#  XORG_MODULES_LIBS 	linker flags for XORG_MODULES, overriding pkg-config
#  XPRINTMODULES_CFLAGS C compiler flags for XPRINTMODULES, overriding pkg-config
#  XPRINTMODULES_LIBS 	linker flags for XPRINTMODULES, overriding pkg-config
#  FREETYPE_CFLAGS 		C compiler flags for FREETYPE, overriding pkg-config
#  FREETYPE_LIBS linker flags for FREETYPE, overriding pkg-config
#  XWINMODULES_CFLAGS 	C compiler flags for XWINMODULES, overriding pkg-config
#  XWINMODULES_LIBS 	linker flags for XWINMODULES, overriding pkg-config
#  DMXMODULES_CFLAGS 	C compiler flags for DMXMODULES, overriding pkg-config
#  DMXMODULES_LIBS linker flags for DMXMODULES, overriding pkg-config
#  XDMXCONFIG_DEP_CFLAGS 	C compiler flags for XDMXCONFIG_DEP, overriding pkg-config
#  XDMXCONFIG_DEP_LIBS 		linker flags for XDMXCONFIG_DEP, overriding pkg-config
#  DMXEXAMPLES_DEP_CFLAGS 	C compiler flags for DMXEXAMPLES_DEP, overriding pkg-config
#  DMXEXAMPLES_DEP_LIBS 	linker flags for DMXEXAMPLES_DEP, overriding pkg-config
#  DMXXMUEXAMPLES_DEP_CFLAGS C compiler flags for DMXXMUEXAMPLES_DEP, overriding pkg-config
#  DMXXMUEXAMPLES_DEP_LIBS 	linker flags for DMXXMUEXAMPLES_DEP, overriding pkg-config
#  DMXXIEXAMPLES_DEP_CFLAGS C compiler flags for DMXXIEXAMPLES_DEP, overriding pkg-config
#  DMXXIEXAMPLES_DEP_LIBS 	linker flags for DMXXIEXAMPLES_DEP, overriding pkg-config
#  XTSTEXAMPLES_DEP_CFLAGS 	C compiler flags for XTSTEXAMPLES_DEP, overriding pkg-config
#  XTSTEXAMPLES_DEP_LIBS 	linker flags for XTSTEXAMPLES_DEP, overriding pkg-config
#  XRESEXAMPLES_DEP_CFLAGS 	C compiler flags for XRESEXAMPLES_DEP, overriding pkg-config
#  XRESEXAMPLES_DEP_LIBS 	linker flags for XRESEXAMPLES_DEP, overriding pkg-config
#  X11EXAMPLES_DEP_CFLAGS 	C compiler flags for X11EXAMPLES_DEP, overriding pkg-config
#  X11EXAMPLES_DEP_LIBS 	linker flags for X11EXAMPLES_DEP, overriding pkg-config
#  XEPHYR_CFLAGS 			C compiler flags for XEPHYR, overriding pkg-config
#  XEPHYR_LIBS 	linker flags for XEPHYR, overriding pkg-config
#  TSLIB_CFLAGS C compiler flags for TSLIB, overriding pkg-config
#  TSLIB_LIBS  	linker flags for TSLIB, overriding pkg-config
#  XORGCONFIG_DEP_CFLAGS C compiler flags for XORGCONFIG_DEP, overriding pkg-config
#  XORGCONFIG_DEP_LIBS 	linker flags for XORGCONFIG_DEP, overriding pkg-config
#  XORGCFG_DEP_CFLAGS 	C compiler flags for XORGCFG_DEP, overriding pkg-config
#  XORGCFG_DEP_LIBS 	linker flags for XORGCFG_DEP, overriding pkg-config
#
#Use these variables to override the choices made by `configure' or to help
#it to find libraries and programs with nonstandard names/locations.
#
#Report bugs to <https://bugs.freedesktop.org/enter_bug.cgi?product=xorg>.
#bash-3.2#

ALL=`./configure --help`

EALL=`echo "$ALL" | sed 's#^[[:blank:]]*##' | grep '^\-\-enable\-' |awk '{print $1}' |sed 's#\=.*$##;s#\[.*$##'`
DISA=`echo "$ALL" | sed 's#^[[:blank:]]*##' | grep '^\-\-disable\-' |awk '{print $1}' |sed 's#\=.*$##;s#\[.*$##'`
WTLL=`echo "$ALL" | sed 's#^[[:blank:]]*##' | grep '^\-\-with\-' |awk '{print $1}' |sed 's#\=.*$##;s#\[.*$##'`
EALL=`echo "$EALL" |grep -vi 'FEATURE'`

echo $BUILD

echo $DIRES

echo $EALL

PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/X11R7/lib/pkgconfig
export PKG_CONFIG_PATH
./configure $BUILD $DIRES $EALL

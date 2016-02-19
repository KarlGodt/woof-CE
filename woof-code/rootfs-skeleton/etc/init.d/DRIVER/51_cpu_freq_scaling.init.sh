#!/bin/ash
#BK got this from http://murga-linux.com/puppy/viewtopic.php?t=55417&start=15
# but added test for /proc/acpi, bios-date, processor-manufacturer.
# Added extra code provided by pakt.
#100603 gamble, any CPU >=2007 can handle acpi-cpufreq, or it will fail to load.
#101014 improve test for older computers, and fix menu --well no probably not the latter.
#101114 rerwin: refine usage of dmidecode.

VERSION=2.0.0 # < 2016-02-19
VERSION=2.1.0 #add _detect_cpu_manufacturer() and list of drivers from Opera2-Dell755
              #code cleanup and typo fixes

_deprecated_early_exit__(){
#disable freq scaling for older computers...
#[ ! -d /proc/acpi ] && FLAGEXIT='yes'
if [ ! -d /proc/acpi ];then #101114
 FLAGEXIT='yes'
else
 [ `dmidecode -s "bios-release-date" | cut -f 3 -d '/' | rev | cut -c 1,2 | rev` -lt 7 ] && FLAGEXIT='yes' #<2006 100603: <2007 101014
fi
if [ "$FLAGEXIT" = "yes" ];then #101014
 exit 0
fi
}

. /etc/rc.d/f4puppy5
VERBOSE=1
echo "STATUS='$STATUS'"

# REM: Use modinfo 'driver' ie modinfo p4-clockmod
#       for info about the driver
_example_list_of_cpufreq_modules(){
cat >&1 <<EoI
kernel/drivers/cpufreq/acpi-cpufreq.ko          ## Main CPU frequency driver
kernel/drivers/cpufreq/cpufreq_conservative.ko  ##  Frequency driver for Laptop
kernel/drivers/cpufreq/cpufreq-nforce2.ko       ## nForce2 FSB changing cpufreq driver
kernel/drivers/cpufreq/cpufreq_ondemand.ko      ##  Frequency driver for Demands
kernel/drivers/cpufreq/cpufreq_performance.ko   ##  Frequency driver for Full speed
kernel/drivers/cpufreq/cpufreq_powersave.ko     ##  Frequency driver for Low speed
kernel/drivers/cpufreq/cpufreq_stats.ko         ##   A driver to export cpufreq stats through sysfs
kernel/drivers/cpufreq/e_powersaver.ko          ## VIA C7 CPU's
kernel/drivers/cpufreq/freq_table.ko            ##   CPUfreq frequency table helpers
kernel/drivers/cpufreq/gx-suspmod.ko            ## Cyrix MediaGX and NatSemi Geode
kernel/drivers/cpufreq/longhaul.ko              ## VIA Cyrix processors
kernel/drivers/cpufreq/longrun.ko               ## Transmeta Crusoe and Efficeon processors
kernel/drivers/cpufreq/mperf.ko                 ##   <?>
kernel/drivers/cpufreq/p4-clockmod.ko           ## Intel
kernel/drivers/cpufreq/pcc-cpufreq.ko           ##   Processor Clocking Control interface driver
kernel/drivers/cpufreq/powernow-k6.ko           ## AMD
kernel/drivers/cpufreq/powernow-k7.ko           ## AMD
kernel/drivers/cpufreq/powernow-k8.ko           ## AMD
kernel/drivers/cpufreq/speedstep-centrino.ko    ## Intel
kernel/drivers/cpufreq/speedstep-ich.ko         ## Intel
kernel/drivers/cpufreq/speedstep-lib.ko         ## Intel
kernel/drivers/cpufreq/speedstep-smi.ko         ## Intel

# REM: In BIOS, it may be possible to (de)activate
#       SpeedStep Technology.
#       SpeedStep Technology needs to be 'on'
#        for Dell Optiplex 745 DT
#            Dell Optiplex 755 MT
#       to enable cpu frequency scaling.
#       The Intel speedstep drivers refuse to load
#        for Core2Duo processors,
#        but the acpi-cpufreq module works.
EoI
}

_example_list_of_cpufreq_governors(){
cat >&1 <<EoI
kernel/drivers/cpufreq/cpufreq_conservative.ko
kernel/drivers/cpufreq/cpufreq_ondemand.ko
kernel/drivers/cpufreq/cpufreq_performance.ko
kernel/drivers/cpufreq/cpufreq_powersave.ko
kernel/drivers/cpufreq/cpufreq_stats.ko         ## Not a governor
kernel/drivers/cpufreq/cpufreq_userspace.ko
EoI
}

_show_hard_compiled_in_settings_ondemand(){
cat >&1 <<EoI
#define DEF_FREQUENCY_DOWN_DIFFERENTIAL     (10)
#define DEF_FREQUENCY_UP_THRESHOLD      (80)
#define DEF_SAMPLING_DOWN_FACTOR        (1)
#define MAX_SAMPLING_DOWN_FACTOR        (100000)
#define MICRO_FREQUENCY_DOWN_DIFFERENTIAL   (3)
#define MICRO_FREQUENCY_UP_THRESHOLD        (95)
#define MICRO_FREQUENCY_MIN_SAMPLE_RATE     (10000)
#define MIN_FREQUENCY_UP_THRESHOLD      (11)
#define MAX_FREQUENCY_UP_THRESHOLD      (100)
#define MIN_SAMPLING_RATE_RATIO         (2)
#define LATENCY_MULTIPLIER          (1000)
#define MIN_LATENCY_MULTIPLIER          (100)
#define TRANSITION_LATENCY_LIMIT        (10 * 1000 * 1000)
EoI
}

# REM: Available drivers
_show_available_cpufreq_drivers(){
 modprobe -l | grep cpufreq  | sort
}

# REM: governors
_show_available_cpufreq_governors(){
 modprobe -l | grep cpufreq_  | sort
}

[ "$AMD" ]    || AMD='powernow-k6 powernow-k7 powernow-k8'
[ "$CYRIX" ]  || CYRIX='gx-suspmod'
[ "$INTEL" ]  || INTEL='p4-clockmod speedstep-centrino speedstep-ich'
[ "$NVIDIA" ] || NVIDIA='cpufreq-nforce2'
# description:    LongRun driver for Transmeta Crusoe and Efficeon processors.
[ "$TRANSM" ] || TRANSM='longrun'
[ "$VIA" ]    || VIA='longhaul e_powersaver'

_detect_cpu_manufacturer(){
  CPUMAN="`dmidecode -s 'processor-manufacturer' | tr '[A-Z]' '[a-z]' | cut -f 1 -d ' '`"
  _info "CPUMAN='$CPUMAN'"
  case $CPUMAN in
   amd)    mFREQMODS_="${AMD}" ; mFREQMODOPTS_='';;
   cyrix)   mFREQMODS_="${CYRIX}" ;mFREQMODOPTS_='';;
   intel)    mFREQMODS_="${INTEL}" ;mFREQMODOPTS_='';;
   nvidia)    mFREQMODS_="${NVIDIA}" ;mFREQMODOPTS_='';;
   transmeta) mFREQMODS_="${TRANSM}" ;mFREQMODOPTS_='';;
   via)       mFREQMODS_="${VIA}" ;mFREQMODOPTS_='';;
  esac
  _info "mFREQMODS_='$mFREQMODS_'"
  _info "mFREQMODOPTS_='$mFREQMODOPTS_'"
}
_detect_cpu_manufacturer

[ "$mFREQMODS_" ]    && mFREQMODS="$mFREQMODS_"
[ "$mFREQMODOPTS_" ] && mFREQMODOPTS="$mFREQMODOPTS_"

 FREQMODS="acpi-cpufreq"
 [ "$FREQMOD_OPS" ]  || FREQMOD_OPS='acpi_pstate_strict=1'
 GOVERNOR='ondemand'
 [ "$GOVERNOR_OPS" ] || GOVERNOR_OPS=''
 GOVERNORS='conservative ondemand performance powersave userspace'

 FREQMODS="${mFREQMODS} $FREQMODS"

if [ "$DEBUG" ]; then
       ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/   ##DEBUG
grep -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/*  ##DEBUG
fi

if [ "$GOVERNOR" = 'ondemand' ]; then
 test "$TRESHOLD"          || TRESHOLD=99         # Range 11-100 %
 test "$SAMPLERATE"        || SAMPLERATE=200000   # Range 10000 Hz - CPU Hz
 test "$IGNORE_NICE_LOAD"  || IGNORE_NICE_LOAD=1
 test "$SAMPLING_DOWN_FACTOR" || SAMPLING_DOWN_FACTOR=10
fi

test "$up_threshold"     || up_threshold=$TRESHOLD
test "$sampling_rate "   || sampling_rate=$SAMPLERATE
test "$ignore_nice_load" || ignore_nice_load=$IGNORE_NICE_LOAD
test "$sampling_down_factor" || sampling_down_factor=$SAMPLING_DOWN_FACTOR

echo "STATUS='$STATUS'"
case "$1" in
 start)

 _kernel_version
 _notice "$*:For kernel $KERNEL_RELEASE"
 # REM: add your driver to FREQMODS
  for oneMOD in $FREQMODS
  do
   modprobe $Q $VERB -b $oneMOD
   if [ $? -eq 0 ];then
    # REM: now insert driver GOVERNOR
    modprobe $Q $VERB -b cpufreq_${GOVERNOR}
    if [ $? -eq 0 ];then

     # REM: some grep syntax that work for the purpose:

     # REM: grep without option
     # *      The preceding item will be matched zero or more times.
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]*$'

     # ?      The preceding item is optional and matched at most once.
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]\?$'

     # +      The preceding item will be matched one or more times.
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]\+$'

     # {n}    The preceding item is matched exactly n times.
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]\{1\}$'  ## TODO:limits to 10 cores

     # {n,}   The preceding item is matched n or more times.
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]\{1,\}$' ## TODO:

     #
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[[0-9]]*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[[0-9]]\?$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9].*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9].*'
     #
     # ls -1v /sys/devices/system/cpu/ | grep '\(cpu[0-9].*\)'
     #
     #

     # REM: grep with -e switch
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[0-9]*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[0-9]\?$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[0-9]\+$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[[0-9]]*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[[0-9]]\?$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[0-9].*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[0-9].*'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -e '\(cpu[0-9].*\)'
     #
     #

     # REM: grep with -E switch
     # ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[0-9]*$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[0-9]?$'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[0-9]]*'
     #
     # ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[0-9]]?'
     #
     #
     #
     #
     #
     #
     #

     # REM core is core and thread ( thread directory gets linked to core )
     for core in `ls -1v /sys/devices/system/cpu/ | grep -w '^cpu[0-9]\{1,\}$'`
     do
      [ "$VERBOSE" ] && ls -ld /sys/devices/system/cpu/$core/cpufreq # DEBUG
      # REM: test if LINK , then it is a thread
      test -L /sys/devices/system/cpu/$core/cpufreq && continue # do not write twice or more

      # REM: test if governor is available
      grep $Q "${GOVERNOR}" /sys/devices/system/cpu/$core/cpufreq/scaling_available_governors || continue
      # REM: test if sysfs file is writable
      _test_fw /sys/devices/system/cpu/$core/cpufreq/scaling_governor || continue
      # REM: now write GOVERNOR to sysfs file
      echo ${GOVERNOR} >/sys/devices/system/cpu/$core/cpufreq/scaling_governor


      if _test_fw /sys/devices/system/cpu/$core/cpufreq/cpuinfo_transition_latency; then
       :
      fi

      # REM: DEBUG
      if [ "$DEBUG" ]; then
      sleep 0.2
      #ls -l /sys/devices/system/cpu/$core/cpufreq/${GOVERNOR}/  ##DEBUG
      #grep -H '.*' /sys/devices/system/cpu/$core/cpufreq/${GOVERNOR}/*  ##DEBUG
      ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/  ##DEBUG
      grep -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/*  ##DEBUG
      fi

     done

     break  # FREQMODS

    else
     # REM: Should not happen ..
     _err "Failed to insert 'cpufreq_${GOVERNOR}' into kernel"
     _notice "Make sure the BIOS settings allow Frequency-Scaling"
     rmmod $oneMOD
    fi

   else
    # REM: Should not happen ..
    _err "Failed to insert '$oneMOD' into kernel"
    _notice "Make sure '$oneMOD' is appropriate for your CPU"
   fi
  done

if [ "$DEBUG" ]; then
       ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/   ##DEBUG
grep -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/*  ##DEBUG
fi

if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/ignore_nice_load; then
:
test "$ignore_nice_load"    && echo $ignore_nice_load     >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/ignore_nice_load
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/io_is_busy; then
:
test "$io_is_busy"          && echo $io_is_busy           >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/io_is_busy
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/powersave_bias; then
:
test "$powersave_bias"      && echo $powersave_bias       >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/powersave_bias
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_down_factor; then
:
[ "$sampling_down_factor" ] && echo $sampling_down_factor >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_down_factor
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_rate; then
:
test "$sampling_rate"       && echo $sampling_rate        >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_rate
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_rate_min; then
:
test "$sampling_rate_min"   && echo $sampling_rate_min    >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/sampling_rate_min
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/up_threshold; then
:
test "$up_threshold"        && echo $up_threshold         >/sys/devices/system/cpu/cpufreq/${GOVERNOR}/up_threshold
fi
if _test_fw /sys/devices/system/cpu/cpufreq/${GOVERNOR}/; then
:
fi

if [ "$DEBUG" ]; then
       ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/   ##DEBUG
grep -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/*  ##DEBUG
fi

 ;;

# REM: Added stop part..
  stop)
   grep $Q "^cpufreq_${GOVERNOR}" /proc/modules && {
     ( timeout -t 5 modprobe $VERB -r cpufreq_${GOVERNOR} || exit 4 ) & sleep 1

    }

   for oneMOD in $FREQMODS
    do
     grep $Q "^$oneMOD" /proc/modules || continue
     ( timeout -t 5 modprobe $VERB -r $oneMOD || exit 5 ) & sleep 1
    done
 ;;
  status)
        echo "STATUS='$STATUS'"
        [ "$DEBUG" ] && echo "FILES:"
           ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/ >>$OUT 2>>$ERR
           STATUS=$((STATUS+$?))
        echo "STATUS='$STATUS'"
        [ "$DEBUG" ] && echo "CONTENTS:"
           grep $Q -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/* 2>>$ERR
           STATUS=$((STATUS+$?))
         echo "STATUS='$STATUS'"
        if test "$STATUS" = 0; then
          _notice "status:OK for governor '$GOVERNOR'"
        else
          _warn "status:FAIL for governor '$GOVERNOR'"
        fi
 ;;
  help)
       echo "STATUS='$STATUS'"
       case $2 in
       modules) echo "EXAMPLE LIST of FREQUENCY DRIVERS:"
                      _example_list_of_cpufreq_modules
                echo
                echo "LIST of available FREQUENCY DRIVERS:"
                      _show_available_cpufreq_drivers
                echo
                echo "EXAMPLE LIST of  GOVERNOR DRIVERS:"
                      _example_list_of_cpufreq_governors
                echo
                echo "LIST of available GOVERNOR DRIVERS:"
                      _show_available_cpufreq_governors
         ;;
         settings)
                echo "The ondemand driver has these defaults:"
                _show_hard_compiled_in_settings_ondemand

         ;;
         '') echo "Need second parameter modules OR settings"
             STATUS=$((STATUS+1))
         ;;
         *) :
         ;;
         esac
 ;;
*)
 echo "Usage: $0 start|stop|status|help [modules|settings]"
 STATUS=$((STATUS+1))
 ;;
esac
STATUS=$((STATUS+$?))
exit $STATUS

#!/bin/bash
#http://murga-linux.com/puppy/viewtopic.php?t=75139

#modprobe -l | grep nls |sed 's#\..*##g' |rev|cut -f 1 -d '/'|rev|while read m ; do modprobe -v $m;done

EXT="$1"
[ ! "$EXT" ] && EXT=mp4
RATE="$((<<<$2)|sed 's#[^0-9]##g')"
[ ! "$RATE" ] && RATE=15 #25
RESOLUTION="$((<<<$3)|sed 's#[^0-9x+]##g')"
[ ! "$RESOLUTION" ] && RESOLUTION="100x100+100+100"


echo DBG $LANG
export LANG=C
echo DBG $LANG
var="$(xrandr | grep '*')"
echo DBG "$var"
IFS=' '
set -- $var
#export $@
export IFS=' '
echo DBG "IFS='$IFS'"
echo DBG $LANG

if [ -f ./ffmpeg -a -x ./ffmpeg ];then
FFMPEG='./ffmpeg'
elif [ -f /usr/local/bin/ffmpeg -a -x /usr/local/bin/ffmpeg ];then
FFMPEG='/usr/local/bin/ffmpeg'
else
FFMPEG=`which ffmpeg`
fi

ALSACAP=`$FFMPEG -formats 2>/dev/null|grep alsa`
X11GRABCAP=`$FFMPEG -formats 2>/dev/null|grep x11grab`

if [ ! "$ALSACAP" ];then
echo "ERROR , format 'alsa' not supported by $FFMPEG" ;exit 21
elif [ ! "$X11GRABCAP" ];then
echo "ERROR , format 'x11grab' not supported by $FFMPEG" ;exit 23
else
echo "OK , both formats supported by $FFMPEG : 'alsa' 'x11grab'"
fi

FFMPEGVERSION=`$FFMPEG -version 2>/dev/null |head -n1 |cut -f 2 -d ' '`
if [ ! "$FFMPEGVERSION" ];then
echo "ERROR , could not determine version of $FFMPEG"
exit 25;fi

c=0
if [ -e /root/test.$FFMPEGVERSION.$EXT ];then
c=$((c+1))
while [ -e /root/test.$FFMPEGVERSION.$c.$EXT ];do c=$((c+1));done
mv  /root/test.$FFMPEGVERSION.$EXT /root/test.$FFMPEGVERSION.$c.$EXT
fi
echo DBG "$@"
[ ! "$RESOLUTION" ] && RESOLUTION="$1"
echo DBG $RESOLUTION $RATE $EXT

k='';c=0
echo "Press any key to start ffmpeg"
until [ "$k" ] ; do
sleep 1s;c=$((c+1));echo -ne "\r$c "
read -s -t1 -n1 k
done
echo

#xterm -hold -e
#vte -c
#sakura -e
echo
#xterm -hold -e \
#"$FFMPEG"\
#	-f alsa -ac 2 -i hw:0,0\
#	-f x11grab -s $RESOLUTION -r $RATE -i :0.0\
#	-sameq\
#	/root/test.$FFMPEGVERSION.$EXT\
# && RV="$?" || RV="$?"
xterm -hold -e \
"$FFMPEG"\
	-f alsa -ac 2 -i hw:0,0\
	-f x11grab -s $RESOLUTION -r $RATE -i :0.0\
	/root/test.$FFMPEGVERSION.$EXT\
 && RV="$?" || RV="$?"
RVC="$?"

echo "$FFMPEG -f alsa -ac 2 -i hw:0,0 -f x11grab -s $RESOLUTION -r $RATE -i :0.0 -sameq /root/test.$FFMPEGVERSION.$EXT
RETURNS : '$RV'"
exit $((RV+RVC))

#-t duration
#Restrict the transcoded/captured video sequence to the duration
#specified in seconds.  "hh:mm:ss[.xxx]" syntax is also supported.

#-fs limit_size Set the file size limit.

#dbug modes 1,2,4,8,16,32
# 128,256,512,1024,2048,4096
# 32768
# 65536,131072,262144,524288,1048576
# 2097152,4194304,8388608,16777216,33554432,67108864
# 134217728,268435456,536870912,1073741824
# -2147483648

#sh -c '/usr/local/bin/ffmpeg ﻿-f alsa -ac 2 -i hw:0,0 -f x11grab -s $1 -r 25 -i :0.0 -sameq /root/test.avi'
#Unable to find a suitable output format for 'ï»¿-f'

#/usr/local/bin/ffmpeg ﻿-f alsa -i hw:0,0 -f x11grab -s $1 -r 25 -i :0.0 -sameq /root/test.avi
#Unable to find a suitable output format for 'ï»¿-f'
#/usr/local/bin/ffmpeg ﻿-f alsa -i hw:0.0 -f x11grab -s $1 -r 25 -i :0.0 -sameq /root/test.avi
#Unable to find a suitable output format for 'ï»¿-f'
#/usr/local/bin/ffmpeg ﻿-f alsa -i hw:0,0 -f x11grab -s $1 -r 25 -i :0,0 -sameq /root/test.avi
#Unable to find a suitable output format for 'ï»¿-f'

#/usr/local/bin/ffmpeg ﻿\
#-f avi \
#-s $1 -r 25 -sameq  /root/test.avi
#Unable to find a suitable output format for 'ï»¿-f'
#mpegvideo


## FFmpeg version SVN-rUNKNOWN, Copyright (c) 2000-2007 Fabrice Bellard, et al.
##   configuration: --arch=i486 --enable-libmp3lame --enable-liba52 --enable-libfaac --enable-libfaad --enable-pthreads --enable-small --enable-libogg --enable-libvorbis --enable-gpl --enable-shared --enable-pp --disable-debug --prefix=/usr
##   libavutil version: 49.5.0
##   libavcodec version: 51.44.0
##   libavformat version: 51.14.0
##   built on Jul 12 2009 11:29:41, gcc: 4.2.2
## usage: ffmpeg [[infile options] -i infile]... {[outfile options] outfile}...
## Hyper fast Audio and Video encoder
##
## Main options:
## -L                  show license
## -h                  show help
## -version            show version
## -formats            show available formats, codecs, protocols, ...
## -f fmt              force format
## -i filename         input file name
## -y                  overwrite output files
## -t duration         record or transcode "duration" seconds of audio/video
## -fs limit_size      set the limit file size in bytes
## -ss time_off        set the start time offset
## -itsoffset time_off  set the input ts offset
## -title string       set the title
## -timestamp time     set the timestamp
## -author string      set the author
## -copyright string   set the copyright
## -comment string     set the comment
## -album string       set the album
## -v verbose          control amount of logging
## -target type        specify target file type ("vcd", "svcd", "dvd", "dv", "dv50", "pal-vcd", "ntsc-svcd", ...)
## -dframes number     set the number of data frames to record
## -sn                 disable subtitle
## -scodec codec       force subtitle codec ('copy' to copy stream)
## -newsubtitle        add a new subtitle stream to the current output stream
## -slang code         set the ISO 639 language code (3 letters) of the current subtitle stream
##
## Video options:
## -vframes number     set the number of video frames to record
## -r rate             set frame rate (Hz value, fraction or abbreviation)
## -s size             set frame size (WxH or abbreviation)
## -aspect aspect      set aspect ratio (4:3, 16:9 or 1.3333, 1.7777)
## -croptop size       set top crop band size (in pixels)
## -cropbottom size    set bottom crop band size (in pixels)
## -cropleft size      set left crop band size (in pixels)
## -cropright size     set right crop band size (in pixels)
## -padtop size        set top pad band size (in pixels)
## -padbottom size     set bottom pad band size (in pixels)
## -padleft size       set left pad band size (in pixels)
## -padright size      set right pad band size (in pixels)
## -padcolor color     set color of pad bands (Hex 000000 thru FFFFFF)
## -vn                 disable video
## -vcodec codec       force video codec ('copy' to copy stream)
## -sameq              use same video quality as source (implies VBR)
## -pass n             select the pass number (1 or 2)
## -passlogfile file   select two pass log file name
## -newvideo           add a new video stream to the current output stream
##
## Advanced Video options:
## -pix_fmt format     set pixel format, 'list' as argument shows all the pixel formats supported
## -intra              use only intra frames
## -vdt n              discard threshold
## -qscale q           use fixed video quantizer scale (VBR)
## -qdiff q            max difference between the quantizer scale (VBR)
## -rc_eq equation     set rate control equation
## -rc_override override  rate control override for specific intervals
## -me_threshold       motion estimaton threshold
## -strict strictness  how strictly to follow the standards
## -deinterlace        deinterlace pictures
## -psnr               calculate PSNR of compressed frames
## -vstats             dump video coding statistics to file
## -vstats_file file   dump video coding statistics to file
## -vhook module       insert video processing module
## -intra_matrix matrix  specify intra matrix coeffs
## -inter_matrix matrix  specify inter matrix coeffs
## -top                top=1/bottom=0/auto=-1 field first
## -dc precision       intra_dc_precision
## -vtag fourcc/tag    force video tag/fourcc
## -qphist             show QP histogram
## -vbsf bitstream filter
##
## Audio options:
## -aframes number     set the number of audio frames to record
## -aq quality         set audio quality (codec-specific)
## -ar rate            set audio sampling rate (in Hz)
## -ac channels        set number of audio channels
## -an                 disable audio
## -acodec codec       force audio codec ('copy' to copy stream)
## -vol volume         change audio volume (256=normal)
## -newaudio           add a new audio stream to the current output stream
## -alang code         set the ISO 639 language code (3 letters) of the current audio stream
##
## Advanced Audio options:
## -atag fourcc/tag    force audio tag/fourcc
## -absf bitstream filter
##
## Subtitle options:
## -sn                 disable subtitle
## -scodec codec       force subtitle codec ('copy' to copy stream)
## -newsubtitle        add a new subtitle stream to the current output stream
## -slang code         set the ISO 639 language code (3 letters) of the current subtitle stream
##
## Audio/Video grab options:
## -vc channel         set video grab channel (DV1394 only)
## -tvstd standard     set television standard (NTSC, PAL (SECAM))
## -isync              sync read on input
##
## Advanced options:
## -map file:stream[:syncfile:syncstream]  set input stream mapping
## -map_meta_data outfile:infile  set meta data information of outfile from infile
## -benchmark          add timings for benchmarking
## -dump               dump each input packet
## -hex                when dumping packets, also dump the payload
## -re                 read input at native frame rate
## -loop_input         loop (current only works with images)
## -loop_output        number of times to loop output in formats that support looping (0 loops forever)
## -threads count      thread count
## -vsync              video sync method
## -async              audio sync method
## -adrift_threshold   audio drift threshold
## -vglobal            video global header storage type
## -copyts             copy timestamps
## -shortest           finish encoding within shortest input
## -dts_delta_threshold   timestamp discontinuity delta threshold
## -muxdelay seconds   set the maximum demux-decode delay
## -muxpreload seconds  set the initial demux-decode delay
## AVCodecContext AVOptions:
## -b                 <int>   E.V.. set bitrate (in bits/s)
## -ab                <int>   E..A. set bitrate (in bits/s)
## -bt                <int>   E.V.. set video bitrate tolerance (in bits/s)
## -flags             <flags> EDVA.
##    mv4                     E.V.. use four motion vector by macroblock (mpeg4)
##    obmc                    E.V.. use overlapped block motion compensation (h263+)
##    qpel                    E.V.. use 1/4 pel motion compensation
##    loop                    E.V.. use loop filter
##    gmc                     E.V.. use gmc
##    mv0                     E.V.. always try a mb with mv=<0,0>
##    part                    E.V.. use data partitioning
##    gray                    EDV.. only decode/encode grayscale
##    psnr                    E.V.. error[?] variables will be set during encoding
##    naq                     E.V.. normalize adaptive quantization
##    ildct                   E.V.. use interlaced dct
##    low_delay               EDV.. force low delay
##    alt                     E.V.. enable alternate scantable (mpeg2/mpeg4)
##    trell                   E.V.. use trellis quantization
##    bitexact                EDVAS use only bitexact stuff (except (i)dct)
##    aic                     E.V.. h263 advanced intra coding / mpeg4 ac prediction
##    umv                     E.V.. use unlimited motion vectors
##    cbp                     E.V.. use rate distortion optimization for cbp
##    qprd                    E.V.. use rate distortion optimization for qp selection
##    aiv                     E.V.. h263 alternative inter vlc
##    slice                   E.V..
##    ilme                    E.V.. interlaced motion estimation
##    scan_offset             E.V.. will reserve space for svcd scan offset user data
##    cgop                    E.V.. closed gop
## -me_method         <int>   E.V.. set motion estimation method
##    zero                    E.V.. zero motion estimation (fastest)
##    full                    E.V.. full motion estimation (slowest)
##    epzs                    E.V.. EPZS motion estimation (default)
##    log                     E.V.. log motion estimation
##    phods                   E.V.. phods motion estimation
##    x1                      E.V.. X1 motion estimation
##    hex                     E.V.. hex motion estimation
##    umh                     E.V.. umh motion estimation
##    iter                    E.V.. iter motion estimation
## -me                <int>   E.V.. set motion estimation method (deprecated, use me_method instead)
##    zero                    E.V.. zero motion estimation (fastest)
##    full                    E.V.. full motion estimation (slowest)
##    epzs                    E.V.. EPZS motion estimation (default)
##    log                     E.V.. log motion estimation
##    phods                   E.V.. phods motion estimation
##    x1                      E.V.. X1 motion estimation
##    hex                     E.V.. hex motion estimation
##    umh                     E.V.. umh motion estimation
##    iter                    E.V.. iter motion estimation
## -g                 <int>   E.V.. set the group of picture size
## -cutoff            <int>   E..A. set cutoff bandwidth
## -frame_size        <int>   E..A.
## -qcomp             <float> E.V.. video quantizer scale compression (VBR)
## -qblur             <float> E.V.. video quantizer scale blur (VBR)
## -qmin              <int>   E.V.. min video quantizer scale (VBR)
## -qmax              <int>   E.V.. max video quantizer scale (VBR)
## -qdiff             <int>   E.V.. max difference between the quantizer scale (VBR)
## -bf                <int>   E.V.. use 'frames' B frames
## -b_qfactor         <float> E.V.. qp factor between p and b frames
## -rc_strategy       <int>   E.V.. ratecontrol method
## -b_strategy        <int>   E.V.. strategy to choose between I/P/B-frames
## -hurry_up          <int>   .DV..
## -ps                <int>   E.V.. rtp payload size in bits
## -bug               <flags> .DV.. workaround not auto detected encoder bugs
##    autodetect              .DV..
##    old_msmpeg4             .DV.. some old lavc generated msmpeg4v3 files (no autodetection)
##    xvid_ilace              .DV.. Xvid interlacing bug (autodetected if fourcc==XVIX)
##    ump4                    .DV.. (autodetected if fourcc==UMP4)
##    no_padding              .DV.. padding bug (autodetected)
##    amv                     .DV..
##    ac_vlc                  .DV.. illegal vlc bug (autodetected per fourcc)
##    qpel_chroma             .DV..
##    std_qpel                .DV.. old standard qpel (autodetected per fourcc/version)
##    qpel_chroma2            .DV..
##    direct_blocksize         .DV.. direct-qpel-blocksize bug (autodetected per fourcc/version)
##    edge                    .DV.. edge padding bug (autodetected per fourcc/version)
##    hpel_chroma             .DV..
##    dc_clip                 .DV..
##    ms                      .DV.. workaround various bugs in microsofts broken decoders
## -lelim             <int>   E.V.. single coefficient elimination threshold for luminance (negative values also consider dc coefficient)
## -celim             <int>   E.V.. single coefficient elimination threshold for chrominance (negative values also consider dc coefficient)
## -strict            <int>   .DVA. how strictly to follow the standards
##    very                    E.V.. strictly conform to a older more strict version of the spec or reference software
##    strict                  E.V.. strictly conform to all the things in the spec no matter what consequences
##    normal                  E.V..
##    inofficial              E.V.. allow inofficial extensions
##    experimental            E.V.. allow non standardized experimental things
## -b_qoffset         <float> E.V.. qp offset between p and b frames
## -er                <int>   .DVA. set error resilience strategy
##    careful                 .DV..
##    compliant               .DV..
##    aggressive              .DV..
##    very_aggressive         .DV..
## -mpeg_quant        <int>   E.V.. use MPEG quantizers instead of H.263
## -qsquish           <float> E.V.. how to keep quantizer between qmin and qmax (0 = clip, 1 = use differentiable function)
## -rc_qmod_amp       <float> E.V.. experimental quantizer modulation
## -rc_qmod_freq      <int>   E.V.. experimental quantizer modulation
## -rc_eq             <string> E.V.. set rate control equation
## -maxrate           <int>   E.V.. set max video bitrate tolerance (in bits/s)
## -minrate           <int>   E.V.. set min video bitrate tolerance (in bits/s)
## -bufsize           <int>   E.V.. set ratecontrol buffer size (in bits)
## -rc_buf_aggressivity <float> E.V.. currently useless
## -i_qfactor         <float> E.V.. qp factor between p and i frames
## -i_qoffset         <float> E.V.. qp offset between p and i frames
## -rc_init_cplx      <float> E.V.. initial complexity for 1-pass encoding
## -dct               <int>   E.V.. DCT algorithm
##    auto                    E.V.. autoselect a good one (default)
##    fastint                 E.V.. fast integer
##    int                     E.V.. accurate integer
##    mmx                     E.V..
##    mlib                    E.V..
##    altivec                 E.V..
##    faan                    E.V.. floating point AAN DCT
## -lumi_mask         <float> E.V.. compresses bright areas stronger than medium ones
## -tcplx_mask        <float> E.V.. temporal complexity masking
## -scplx_mask        <float> E.V.. spatial complexity masking
## -p_mask            <float> E.V.. inter masking
## -dark_mask         <float> E.V.. compresses dark areas stronger than medium ones
## -idct              <int>   EDV.. select IDCT implementation
##    auto                    EDV..
##    int                     EDV..
##    simple                  EDV..
##    simplemmx               EDV..
##    libmpeg2mmx             EDV..
##    ps2                     EDV..
##    mlib                    EDV..
##    arm                     EDV..
##    altivec                 EDV..
##    sh4                     EDV..
##    simplearm               EDV..
##    simplearmv5te           EDV..
##    h264                    EDV..
##    vp3                     EDV..
##    ipp                     EDV..
##    xvidmmx                 EDV..
## -ec                <flags> .DV.. set error concealment strategy
##    guess_mvs               .DV.. iterative motion vector (MV) search (slow)
##    deblock                 .DV.. use strong deblock filter for damaged MBs
## -pred              <int>   E.V.. prediction method
##    left                    E.V..
##    plane                   E.V..
##    median                  E.V..
## -aspect            <rational> E.V.. sample aspect ratio
## -debug             <flags> EDVAS print specific debug info
##    pict                    .DV.. picture info
##    rc                      E.V.. rate control
##    bitstream               .DV..
##    mb_type                 .DV.. macroblock (MB) type
##    qp                      .DV.. per-block quantization parameter (QP)
##    mv                      .DV.. motion vector
##    dct_coeff               .DV..
##    skip                    .DV..
##    startcode               .DV..
##    pts                     .DV..
##    er                      .DV.. error resilience
##    mmco                    .DV.. memory management control operations (H.264)
##    bugs                    .DV..
##    vis_qp                  .DV.. visualize quantization parameter (QP), lower QP are tinted greener
##    vis_mb_type             .DV.. visualize block types
## -vismv             <int>   .DV.. visualize motion vectors (MVs)
##    pf                      .DV.. forward predicted MVs of P-frames
##    bf                      .DV.. forward predicted MVs of B-frames
##    bb                      .DV.. backward predicted MVs of B-frames
## -mb_qmin           <int>   E.V.. obsolete, use qmin
## -mb_qmax           <int>   E.V.. obsolete, use qmax
## -cmp               <int>   E.V.. full pel me compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -subcmp            <int>   E.V.. sub pel me compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -mbcmp             <int>   E.V.. macroblock compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -ildctcmp          <int>   E.V.. interlaced dct compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -dia_size          <int>   E.V.. diamond type & size for motion estimation
## -last_pred         <int>   E.V.. amount of motion predictors from the previous frame
## -preme             <int>   E.V.. pre motion estimation
## -precmp            <int>   E.V.. pre motion estimation compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -pre_dia_size      <int>   E.V.. diamond type & size for motion estimation pre-pass
## -subq              <int>   E.V.. sub pel motion estimation quality
## -me_range          <int>   E.V.. limit motion vectors range (1023 for DivX player)
## -ibias             <int>   E.V.. intra quant bias
## -pbias             <int>   E.V.. inter quant bias
## -coder             <int>   E.V..
##    vlc                     E.V.. variable length coder / huffman coder
##    ac                      E.V.. arithmetic coder
##    raw                     E.V.. raw (no encoding)
##    rle                     E.V.. run-length coder
##    deflate                 E.V.. deflate-based coder
## -context           <int>   E.V.. context model
## -mbd               <int>   E.V.. macroblock decision algorithm (high quality mode)
##    simple                  E.V.. use mbcmp (default)
##    bits                    E.V.. use fewest bits
##    rd                      E.V.. use best rate distortion
## -sc_threshold      <int>   E.V.. scene change threshold
## -lmin              <int>   E.V.. min lagrange factor (VBR)
## -lmax              <int>   E.V.. max lagrange factor (VBR)
## -nr                <int>   E.V.. noise reduction
## -rc_init_occupancy <int>   E.V.. number of bits which should be loaded into the rc buffer before decoding starts
## -inter_threshold   <int>   E.V..
## -flags2            <flags> EDVA.
##    fast                    E.V.. allow non spec compliant speedup tricks
##    sgop                    E.V.. strictly enforce gop size
##    noout                   E.V.. skip bitstream encoding
##    local_header            E.V.. place global headers at every keyframe instead of in extradata
##    bpyramid                E.V.. allows B-frames to be used as references for predicting
##    wpred                   E.V.. weighted biprediction for b-frames (H.264)
##    mixed_refs              E.V.. one reference per partition, as opposed to one reference per macroblock
##    dct8x8                  E.V.. high profile 8x8 transform (H.264)
##    fastpskip               E.V.. fast pskip (H.264)
##    aud                     E.V.. access unit delimiters (H.264)
##    brdo                    E.V.. b-frame rate-distortion optimization
##    skiprd                  E.V.. RD optimal MB level residual skipping
##    ivlc                    E.V.. intra vlc table
##    drop_frame_timecode         E.V..
##    non_linear_q            E.V.. use non linear quantizer
## -error             <int>   E.V..
## -antialias         <int>   .DV.. MP3 antialias algorithm
##    auto                    .DV..
##    fastint                 .DV..
##    int                     .DV..
##    float                   .DV..
## -qns               <int>   E.V.. quantizer noise shaping
## -threads           <int>   EDV..
## -mb_threshold      <int>   E.V.. macroblock threshold
## -dc                <int>   E.V.. intra_dc_precision
## -nssew             <int>   E.V.. nsse weight
## -skip_top          <int>   .DV.. number of macroblock rows at the top which are skipped
## -skip_bottom       <int>   .DV.. number of macroblock rows at the bottom which are skipped
## -profile           <int>   E.VA.
##    unknown                 E.VA.
##    aac_main                E..A.
##    aac_low                 E..A.
##    aac_ssr                 E..A.
##    aac_ltp                 E..A.
## -level             <int>   E.VA.
##    unknown                 E.VA.
## -lowres            <int>   .DV.. decode at 1= 1/2, 2=1/4, 3=1/8 resolutions
## -skip_threshold    <int>   E.V.. frame skip threshold
## -skip_factor       <int>   E.V.. frame skip factor
## -skip_exp          <int>   E.V.. frame skip exponent
## -skipcmp           <int>   E.V.. frame skip compare function
##    sad                     E.V.. sum of absolute differences, fast (default)
##    sse                     E.V.. sum of squared errors
##    satd                    E.V.. sum of absolute Hadamard transformed differences
##    dct                     E.V.. sum of absolute DCT transformed differences
##    psnr                    E.V.. sum of squared quantization errors (avoid, low quality)
##    bit                     E.V.. number of bits needed for the block
##    rd                      E.V.. rate distortion optimal, slow
##    zero                    E.V.. 0
##    vsad                    E.V.. sum of absolute vertical differences
##    vsse                    E.V.. sum of squared vertical differences
##    nsse                    E.V.. noise preserving sum of squared differences
##    w53                     E.V.. 5/3 wavelet, only used in snow
##    w97                     E.V.. 9/7 wavelet, only used in snow
##    dctmax                  E.V..
##    chroma                  E.V..
## -border_mask       <float> E.V.. increases the quantizer for macroblocks close to borders
## -mblmin            <int>   E.V.. min macroblock lagrange factor (VBR)
## -mblmax            <int>   E.V.. max macroblock lagrange factor (VBR)
## -mepc              <int>   E.V.. motion estimation bitrate penalty compensation (1.0 = 256)
## -bidir_refine      <int>   E.V.. refine the two motion vectors used in bidirectional macroblocks
## -brd_scale         <int>   E.V.. downscales frames for dynamic B-frame decision
## -crf               <float> E.V.. enables constant quality mode, and selects the quality (x264)
## -cqp               <int>   E.V.. constant quantization parameter rate control method
## -keyint_min        <int>   E.V.. minimum interval between IDR-frames (x264)
## -refs              <int>   E.V.. reference frames to consider for motion compensation (Snow)
## -chromaoffset      <int>   E.V.. chroma qp offset from luma
## -bframebias        <int>   E.V.. influences how often B-frames are used
## -trellis           <int>   E.VA. rate-distortion optimal quantization
## -directpred        <int>   E.V.. direct mv prediction mode - 0 (none), 1 (spatial), 2 (temporal)
## -complexityblur    <float> E.V.. reduce fluctuations in qp (before curve compression)
## -deblockalpha      <int>   E.V.. in-loop deblocking filter alphac0 parameter
## -deblockbeta       <int>   E.V.. in-loop deblocking filter beta parameter
## -partitions        <flags> E.V.. macroblock subpartition sizes to consider
##    parti4x4                E.V..
##    parti8x8                E.V..
##    partp4x4                E.V..
##    partp8x8                E.V..
##    partb8x8                E.V..
## -sc_factor         <int>   E.V.. multiplied by qscale for each frame and added to scene_change_score
## -mv0_threshold     <int>   E.V..
## -b_sensitivity     <int>   E.V.. adjusts sensitivity of b_frame_strategy 1
## -compression_level <int>   E.VA.
## -use_lpc           <int>   E..A. sets whether to use LPC mode (FLAC)
## -lpc_coeff_precision <int>   E..A. LPC coefficient precision (FLAC)
## -min_prediction_order <int>   E..A.
## -max_prediction_order <int>   E..A.
## -prediction_order_method <int>   E..A. search method for selecting prediction order
## -min_partition_order <int>   E..A.
## -max_partition_order <int>   E..A.
## -timecode_frame_start <int>   E.V.. GOP timecode frame start number, in non drop frame format
## -request_channels  <int>   .D.A. set desired number of audio channels
## AVFormatContext AVOptions:
## -probesize         <int>   .D...
## -muxrate           <int>   E.... set mux rate
## -packetsize        <int>   E.... set packet size
## -fflags            <flags> ED...
##    ignidx                  .D... ignore index
##    genpts                  .D... generate pts
## -track             <int>   E....  set the track number
## -year              <int>   E.... set the year
## -analyzeduration   <int>   .D... how many microseconds are analyzed to estimate duration

## (null) AVOptions:
## File formats:
##   E 3g2             3gp2 format
##   E 3gp             3gp format
##  D  4xm             4X Technologies format
##  D  MTV             MTV format
##  DE RoQ             Id RoQ format
##  D  aac             ADTS AAC
##  DE ac3             raw ac3
##   E adts            ADTS AAC
##  DE aiff            Audio IFF
##  DE alaw            pcm A law format
##  DE amr             3gpp amr file format
##  D  apc             CRYO APC format
##  D  ape             Monkey's Audio
##  DE asf             asf format
##   E asf_stream      asf format
##  DE au              SUN AU Format
##  DE avi             avi format
##  D  avs             avs format
##  D  bethsoftvid     Bethesda Softworks 'Daggerfall' VID format
##  D  c93             Interplay C93
##   E crc             crc testing format
##  D  daud            D-Cinema audio format
##  D  dsicin          Delphine Software International CIN format
##  D  dts             raw dts
##  DE dv              DV video format
##  D  dv1394          dv1394 A/V grab
##   E dvd             MPEG2 PS format (DVD VOB)
##  D  dxa             dxa
##  D  ea              Electronic Arts Multimedia Format
##  DE ffm             ffm format
##  D  film_cpk        Sega FILM/CPK format
##  DE flac            raw flac
##  D  flic            FLI/FLC/FLX animation format
##  DE flv             flv format
##   E framecrc        framecrc testing format
##  DE gif             GIF Animation
##  DE gxf             GXF format
##  DE h261            raw h261
##  DE h263            raw h263
##  DE h264            raw H264 video format
##  D  idcin           Id CIN format
##  DE image2          image2 sequence
##  DE image2pipe      piped image2 sequence
##  D  ingenient       Ingenient MJPEG
##  D  ipmovie         Interplay MVE format
##  DE m4v             raw MPEG4 video format
##  DE matroska        Matroska File Format
##  DE mjpeg           MJPEG video
##  D  mm              American Laser Games MM format
##  DE mmf             mmf format
##   E mov             mov format
##  D  mov,mp4,m4a,3gp,3g2,mj2 QuickTime/MPEG4/Motion JPEG 2000 format
##   E mp2             MPEG audio layer 2
##  DE mp3             MPEG audio layer 3
##   E mp4             mp4 format
##  D  mpc             musepack
##  DE mpeg            MPEG1 System format
##   E mpeg1video      MPEG video
##   E mpeg2video      MPEG2 video
##  DE mpegts          MPEG2 transport stream format
##  D  mpegtsraw       MPEG2 raw transport stream format
##  D  mpegvideo       MPEG video
##   E mpjpeg          Mime multipart JPEG format
##  DE mulaw           pcm mu law format
##  D  mxf             MXF format
##  D  nsv             NullSoft Video format
##   E null            null video format
##  DE nut             nut format
##  D  nuv             NuppelVideo format
##  DE ogg             Ogg format
##  DE oss             audio grab and output
##   E psp             psp mp4 format
##  D  psxstr          Sony Playstation STR format
##  DE rawvideo        raw video format
##  D  redir           Redirector format
##  DE rm              rm format
##   E rtp             RTP output format
##  D  rtsp            RTSP input format
##  DE s16be           pcm signed 16 bit big endian format
##  DE s16le           pcm signed 16 bit little endian format
##  DE s8              pcm signed 8 bit format
##  D  sdp             SDP
##  D  shn             raw shorten
##  D  smk             Smacker Video
##  D  sol             Sierra SOL Format
##   E svcd            MPEG2 PS format (VOB)
##  DE swf             Flash format
##  D  thp             THP
##  D  tiertexseq      Tiertex Limited SEQ format
##  D  tta             true-audio
##  D  txd             txd format
##  DE u16be           pcm unsigned 16 bit big endian format
##  DE u16le           pcm unsigned 16 bit little endian format
##  DE u8              pcm unsigned 8 bit format
##  D  vc1             raw vc1
##   E vcd             MPEG1 System format (VCD)
##  D  video4linux     video grab
##  D  video4linux2    video grab
##  D  vmd             Sierra VMD format
##   E vob             MPEG2 PS format (VOB)
##  DE voc             Creative Voice File format
##  DE wav             wav format
##  D  wc3movie        Wing Commander III movie format
##  D  wsaud           Westwood Studios audio format
##  D  wsvqa           Westwood Studios VQA format
##  D  wv              WavPack
##  DE yuv4mpegpipe    YUV4MPEG pipe format
##
## Codecs:
##  D V    4xm
##  D V D  8bps
##  D V    VMware video
##  D V D  aasc
##   EA    ac3
##  DEA    adpcm_4xm
##  DEA    adpcm_adx
##  DEA    adpcm_ct
##  DEA    adpcm_ea
##  D A    adpcm_ima_amv
##  DEA    adpcm_ima_dk3
##  DEA    adpcm_ima_dk4
##  DEA    adpcm_ima_qt
##  DEA    adpcm_ima_smjpeg
##  DEA    adpcm_ima_wav
##  DEA    adpcm_ima_ws
##  DEA    adpcm_ms
##  DEA    adpcm_sbpro_2
##  DEA    adpcm_sbpro_3
##  DEA    adpcm_sbpro_4
##  DEA    adpcm_swf
##  D A    adpcm_thp
##  DEA    adpcm_xa
##  DEA    adpcm_yamaha
##  D A    alac
##  D V D  amv
##  D A    ape
##  DEV D  asv1
##  DEV D  asv2
##  D A    atrac 3
##  D V D  avs
##  D V    bethsoftvid
##  DEV    bmp
##  D V D  c93
##  D V D  camstudio
##  D V D  camtasia
##  D V D  cavs
##  D V D  cinepak
##  D V D  cljr
##  D A    cook
##  D V D  cyuv
##  D A    dca
##  D V D  dnxhd
##  D A    dsicinaudio
##  D V D  dsicinvideo
##  DES    dvbsub
##  DES    dvdsub
##  DEV D  dvvideo
##  D V    dxa
##  DEV D  ffv1
##  DEVSD  ffvhuff
##  DEA    flac
##  DEV D  flashsv
##  D V D  flic
##  DEVSD  flv
##  D V D  fraps
##  DEA    g726
##  DEV    gif
##  DEV D  h261
##  DEVSDT h263
##  D VSD  h263i
##   EV    h263p
##  D V DT h264
##  DEVSD  huffyuv
##  D V D  idcinvideo
##  D A    imc
##  D V D  indeo2
##  D V    indeo3
##  D A    interplay_dpcm
##  D V D  interplayvideo
##  DEV D  jpegls
##  D V    kmvc
##  D A    liba52
##   EA    libfaac
##  D A    libfaad
##   EA    libmp3lame
##   EV    ljpeg
##  D V D  loco
##  D A    mace3
##  D A    mace6
##  D V D  mdec
##  DEV D  mjpeg
##  D V D  mjpegb
##  D V D  mmvideo
##  DEA    mp2
##  D A    mp3
##  D A    mp3adu
##  D A    mp3on4
##  D A    mpc sv7
##  DEVSDT mpeg1video
##  DEVSDT mpeg2video
##  DEVSDT mpeg4
##  D A    mpeg4aac
##  D VSDT mpegvideo
##  DEVSD  msmpeg4
##  DEVSD  msmpeg4v1
##  DEVSD  msmpeg4v2
##  D V D  msrle
##  D V D  msvideo1
##  D V D  mszh
##  D V D  nuv
##  DEV    pam
##  DEV    pbm
##  DEA    pcm_alaw
##  DEA    pcm_mulaw
##  DEA    pcm_s16be
##  DEA    pcm_s16le
##  DEA    pcm_s24be
##  DEA    pcm_s24daud
##  DEA    pcm_s24le
##  DEA    pcm_s32be
##  DEA    pcm_s32le
##  DEA    pcm_s8
##  DEA    pcm_u16be
##  DEA    pcm_u16le
##  DEA    pcm_u24be
##  DEA    pcm_u24le
##  DEA    pcm_u32be
##  DEA    pcm_u32le
##  DEA    pcm_u8
##  DEA    pcm_zork
##  DEV    pgm
##  DEV    pgmyuv
##  DEV    png
##  DEV    ppm
##  D V    ptx
##  D A    qdm2
##  D V D  qdraw
##  D V D  qpeg
##  DEV D  qtrle
##  DEV    rawvideo
##  D A    real_144
##  D A    real_288
##  DEA    roq_dpcm
##  DEV D  roqvideo
##  D V D  rpza
##  DEV D  rv10
##  DEV D  rv20
##  DEV    sgi
##  D A    shorten
##  D A    smackaud
##  D V    smackvid
##  D V D  smc
##  DEV    snow
##  D A    sol_dpcm
##  DEA    sonic
##   EA    sonicls
##  D V D  sp5x
##  DEV D  svq1
##  D VSD  svq3
##  DEV    targa
##  D V    theora
##  D V D  thp
##  D V D  tiertexseqvideo
##  DEV    tiff
##  D V D  truemotion1
##  D V D  truemotion2
##  D A    truespeech
##  D A    tta
##  D V    txd
##  D V D  ultimotion
##  D V    vc1
##  D V D  vcr1
##  D A    vmdaudio
##  D V D  vmdvideo
##  DEA    vorbis
##  D V    vp3
##  D V D  vp5
##  D V D  vp6
##  D V D  vp6a
##  D V D  vp6f
##  D V D  vqavideo
##  D A    wavpack
##  DEA    wmav1
##  DEA    wmav2
##  DEVSD  wmv1
##  DEVSD  wmv2
##  D V    wmv3
##  D V D  wnv1
##  D A    ws_snd1
##  D A    xan_dpcm
##  D V D  xan_wc3
##  D V D  xl
##  D S    xsub
##  DEV D  zlib
##  DEV    zmbv
##
## Supported file protocols:
##  file: http: pipe: rtp: tcp: udp:
## Frame size, frame rate abbreviations:
##  ntsc pal qntsc qpal sntsc spal film ntsc-film sqcif qcif cif 4cif
##
## Note, the names of encoders and decoders do not always match, so there are
## several cases where the above table shows encoder only or decoder only entries
## even though both encoding and decoding are supported. For example, the h263
## decoder corresponds to the h263 and h263p encoders, for file formats it is even
## worse.

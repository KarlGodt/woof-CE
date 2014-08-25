#!/bin/bash
# yt-download.sh v2.2 2011-03
# Arif HS http://arif.suparlan.com/2011/02/23/download-youtube-video-dengan-shell-script
# Big thanks to: Trio & Dougal http://www.murga-linux.com/puppy/viewtopic.php?p=326803#326803
# Usage: sh yt-download.sh [youtube_video_id] [save_directory]
#

echo ""
echo "YT-DOWNLOAD.SH v2.2"
echo "----------------------------------"

if [ $2 ]
then
    if [ ! -d "$2" ]
    then
        echo "Can not find directory. Aborting..."
        sleep 1
        exit 0
    fi
    DIR=$2"/"
else
    DIR=""
fi

if [ $1 ]
then
    #downloading html file
    echo "Downloading HTML file and getting video formats, please wait..."
    if [ ! -f /tmp/$1.tmp ];then
    #wget -O /tmp/$1.tmp "http://www.youtube.com/watch?v="$1 -q
    curl -s "http://www.youtube.com/watch?v="$1 > /tmp/$1.tmp
    fi
    #get title
    title=$(grep -o "<meta name=\"title\" content=\".*\">" /tmp/$1.tmp)
    echo "$title" >/tmp/title.1
    title=`expr match "$title" '<meta name=\"title\" content=\"\(.*\)\">'`
    echo "$title" >/tmp/title.2
    title=${title//\//"-"}
    titlefn=${title//" "/"_"}

    #check value
    function chkval {
        if [ ! $1 ]
        then
            echo "Uh oh, something went wrong..."
            exit 0
        fi
    }

    chkval $titlefn
    echo ""
    echo "Download site(s) found!"
    echo "----------------------------------"
    echo "Title: "$title

    #get player_config part
func_1(){
    Tmp=$(grep -o "'PLAYER_CONFIG': {.*}" /tmp/$1.tmp)
    if [ ! "$Tmp" ];then
    echo "
    ERROR
    could NOT find the
    'PLAYER_CONFIG': {.*}
    String in
/tmp/$1.tmp
     "
     read -n1 -p "press any Key to quit " QKEY
     exit 1
     fi
 }
#(last)part_of_line 2:"http:\/\/o-o.preferred.fra02s05.v2.lscache5.c.youtube.com\/crossdomain.xml");yt.preload.start("http:\/\/o-o.preferred.fra02s05.v2.lscache5.c.youtube.com\/generate_204?upn=MTQ5ODQ3MDQ2NjU1NDc0NzkxNDA\u0026sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire\u0026fexp=907048%2C903903%2C901700\u0026itag=34\u0026ip=2.0.0.0\u0026signature=428325210D4B67622FB1F0BD54C81996A7D1AA4D.1616475AC94886B8A44B6E06E8E7819B88FD0BD8\u0026sver=3\u0026ratebypass=yes\u0026source=youtube\u0026expire=1333481466\u0026key=yt1\u0026ipbits=8\u0026cp=U0hSSFRTT19LUENOMl9MTVNFOlJ6a2stVU52NDh5\u0026id=1508b25a11a08c0d");</script> <title>Top 10 Ausraster am PC
#line 3:      - YouTube
#line 4:  </title>
    #get o-o part
    #in shell, not in script: grep -o -m1 '"http:\\/\\/o-o.*".*</title>'
    #LINENR=`grep -n -o -m1 '"http:.*o-o.*".*</title>' /tmp/$1.tmp |cut -f 1 -d':'`
    LINENR=`grep -n -o -m1 '"http:.*youtube\.com.*</title>' /tmp/$1.tmp |cut -f 1 -d':'`
    echo "LINENR='$LINENR'"
    if [ ! "$LINENR" ];then
    #LINENR=`grep -n -o -m1 '"http:.*o\-o.*".*' /tmp/$1.tmp |cut -f 1 -d':'`
    LINENR=`grep -n -o -m1 '"http:.*youtube\.com.*".*' /tmp/$1.tmp |cut -f 1 -d':'`
    echo "LINENR='$LINENR'"
    #grep -o -m1 '"http:.*o\-o.*".*' /tmp/$1.line |tr ')' '\n' >/tmp/$1.wanted
    grep -o -m1 '"http:.*youtube\.com.*".*' /tmp/$1.line |tr ')' '\n' >/tmp/$1.wanted
    #URLS=`grep -o 'http:.*o-o.*"' /tmp/$1.wanted`
    URLS=`grep -o 'http:.*youtube\.com.*"' /tmp/$1.wanted`
    URL1=`echo "$URLS" | grep -v '/crossdomain\.xml'`
    URL9=`echo "$URL1" |sed 's/^;yt.preload.start(//'`
    echo "URL='$URL9'"
    URL8=`echo "$URL9" |sed 's,\\\\u0026,\&,g;s|\\\\||g'`
    echo "URL='$URL8'"
    URL7=`echo "$URL8" |sed 's/"$//;s/generate_204/videoplayback/'`
    echo "URL='$URL7'"
    URL6=`echo "$URL7" |sed 's|\ |\%20|g'`
    echo "URL='$URL6'"
    URL="$URL6"
    else
    sed -n "$LINENR p" /tmp/$1.tmp >/tmp/$1.line
    #grep -o -m1 '"http:\\/\\/o-o.*".*</title>' /tmp/$1.line |tr ')' '\n' >/tmp/$1.wanted
    #grep -o -m1 '"http:.*o\-o.*".*</title>' /tmp/$1.line |tr ')' '\n' >/tmp/$1.wanted
    grep -o -m1 '"http:.*youtube\.com.*".*</title>' /tmp/$1.line |tr ')' '\n' >/tmp/$1.wanted
    #URLS=`grep -o 'http:\\/\\/o-o' /tmp/$1.wanted`
    #URLS=`grep -o 'http:.*o-o.*"' /tmp/$1.wanted`
    URLS=`grep -o 'http:.*youtube\.com.*"' /tmp/$1.wanted`
    #URL1=`echo "$URLS" | grep -v '.xml$"'`
    URL1=`echo "$URLS" | grep -v '/crossdomain\.xml'`
    #URL=`echo "$URL1" |sed 's/^;yt.preload.start(//;s,\\\\u0026,\&,g;s|%2C|,|g;s|\\\\||g;s/"$//'`
    #URL=`echo "$URL1" |sed 's/^;yt.preload.start(//;s,\\\\u0026,\&,g;s|\\\\||g;s/\ /\%\2\0/g;s/"$//;s/generate_204/videoplayback/'`
    URL9=`echo "$URL1" |sed 's/^;yt.preload.start(//'`
    echo "URL='$URL9'"
    URL8=`echo "$URL9" |sed 's,\\\\u0026,\&,g;s|\\\\||g'`
    echo "URL='$URL8'"
    URL7=`echo "$URL8" |sed 's/"$//;s/generate_204/videoplayback/'`
    echo "URL='$URL7'"
    URL6=`echo "$URL7" |sed 's|\ |\%20|g'`
    echo "URL='$URL6'"
    URL="$URL6"
    fi
    TITLE=`grep '<title>.*</title>' /tmp/$1.wanted| sed 's|.*<title>||;s| - YouTube </title>||'`
    if [ ! "$TITLE" ];then
    TITLE9=`grep -A10 -m1 '<title>' /tmp/$1.tmp`
    TITLE8=`echo $TITLE9 | tr '[[:blank:]]' ' ' | tr -s ' '`
    TITLE7=`echo $TITLE8 | grep -o '<title>.*</title>'`
    TITLE6=`echo $TITLE7 | sed 's|<title>||;s| - YouTube </title>||'`
    TITLE="$TITLE6"
    fi
    [ ! "$TITLE" ] && TITLE="$RANDOM"
    TITLE=`echo "$TITLE" | sed 's|\ |\%20|g'`
    TITLE=`echo "$TITLE" | sed 's|/|_|g'`
    echo "URL='$URL'"
    echo "TITLE='$TITLE'"
    #GREATURL="\"${URL}&title=${TITLE}\""
    GREATURL="${URL}&title=${TITLE}"
    echo "GREATURL='$GREATURL'"
    if [ ! "$GREATURL" = "&title=${TITLE}" ];then
    #curl $GREATURL > "$DIR"/"$TITLE"
    curl $GREATURL -o "$DIR"/"$TITLE"
    CURLRV="$?"
    echo "CURLRV='$CURLRV'"
    read -p "Press Key to continue " KEY
    if [ "$CURLRV" != '0' ];then
    while [ "$CURLRV" != '0' ];do
    curl -C $GREATURL -o "$DIR"/"$TITLE"
    CURLRV="$?"
    done
    fi
    read -n1 -p "press any Key to quit " QKEY
    MIME=`file "$DIR"/"$TITLE"`
    FILENAME=`echo "$DIR"/"$TITLE" | sed 's|\%20| |g'`
    mv "$DIR"/"$TITLE" "$FILENAME"
    if [ "`echo "$MIME" | grep -i 'flash'`" ];then
    EXT='flv'
    elif [ "`echo "$MIME" | grep -i 'mp4'`" ];then
    EXT='mp4'
    fi
    if [ "$EXT" ];then
    mv "$FILENAME" "${FILENAME}.$EXT"
    fi
    exit
    else
    read -n1 -p "press any Key to quit " QKEY
    exit
    fi

func_2(){
    declare -a Url_array Geom_array Fmt_array
    UrlMap=${Tmp#*\"fmt_url_map\": \"}
    UrlMap=${UrlMap%%\"*}
    UrlMap=`echo ${UrlMap//,/ } | tac -s' '`
    GeomMap=${Tmp#*\"fmt_map\": \"}
    GeomMap=${GeomMap%%\"*}
    GeomMap=`echo ${GeomMap//,/ } | tac -s' '`

    j=0
    for i in ${UrlMap} ; do
        Fmt=${i%%|*}
        Url=${i#*|} ; Url=${Url%%|*}
        Url=${Url//\\\///}
        Url=${Url//\\\u0026/&}
        Url_array[$j]=$Url
        Fmt_array[$j]=$Fmt
        let j++
    done

    j=0
    for i in ${GeomMap} ; do
        Fmt=${i%%\\*}
        Geom=${i#*/} ; Geom=${Geom%%\\*}
        Geom_array[$j]="$Geom"
        let j++
    done

    #format list
    fmt[0]="flv"
    fmt[5]="flv"
    fmt[6]="flv"
    fmt[34]="flv"
    fmt[35]="flv"
    fmt[13]="3gp"
    fmt[17]="3gp"
    fmt[18]="mp4"
    fmt[22]="mp4"
    fmt[37]="mp4"
    fmt[38]="mp4"
    fmt[43]="webm"
    fmt[45]="webm"

    echo "----------------------------------"
    # List all the elements in the array.
    arr_count=${#Geom_array[@]}
    i=0
    while [ "$i" -lt "$arr_count" ]
    do
        echo [$i] ${Geom_array[$i]} ${fmt[${Fmt_array[$i]}]} #${Fmt_array[$i]}
        let i++
    done

    echo -n 'Select video format and press enter or just press enter to abort: '
    read infmt
    #rm /tmp/$1.tmp

    if [ ! "$infmt" ]
    then
        echo "Aborting..."
        sleep 10
        exit 0
    else
        #check if input integer
        if [ $infmt -ne 0 -o $infmt -eq 0 2>/dev/null ]
        then
            arr_in=${#Fmt_array[@]}
            if [ $infmt -lt $arr_in ]  &&  [ $infmt -ge "0" ]
            then
                echo "Downloading video..."
                echo "----------------------------------"

                #set file name
                echo 'You may want to provide a new file or use the existing title'
                echo 'Type new file name (no spaces) or just press enter to continue: '
                read newname

                if [ ! "$newname" ] ; then
                fn=$titlefn.${Geom_array[$infmt]}.${fmt[${Fmt_array[$infmt]}]}
                else
                fn=$newname.${Geom_array[$infmt]}.${fmt[${Fmt_array[$infmt]}]}
                fi

                chkval ${Url_array[$infmt]}
                wget -O - -t 7 -w 5 --waitretry=14 --random-wait '--user-agent=Mozilla/5.0' -e robots=off "${Url_array[$infmt]}" > "$DIR""$fn"
                #echo "File:" $fn ${Url_array[$infmt]}
                rm wget-log*
            fi
        fi
    fi

    echo "----------------------------------"
    echo ""
}
else
    echo "Usage: sh yt-download.sh [youtube_video_id] [save_directory] "
    echo "Example: sh yt-download.sh jNQXAC9IVRw $HOME/my-documents"
    exit
fi

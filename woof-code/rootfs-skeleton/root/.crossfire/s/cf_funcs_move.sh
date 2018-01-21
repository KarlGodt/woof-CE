#!/bin/ash

[ "$HAVE_FUNCS_MOVE" ] && return 0

___direction_to_number(){ # cf_funcs_common.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 0

lDIRECTION=`echo "$lDIRECTION" | tr '[A-Z]' '[a-z]'`
case $lDIRECTION in
0|center|centre|c) DIRECTION=0; DIRB=;          DIRF=;;
1|north|n)         DIRECTION=1; DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=2; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=3; DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=4; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=5; DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=6; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=7; DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=8; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error "Not recognized: '$lDIRECTION'";;
esac
}

___number_to_direction(){ # cf_funcs_common.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 0

lDIRECTION=`echo "$lDIRECTION" | tr '[A-Z]' '[a-z]'`
case $lDIRECTION in
0|center|centre|c) DIRECTION=center;    DIRB=;          DIRF=;;
1|north|n)         DIRECTION=north;     DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=northeast; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=east;      DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=southeast; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=south;     DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=southwest; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=west;      DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=northwest; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error "Not recognized: '$lDIRECTION'";;
esac
}

_turn_direction(){
test "$3" && { DIRECTION=${1:-DIRECTION}; shift; }
test "$DIRECTION" || return 0

_direction_to_number $DIRECTION
_is 0 0 ${1:-ready_skill} ${2:-lockpicking}
_is 0 0 fire $DIRECTION
_is 0 0 fire_stop
}

_open_door_with_standard_key(){
#DEBUG=1 _debug "_open_door_with_standard_key:$*"
local lDIRECTION=${1:-$DIRECTION}
#DEBUG=1 _debug "DIRECTION=$DIRECTION"
test "$lDIRECTION" || return 0
_number_to_direction "$lDIRECTION"
#DEBUG=1 _debug "DIRECTION=$DIRECTION"
_is 0 0 $DIRECTION
}

_move_back(){  ##+++2018-01-08
test "$DIRB" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRB
_sleep
done
}

_move_forth(){  ##+++2018-01-08
test "$DIRF" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRF
_sleep
done
}

_move_back_and_forth(){  ##+++2018-01-08
STEPS=${1:-1}

#test "$DIRB" -a "$DIRF" || return 0
test "$DIRB" || return 0
for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRB
_sleep
done

if test "$2"; then shift
 while test "$1";
 do
 #oIFS=$IFS
 #IFS=';'
 COMMANDS=`echo "$1" | tr ';' '\n'`
 test "$COMMANDS" || break 1
  echo "$COMMANDS" | while read line
  do
  $line
  sleep 0.1
  done

 #IFS=$oIFS
 shift
 sleep 0.1
 done
fi

test "$DIRF" || return 0
for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRF
_sleep
done
}

_check_for_space(){
# *** Check for [4] empty space to DIRB *** #
_debug "_check_for_space:$*"

local REPLY_MAP OLD_REPLY NUMBERT
test "$1" && NUMBERT="$1"
NUMBERT=${NUMBERT:-4}
test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

_empty_message_stream
echo request map pos

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville

while :; do
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log "$REPLY_LOG" "_check_for_space:request map pos:$REPLY_MAP"
_debug "$REPLY_MAP"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'` #request map pos:request map pos 280 231
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
southwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y+nr))
;;
southeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y+nr))
;;
esac

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }

_empty_message_stream
echo request map $R_X $R_Y

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_check_for_space:request map '$R_X' '$R_Y':$REPLY"
_debug "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
_debug "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

done

 else
  _exit 1 "Received Incorrect X Y parameters from server."
 fi

else
 _exit 1 "Could not get X and Y position of player."
fi

_draw 7 "OK."
}

_check_for_space_old_client(){
# *** Check for 4 empty space to DIRB *** #
_debug "_check_for_space_old_client:$*"

local REPLY_MAP OLD_REPLY NUMBERT cm
test "$1" && NUMBERT="$1"
NUMBERT=${NUMBERT:-4}
test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

_empty_message_stream
echo request map near

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville
#                request map near:request map     279 231  0 n n n n smooth 30 0 0 heads 4854 825 0 tails 0 0 0
cm=0
while :; do
cm=$((cm+1))
read -t $TMOUT REPLY_MAP
_log "$REPLY_LOG" "_check_for_space_old_client:request map near:$REPLY_MAP"
_debug "$REPLY_MAP"
test "$cm" = 5 && break
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

_empty_message_stream

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $3}'` #request map near:request map 278 230  0 n n n n smooth 30 0 0 heads 4854 0 0 tails 0 0 0
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $4}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
southwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y+nr))
;;
southeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y+nr))
;;
esac

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }

_empty_message_stream
echo request map $R_X $R_Y

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_check_for_space_old_client:request map '$R_X' '$R_Y':$REPLY"
_debug "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
_debug "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

done

 else
  _exit 1 "Received Incorrect X Y parameters from server."
 fi

else
 _exit 1 "Could not get X and Y position of player."
fi

_draw 7 "OK."
}

###END###
HAVE_FUNCS_MOVE=1

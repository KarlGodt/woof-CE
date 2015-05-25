#!/bin/bash

# client/common/script.c
# * draw {color} {text}
# *   display the text in the specified color as if the server had sent
# *   a drawinfo command.


#client/common/commands.c:

#void DrawExtInfoCmd(char *data, int len) {
#    int color;
#    int type, subtype;
#    char *buf = data;
#    int wordCount = 3;
#    ExtTextManager fnct;
#
#     fnct(color, type, subtype, buf);
#}

#void DrawInfoCmd(char *data, int len) {
#    int color = atoi(data);
#    char *buf;
#
#    (void)len; /* __UNUSED__ */
#
#    buf = strchr(data, ' ');
#    if (!buf) {
#        LOG(LOG_WARNING, "common::DrawInfoCmd", "got no data");
#        buf = "";
#    } else {
#        buf++;
#    }
#    draw_ext_info(color, MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_COMMAND, buf);
#}

#client/common/msgtype.h:
#
#const Msg_Type_Names msg_type_names[] = {
#{0, 0, "generic"},
#{MSG_TYPE_BOOK, 0, "book"},
#{MSG_TYPE_CARD, 0, "card"},
#{MSG_TYPE_PAPER, 0, "paper"},
#{MSG_TYPE_SIGN, 0, "sign"},
#{MSG_TYPE_MONUMENT, 0, "monument"},
#{MSG_TYPE_DIALOG, 0, "dialog"},
#{MSG_TYPE_MOTD, 0, "motd"},
#{MSG_TYPE_ADMIN, 0, "admin"},
#{MSG_TYPE_SHOP, 0, "shop"},
#{MSG_TYPE_COMMAND, 0, "command"},
#{MSG_TYPE_ATTRIBUTE, 0, "attribute"},
#{MSG_TYPE_SKILL, 0, "skill"},
#{MSG_TYPE_APPLY, 0, "apply"},
#{MSG_TYPE_ATTACK, 0, "attack"},
#{MSG_TYPE_COMMUNICATION, 0, "communication"},
#{MSG_TYPE_SPELL, 0, "spell"},
#{MSG_TYPE_ITEM, 0, "item"},
#{MSG_TYPE_MISC, 0, "misc"},
#{MSG_TYPE_VICTIM, 0, "victim"},
#
#{MSG_TYPE_CLIENT, 0, "client"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_CONFIG, "client_config"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_SERVER, "client_server"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_COMMAND, "client_command"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_QUERY, "client_query"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_DEBUG, "client_debug"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_NOTICE, "client_notice"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_METASERVER, "client_metaserver"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_SCRIPT, "client_script"},
#{MSG_TYPE_CLIENT, MSG_TYPE_CLIENT_ERROR, "client_error"},
#};

# server/socket/loop.c
#/** Prototype for functions the client sends without player interaction. */
#typedef void (*func_uint8_int_ns)(char *, int, socket_struct *);
#
#/** Definition of a function the client sends without player interaction. */
#struct client_cmd_mapping {
#    const char *cmdname;        /**< Command name. */
#    const func_uint8_int_ns cmdproc;  /**< Function to call. */
#};
#
#/** Prototype for functions used to handle player actions. */
#typedef void (*func_uint8_int_pl)(char *, int, player *);
#
#/** Definition of a function called in reaction to player's action. */
#struct player_cmd_mapping {
#    const char *cmdname;             /**< Command name. */
#    const func_uint8_int_pl cmdproc; /**< Function to call. */
#    const uint8 flag;                /**< If set, the player must be in the ST_PLAYING state for this command to be available. */
#};
#
#/**
# * Dispatch tables for the server.
# *
# * CmdMapping is the dispatch table for the server, used in handle_client,
# * which gets called when the client has input.  All commands called here
# * use the same parameter form (char *data, int len, int clientnum.
# * We do implicit casts, because the data that is being passed is
# * unsigned (pretty much needs to be for binary data), however, most
# * of these treat it only as strings, so it makes things easier
# * to cast it here instead of a bunch of times in the function itself.
# * flag is 1 if the player must be in the playing state to issue the
# * command, 0 if they can issue it at any time.
# */
#
#/** Commands sent by the client reacting to player's actions. */
#static const struct player_cmd_mapping player_commands[] = {
#    { "examine",    examine_cmd,                       1 },
#    { "apply",      apply_cmd,                         1 },
#    { "move",       move_cmd,                          1 },
#    { "reply",      reply_cmd,                         0 },
#    { "ncom",       (func_uint8_int_pl)new_player_cmd, 1 },
#    { "lookat",     look_at_cmd,                       1 },
#    { "lock",       (func_uint8_int_pl)lock_item_cmd,  1 },
#    { "mark",       (func_uint8_int_pl)mark_item_cmd,  1 },
#    { "mapredraw",  map_redraw_cmd,                    0 },  /* Added: phil */
#    { "inscribe",   inscribe_scroll_cmd,               0 },
#    { NULL,         NULL,                              0 }   /* terminator */
#};
#
#/** Commands sent directly by client, when connecting or when needed. */
#static const struct client_cmd_mapping client_commands[] = {
#    { "addme",               add_me_cmd },
#    { "askface",             send_face_cmd },             /* Added: phil */
#    { "requestinfo",         request_info_cmd },
#    { "setup",               set_up_cmd },
#    { "version",             version_cmd },

#void request_info_cmd(char *buf, int len, socket_struct *ns) {
#    char *params = NULL, *cp;
#    /* No match */
#    SockList sl;
#
#    if (!strcmp(buf, "image_info"))
#        send_image_info(ns, params);
#    else if (!strcmp(buf, "image_sums"))
#        send_image_sums(ns, params);
#    else if (!strcmp(buf, "skill_info"))
#        send_skill_info(ns, params);
#    else if (!strcmp(buf, "spell_paths"))
#        send_spell_paths(ns, params);
#    else if (!strcmp(buf, "exp_table"))
#        send_exp_table(ns, params);
#    else if (!strcmp(buf, "race_list"))
#
#    else if (!strcmp(buf, "knowledge_info"))
#        knowledge_send_info(ns);
#    else
#        Send_With_Handling(ns, &sl);
#    SockList_Term(&sl);
#}




# server/socket/lowlevel.c:
#/**
# * Calls Write_To_Socket to send data to the client.
# *
# * The only difference in this function is that we take a SockList
# *, and we prepend the length information.
# */
#void Send_With_Handling(socket_struct *ns, SockList *sl) {
#    if (ns->status == Ns_Dead || sl == NULL)
#        return;
#
#    sl->buf[0] = ((sl->len-2)>>8)&0xFF;
#    sl->buf[1] = (sl->len-2)&0xFF;
#    Write_To_Socket(ns, sl->buf, sl->len);
#}


# global variables :
GO_BACK=west
GO_FORTH=east

# *** Here begins program *** #
echo drawextinfo 2 1 1 "$0 is started <$*> , pid $$ ppid $PPID"

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo drawextinfo 5 10 10 "Script to produce water of the wise."
echo drawextinfo 7 10 10 "Syntax:"
echo drawextinfo 7 10 10 "$0 NUMBER"
echo drawextinfo 5 10 10 "Allowed NUMBER will loop for"
echo drawextinfo 5 10 10 "NUMBER times to produce NUMBER of"
echo drawextinfo 5 10 10 "Water of the Wise ."

        exit 0
        }

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo drawextinfo 0x3 0x0 0x0 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
echo drawextinfo 0x003 0x001 0x001 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo drawextinfo 0x03 0x01 0x01 "Need <number> ie: script $0 3 ."
        exit 1
}

# *** Check if standing on a cauldron *** #

echo drawextinfo 4 1 1 "Checking if on cauldron..."
UNDER_ME='';
echo request items on

while [ 1 ]; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo drawextinfo 0x03 0x01 0x01 "Need to stand upon cauldron!"
exit 1
}

echo drawextinfo 0xd61417 0x01 0x01 "Done."

# *** Actual script to alch the desired water of the wise           *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water --                        *** #
# *** only one inventory line with water(s) allowed !!              *** #

# *** Now get the number of desired water of                        *** #
# *** seven times the number of the desired water of the wise.      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $GO_BACK of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

rm -f /tmp/cf_script.rpl # empty reply old log file


# *** Readying rod of word of recall - just in case *** #

echo drawextinfo 0x04 0x1 0x1 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo drawextinfo 7 "Done."

# *** EXIT FUNCTIONS *** #
f_exit(){
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
sleep 1s
echo drawextinfo 0x3 0x1 0x1 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
#echo unwatch drawextinfo
echo unwatch drawinfo
exit $1
}

f_emergency_exit(){
echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo drawextinfo 3 1 1 "Emergency Exit $0 !"
#echo unwatch drawextinfo
echo unwatch drawinfo
echo "issue 1 1 fire_stop"
exit $1
}


# *** Getting Player's Speed *** #

echo drawextinfo 0xd61414 0x1 0x1 "Processing Player's Speed..."

SLEEP=4           # setting defaults
DELAY_DRAWINFO=8

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while [ 1 ]; do
read -t 1 ANSWER
echo "$ANSWER" >>/tmp/cf_request.log
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash
PL_SPEED="0.${PL_SPEED:0:2}"

echo drawextinfo 7 "" "" "Player speed is $PL_SPEED"

PL_SPEED="${PL_SPEED:2:2}"
echo drawextinfo 0x07 0x01 0x01 "Player speed is $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1; DELAY_DRAWINFO=2
elif test $PL_SPEED -gt 28; then
SLEEP=2; DELAY_DRAWINFO=4
elif test $PL_SPEED -gt 15; then
SLEEP=3; DELAY_DRAWINFO=6
fi

echo drawextinfo 0x7 0x2 0x2 "Done."


# *** Check if cauldron is empty *** #

echo drawextinfo 0x4 0x3 0x3 "Checking if cauldron is empty..."

echo "issue 1 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

echo "issue 1 1 apply"
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

while [ 1 ]; do
#echo "issue 1 1 get"
read -t 5 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo drawextinfo 3 0 0 "REPLY_ALL='"${REPLY_ALL}"'"

test "`echo "$REPLY_ALL" | grep 'Nothing to take!'`" || {
echo drawextinfo 0x3 "" "" "Cauldron NOT empty !!"
echo drawextinfo 0x3 " " " " "Please empty the cauldron and try again."
f_exit 1
}

#echo unwatch drawextinfo
echo unwatch drawinfo

echo drawextinfo 7 1 2 "OK ! Cauldron IS empty."

sleep ${SLEEP}s

echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
sleep ${SLEEP}s


echo drawextinfo 4 2 3 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

echo "issue 1 1 drop 7 water"


while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done


#echo unwatch drawextinfo
echo unwatch drawinfo

sleep ${SLEEP}s

echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
sleep ${SLEEP}s



#echo watch drawextinfo
echo watch drawinfo

echo "issue 1 1 use_skill alchemy"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch drawextinfo
echo unwatch drawinfo

echo "issue 1 1 apply"
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

echo "issue 7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch drawextinfo
echo unwatch drawinfo

sleep ${SLEEP}s

echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
echo "issue 1 1 $GO_BACK"
sleep ${SLEEP}s

if test $NOTHING = 0; then

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep ${SLEEP}s

#if test $NOTHING = 0; then
#for drop in `seq 1 1 7`; do  # unfortunately does not work without this nasty loop
echo "issue 0 1 drop water of the wise"    # issue 1 1 drop drops only one water
echo "issue 0 1 drop waters of the wise"
echo "issue 0 1 drop water (cursed)"
echo "issue 0 1 drop waters (cursed)"
echo "issue 0 1 drop water (magic)"
echo "issue 0 1 drop waters (magic)"
#echo "issue 0 1 drop water (magic) (cursed)"
#echo "issue 0 1 drop waters (magic) (cursed)"
echo "issue 0 1 drop water (cursed) (magic)"
echo "issue 0 1 drop waters (cursed) (magic)"
#echo "issue 0 1 drop water (unidentified)"
#echo "issue 0 1 drop waters (unidentified)"

echo "issue 0 1 drop slag"               # many times draws 'But there is only 1 slags' ...
#echo "issue 0 1 drop slags"

fi

sleep ${DELAY_DRAWINFO}s
#done                         # to drop all water of the wise at once ...

echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
echo "issue 1 1 $GO_FORTH"
sleep ${SLEEP}s

sleep 2  ##2015-05-24 needed for speed 0.44-0.46 and 0.14-0.15

echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while [ 1 ]; do
read -t 1 UNDER_ME
echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
test "$UNDER_ME" || break

sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
#echo drawextinfo 0x3 0x0 0x0 "LOOP BOTTOM: NOT ON CAULDRON!"
echo drawextinfo 3 0 0 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawextinfo 0x4 " " " " "Elapsed $TIME s, still '$TRIES_STILL' to go..."

done

# *** Here ends program *** #
echo drawextinfo 2 1 1 "$0 is finished."

#!/bin/sh

_f0(){
for a in name stats cmbt hp xp lvl resists
do

echo request stat $a

read -t 1 ANSWER
echo draw 3 "$ANSWER"
sleep 1
echo draw 3 ""
done
}

#Communication commands:
#
# accuse beg bleed blush bounce bow burp \
# cackle chat chuckle clap cointoss cough cringe cry \
# dance flip frown gasp giggle glare grin groan growl \
# hiccup hug kiss laugh lick me nod orcknuckle \
# poke pout printlos puke reply \
# say scream shake shiver shout shrug sigh slap smile smirk \
# snap sneeze snicker sniff snore spit strut sulk \
# tell thank think twiddle wave whistle wink yawn
#

echo watch drawinfo

for player_name in karl Karl KARL Karl_ Trollo Aelfdoerf kalle kalli
do
sleep 0.1
echo issue 1 1 hug $player_name
sleep 0.1
read -t 1 ANSWER
echo draw 2 "ANSWER=$ANSWER"
case $ANSWER in *You*hug*yourself*) NAME=$player_name; break 2;; esac
sleep 0.1
unset ANSWER
done

if test "$NAME"; then
 echo draw 2 "Your name found out to be $NAME"
else
 echo draw 3 "Error finding your name."
fi

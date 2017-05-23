#!/bin/ash





_use_skill(){

echo watch $DRAW_INFO

local c=0
local NUM=$NUMBER

while :;
do

echo issue 1 1 use_skill "$*"

test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = 99 && break; }

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1

}




_handle_disease_msgs(){
# arch/disease/

case $REPLY in

# REM: invoke/cast cure disease
*You*can*no*longer*use*the*skill:*)   # use magic item.

;;

*You*stop*using*the*talisman*)        # of Unified Mind *.

;;

*You*feel*stupid*)

;;

*You*stop*using*the*holy*symbol*)     # of Probity *.

;;

*You*ready*holy*symbol*)

;;

*You*can*now*use*the*skill:*praying*)

;;

*You*cure*a*disease*)

;;

*You*no*longer*feel*diseased*)

;;

# REM: becomming ill
*You*suddenly*feel*ill*)

;;

# REM: # arch/disease/*.arc

#You have warts.  They are ugly and annoying.
#You have warts.  They are ugly and annoying.
*You*have*warts*|*They*are*ugly*and*annoying*)  # warts.arc

;;

#You feel feverish.  Your muscles spasm oddly....  Breathing is difficult.
*You*feel*feverish*|*Your*muscles*spasm*oddly*|*Breathing*is*difficult*)  # typhoid.arc,anthrax.arc

;;

# A tooth wiggles loose and falls to the
# ground.  You should brush more.  Have I
# mentioned that your breath is disgusting,
# too?
#A tooth wiggles loose and falls to the ground.  You should brush more.  Have I mentioned that your breath is disgusting, too?
*A tooth*wiggles*loose*and*falls*to*the*ground*|*You*should*brush*more*|*mentioned*that*your*breath*is*disgusting*|*too*)  # tooth_decay.arc

;;

#You feel more hungry than usual.  You also feel an urge to refer to yourself in the plural.
*You*feel*more*hungry*than*usual*|*You*also*feel*an*urge*to*refer*to*yourself*in*the*plural*)  # tapeworms.arc

;;

#You have a nasty rash all over you.  Are those pustules?
*You*have*a*nasty*rash*all*over*you*|*Are*those*pustules*)  # smallponx.arc

;;

# You spit out a tooth.  Better increase that
# dietary vitamin C!
#You spit out a tooth.  Better increase that dietary vitamin C!
*You*spit*out*a*tooth*|*Better*increase*that*dietary*vitamin*C*)  # scurvy.arc
*You*spit*out*a*tooth*|*dietary*vitamin*C*)

;;

#You notice everyone is looking at you with evil intent.  You must kill them!  You begin to salivate.
*You*notice*everyone*is*looking*at*you*with*evil*intent*|*You*must*kill*them*|*You*begin*to*salivate*)  # rabies.arc

;;

#You cough up some nasty green phlegm.
*You*cough*up*some*nasty*green*phlegm*)  # pneumonic_plague.arc

;;


#You have aches and fever, and you feel nauseous.
*You*have*aches*and*fever*and*you*feel*nauseous*)  # plague.arc,flu.arc

;;

# Splotches are spreading around your body.
# You feel disgusted with yourself.  A piece
# of skin flakes off and falls to the ground.
#Splotches are spreading around your body. You feel disgusted with yourself.  A piece of skin flakes off and falls to the ground.
*Splotches*are*spreading*around*your*body*|*You*feel*disgusted*with*yourself*|*skin*flakes*off*and*falls*to*the*ground*)  # leprosy.arc

;;

# You start gibbering incoherently.  You
# forget where you are and what you were doing.
#You start gibbering incoherently.  You forget where you are and what you were doing.
*You*start*gibbering*incoherently*|*You*forget*where*you*are*and*what*you*were*doing*)  # insanity.arc

;;

# You can't control your bladder.  You have a
# messy accident.  Yuck!
#You can't control your sphincter.  You have a messy accident.  Yuck!
#You can't control your bladder.  You have a messy accident.  Yuck!
*You*can*control*your*bladder*|*You*have*a*messy*accident*|*Yuck*)  # incontinence.arc
*You*can*control*your*bladder*|*messy*accident*Yuck*)

;;

#You have aches and fever, and you feel nauseous.
#You have aches and fever, and you feel nauseous.
*You*have*aches*and*fever*and*you*feel*nauseous*)  # flu.arc,plague.arc

;;

#You blow a great fart.  It ignites.  My God, the REEK!
*You*blow*a*great*fart*|*It*ignites*|*My*God*the*REEK*)  # flaming_fart.arc

;;

#Buck, buck, buck, buck!  You lay an EGG!!
#You feel ridiculous.
*Buck*buck*buck*buck*You*lay*an*EGG*|*You*feel*ridiculous*)  # egg_disease.arc

;;

#Blood leaks out of your eyes and your pores!
Blood*leaks*out*of*your*eyes*and*your*pores*)  # ebola.arc

;;

#You can't control your bladder.  You have a messy accident.  Yuck!
#You can't control your sphincter.  You have a messy accident.  Yuck!
*You*can*control*your*sphincter*|*You*have*a*messy*accident*|*Yuck*)  # diarrhea.arc

;;

#Frost creeps over your body!
*Frost*creeps*over*your*body*)  # creeeping_frost.arc

;;

#You develop a sniffle.
*You*develop*a*sniffle*)  # cold.arc

;;

#Your feet itch.  They burn.
*Your*feet*itch*They*burn*)  # atheletes_foot.arc

;;

#Your joints are swollen.  You feel weak and
#less dextrous.
#Your joints are swollen.  You feel weak and less dextrous.
*Your*joints*are*swollen*|*You*feel*weak*and*less*dextrous*)  # arthritis.arc
*Your*joints*are*swollen*|*less*dextrous*)
;;


esac

}

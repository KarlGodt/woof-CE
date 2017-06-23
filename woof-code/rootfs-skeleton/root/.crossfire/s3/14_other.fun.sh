#!/bin/ash


_skip_noise(){
local RV=0

case $REPLY in

  # msgs from cast dexterity
  *'You lack the skill '*)                  :;;
  *'You can no longer use the skill:'*)     :;;
  *'You ready'*)                            :;;  #You ready talisman of sorcery *. the spell holy symbol of Probity *.
  *'You can now use the skill:'*)           :;;  # praying.
  *'You grow no more agile'*)               :;;
  *'You recast the spell while in effect'*) :;;
  *'The effects'*'are draining out'*)       :;;
  *'The effects'*'are about to expire'*)    :;;
  *'You feel'*)                             :;; # clumsy. stronger. more agile. healthy. smarter.

  # msgs from cure disease
  *'You stop using the'*) :;; # talisman of Frost *.
  *'You cure'*)           :;; # a disease!
  *'You no longer feel'*) :;; # diseased.

  #msgs from cure poison
  *'Your body feels'*) :;; # cleansed

  *' entered '*|*' leaves '*|*' left '*) :;; # the game
  *' chats:'*|*' tells you:'*)           :;;

   *'You feel full'*) :;;  # , but what a waste of food!
   *' tasted '*)      :;;  # food tasted good
   *' your '*)        :;;  #
   *'Your '*)         :;;  # Your monster beats monster
   *'You killed '*)   :;;

 #*) _debug "_skip_noise:Ignoring REPLY";;
  *)  RV=1;;

esac

return ${RV:-4}
}

#!/bin/ash

tmpDir=/tmp/locale
  rm -fr $tmpDir
mkdir -p $tmpDir/log

ERR=/dev/null

  CHARMAPS=`ls -1 /usr/share/i18n/charmaps | sed 's%\.gz$%%'`
ALL_LANGUAGES=`ls -1 /usr/share/i18n/locales`
#LANGUAGES=`ls -1 /usr/share/i18n/locales/ | grep '^de'`

CHOICE_LANGUAGES=`echo "$ALL_LANGUAGES" | sed 's%_.*%%'`

echo $CHOICE_LANGUAGES
echo
read -p "Enter one of the above laguage abbr. : " lang_abbr

[ "$lang_abbr" ] || { echo " Nothing to do."; exit 0; }
echo "$ALL_LANGUAGES" | grep "^${lang_abbr}_" && echo "Input OK." || { echo "Wrong Input."; exit 1; }

LANGUAGES=`ls -1 /usr/share/i18n/locales/ | grep "^${lang_abbr}_"`

for A_LANG_ in $LANGUAGES
do
  echo "$A_LANG_"
  for A_MAP_ in $CHARMAPS
  do
  echo -n "$A_MAP_"
  OK=NO
  #localedef --force -v -f $A_MAP_ -i $A_LANG_ ${A_LANG_}.${A_MAP_} > $tmpDir/log/${A_LANG_}.${A_MAP_}.log 2>&1
  localedef --no-archive -f $A_MAP_ -i $A_LANG_ ${A_LANG_}.${A_MAP_} > $tmpDir/log/${A_MAP_}.${A_LANG_}.log 2>&1 #&& OK=YES || OK=NO
      RV=$?
  [ $RV = 0 ] && OK=YES || { echo "'$A_LANG_' '$_A_MAP_' returnvalue < $RV >"; OK=NO; }

  TRUNC_MAP=`echo ${A_MAP_//-/} |tr '[A-Z]' '[a-z]'`
  if [ "$OK" = NO ] ; then
  if ls /usr/lib/locale/${A_LANG_}.${TRUNC_MAP} 2>$ERR ; then
   rmdir /usr/lib/locale/${A_LANG_}.${TRUNC_MAP} 2>$ERR && OK=NO || OK=YES
  elif  ls /usr/lib/locale/${A_LANG_}.${A_MAP_} 2>$ERR ; then
   rmdir /usr/lib/locale/${A_LANG_}.${A_MAP_} 2>$ERR && OK=NO || OK=YES
  else
   rmdir /usr/lib/locale/${A_LANG}* 2>$ERR
   OK=NO
  fi;fi
  [ "$OK" = YES ] && echo "$A_LANG_ $A_MAP_" >> $tmpDir/${A_LANG_}.SUPPORTED
  echo " OK='$OK'"
  [ -s $tmpDir/log/${A_MAP_}.${A_LANG_}.log ] || rm $tmpDir/log/${A_MAP_}.${A_LANG_}.log

  done
done

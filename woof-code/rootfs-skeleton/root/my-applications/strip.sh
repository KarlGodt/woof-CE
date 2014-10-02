#!/bin/sh


old_code(){
echo Finding lib directories ..
LIB_DIRS=`find /usr -type d -name "lib"`
echo .. done

for d in $LIB_DIRS; do
cd $d
echo -n where am i :
pwd
sleep 3s

 for n in {a..z}; do

 echo Finding lib$n ...
 LIBS=`find -type f -name "lib${n}*.so*"`
 echo .. done

  for l in $LIBS; do
  file $l | grep ' not stripped' || { as=$((as+1));continue; }

  echo -n "Stripping $l ..."
  fs=`ls -s $l |awk '{print $1}'`
  strip --strip-unneeded $l
  sleep 1
  fsn=`ls -s $l |awk '{print $1}'`
  [ $fs = $fsn ] && echo "UNSUCCESSFUL" || echo
  ns=$((ns+1))
  done
 done

 for n in {A..Z}; do

 echo Finding lib$n ...
 LIBS=`find -type f -name "lib${n}*.so*"`
 echo .. done

  for l in $LIBS; do
  file $l | grep 'not stripped' || { as=$((as+1));continue; }

  echo -n "Stripping $l ..."
  fs=`ls -s $l |awk '{print $1}'`
  strip --strip-unneeded $l
  sleep 1
  fsn=`ls -s $l |awk '{print $1}'`
  [ $fs = $fsn ] && echo "UNSUCCESSFUL" || echo
  ns=$((ns+1))
  done
 done

done

echo ALREADY STRIPPED were $as
echo NOT STRIPPED were $ns
}


strip_them(){
  for l in $LIBS; do
  file $l | grep 'not stripped' || { as=$((as+1));continue; }

  echo -n "Stripping $l ..."
  fs=`ls -s $l |awk '{print $1}'`
  strip --strip-unneeded $l
  sleep 1
  fsn=`ls -s $l |awk '{print $1}'`
  [ $fs = $fsn ] && echo "No Size difference by ls -s" || echo
  ns=$((ns+1))
  done
}

find_them(){
 echo "Finding $pre$n*$post* ..."
 LIBS=`find -type f -name "${pre}${n}*${post}*"`
 echo .. done
}

find_and_strip_them_loop(){

for n in {a..z}; do
find_them
strip_them
done
for n in {A..Z}; do
find_them
strip_them
done

}

change_there(){
for d in $WANTED; do
cd $d
echo -n where am i :
pwd
sleep 3s
find_and_strip_them_loop
done
}


variables(){

target=/usr
wanted=sbin  #directory
pre=''       #lib
post=''      #.so

}


program(){
echo Finding $wanted directories in $target ..
WANTED=`find $target -type d -name "$wanted"`
echo .. done
change_there
}

final_message(){
echo ALREADY STRIPPED were $as
echo NOT STRIPPED were $ns
}

variables
program
final_message

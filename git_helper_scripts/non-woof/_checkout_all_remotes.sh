#!/bin/sh


_in_current_directory(){
git branch -a | while read br;
do
case $br in
remotes/*):;;
*)continue;;
esac;
echo $br;

#sbr=${br##*.git/};
sbr=`echo "$br" | cut -f3- -d'/'`
echo $sbr;

git branch | grep "$sbr" && continue;
git checkout $br && git branch $sbr && git checkout $sbr;

sleep 4;
done
}

_all_sub_directories(){
for i in *; do
[ -d "$i" ] || continue;
echo $i; cd $i || continue;
git branch -a ;

 git branch -a | while read br;
 do
 case $br in remotes/*):;;
 *)continue;;
 esac;
 echo $br;

 #sbr=${br##*.git/};
 sbr=`echo "$br" | cut -f3- -d'/'`
 echo $sbr;
 git branch | grep "${sbr}$" && continue;

 git checkout $br && git branch $sbr && git checkout $sbr;
 sleep 4;
 done;

 cd ..;
done
}

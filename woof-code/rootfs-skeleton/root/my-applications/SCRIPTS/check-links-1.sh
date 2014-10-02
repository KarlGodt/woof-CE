#!/bin/bash
####
#####Thu Oct 13 09:38:16 GMT-8 2011
###

parameterJunktion_func(){
for param in "$@" ; do
echo "$param"
case $param in
"-d * "|--dir=* ) : ;;
"-h * "|--help) : ;;
"-c * "|--check=* ) : ;;
"-r * "|--repair=* ) : ;;
*) : ;;
esac
done
}

if [ "$1" ] ; then
cd "$1"
else
cd `pwd`
fi

currentDir="`pwd`"
echo currentDir=$currentDir
echo 10
mountPoints=`busybox mount | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/^ *//g' | cut -f 3 -d ' ' | grep -v -w '/'`
echo 11
echo $mountPoints
for dir in $mountPoints ; do
echo $dir
grepPattern=`echo $dir | sed 's/\\//\\/\\//g'`
echo grepPattern=$grepPattern
if [ -n "`echo $currentDir | grep "$dir"`" ] ; then
echo 20
sedPattern=`echo $dir | sed 's/\\//\\/\\//g'`
echo 21
echo "$sedPattern"

currWorkingDir=`echo "$currentDir" | sed "s%$dir%%"`
echo currWorkingDir=$currWorkingDir
break
fi
done
#exit


check_func(){

links=`find . -maxdepth 1 -type l | sort -d`

for link in $links ; do
echo $link

lsl=`ls -l $link`

linkTarget=`echo $lsl | rev | sed 's/^[[:blank:]]*//' | cut -f 1 -d ' ' | rev`

if [ -n "`echo $linkTarget | grep '/'`" ] ; then

echo "$linkTarget" | grep -o '^\.\./'

if [[ -n `echo "$linkTarget" | grep "^/"` ]] && [[ -z `echo "$linkTarget" | grep -o "^\\.\\./"` ]] ; then

echo $currentDir
echo $currWorkingDir
echo $linkTarget
echo -e "\e[0;36m""$lsl""\e[0;39m\n""not a relative link"

debug_func_100(){
realPath=`realpath $link`
echo realPath=$realPath
readLink=`readlink $link`
echo readLink=$readLink
readLinkm=`readlink -m $link`
echo readLinkm=$readLinkm
readLinkf=`readlink -f $link`
echo readLinkf=$readLinkf
readLinke=`readlink -e $link`
echo readLinke=$readLinke
}

baseNameLinkToRm=`basename $link`
realPathLinkToRm="${currWorkingDir}/${baseNameLinkToRm}"
echo realPathLinkToRm=$realPathLinkToRm

dirNameLinkToRm=`dirname $realPathLinkToRm`
dirNameLinkTarget=`dirname $linkTarget`
[ "$dirNameLinkTarget" == "." ] && dirNameLinkTarget="$dirNameLinkToRm"
baseNameLinkTarget=`basename $linkTarget`

echo dirNameLinkToRm=$dirNameLinkToRm
echo dirNameLinkTarget=$dirNameLinkTarget

#pattern1=${dirNameLink/\(\/\)/ /}
#pattern2=${dirNameLinkTarget/\// /}

pattern1=`echo "$dirNameLinkToRm" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`
pattern2=`echo "$dirNameLinkTarget" | tr '/' ' ' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern1=$pattern1
echo pattern2=$pattern2

pattern11=`echo $pattern1 | rev`
pattern22=`echo $pattern2 | rev`

echo pattern11=$pattern11
echo pattern22=$pattern22

for i in $pattern11 ; do
new=`echo $i | rev`
pattern111="$pattern111 $new"
done
pattern111=`echo $pattern111 | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`
 
for i in $pattern22 ; do
new=`echo $i | rev`
pattern222="$pattern222 $new"
done
pattern222=`echo $pattern222 | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'`

echo pattern111=$pattern111
echo pattern222=$pattern222
pattern1111="$pattern111"
pattern2222="$pattern222"

echo -e "\e[1;33m"`dirname $currWorkingDir` `dirname $dirNameLinkTarget`"\e[0;39m" 

if [[ "$pattern111" == "$pattern222" ]] ; then
echo -e "\e[1;31m""same directory""\e[0;39m"
echo "rm link .."
rm $link
echo "creating link $baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s $baseNameLinkTarget $currentDir/$baseNameLinkToRm

elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo "same dir"
shortPattern=`echo "$dirNameLinkTarget" | grep -o "^$dirNameLinkToRm"`
echo shortPattern=$shortPattern
shortPattern1=`echo $shortPattern | sed 's#\/#\\\/#g'`
echo shortPattern1=$shortPattern1
shortPattern2=`echo $dirNameLinkTarget | sed "s/^$shortPattern1//"`
echo shortPattern2=$shortPattern2
shortPattern3=`echo $shortPattern2 | sed 's#^\/##'`
#baseNameLinkTarget2222=`basename $dirNameLinkTarget`
echo "removing $link"
rm $link
echo "creating  $shortPattern3/$baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s $shortPattern3/$baseNameLinkTarget $currentDir/$baseNameLinkToRm



#elif [[ "`dirname $currWorkingDir`" == "`dirname $dirNameLinkTarget`" ]] ; then
#echo -e "\e[1;31m""same upper directory""\e[0;39m"
#echo "rm link .."
#rm $link
#echo "creating link ../$baseNameLinkTarget $dirNameLinkTarget/$baseNameLinkToRm"
#ln -s ../$baseNameLinkTarget $dirNameLinkTarget/$baseNameLinkToRm  ##typo solved :coun1=$((count+1))
else

count1=0
for j in $pattern1111 ; do
count1=$((count1+1))
done
count1=$((count1-1))
echo count1=$count1
wcWordsPattern2222=`echo $pattern2222 | wc -w`
echo wcWordsPattern2222=$wcWordsPattern2222

for j in `seq $count1 -1 $wcWordsPattern2222` ; do
pattern2222="fake_for_$$ $pattern2222"
done

echo pattern2222=$pattern2222

count2=0
for j in $pattern2222 ; do
count2=$((count2+1))
done
count2=$((count2-1))
echo count2=$count2
wcWordsPattern1111=`echo $pattern1111 | wc -w`
echo wcWordsPattern1111=$wcWordsPattern1111

for j in `seq $count2 -1 $wcWordsPattern1111` ; do
pattern1111="fake_for_$$ $pattern1111"
done

echo pattern1111=$pattern1111

if [[ -n "`echo $pattern1111 | grep "fake_for_$$"`" ]] ; then

func_1000(){ #169
count3=0; wayBack=0

for content in $pattern1111 ; do
count3=$((count3+1))
echo $pattern2222 | cut -f $count3 -d ' '
if [[ "$content" != "`echo $pattern2222 | cut -f $count3 -d ' '`" ]] ; then
echo "$content not equal"
if [[ "`echo $pattern2 | wc -w`" -gt "`echo $pattern1 | wc -w`" ]] ; then
echo "wc -w $pattern2 -gt $pattern1"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
else
echo "$content is equal"
if [[ "`echo $pattern1 | wc -w`" -gt "`echo $pattern2 | wc -w`" ]] ; then
echo "wc -w $pattern1 -gt $pattern2"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
fi
done
} #func1000 157

count3=0; wayBack=0
for content in $pattern1111 ; do  ##pattern1
echo content=$content
count3=$((count3+1))

if [[ "$content" != "`echo $pattern2 | cut -f $count3 -d ' '`" ]] ; then
echo "$content not equal"
if [[ "`echo $pattern2 | wc -w`" -gt "`echo $pattern1 | wc -w`" ]] ; then
echo "wc -w $pattern2 -gt $pattern1"
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
else
echo "$content is equal"
if [[ "`echo $pattern1 | wc -w`" -gt "`echo $pattern2 | wc -w`" ]] ; then
echo "wc -w $pattern1 -gt $pattern2"
fi
fi
done

for k in `seq 1 $wayBack` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath=$dirNameLinkTarget
echo relativePath=$relativePath
count4=1
for k in `seq 1 $wayBack` ; do
echo k2  ##for k in $pathWayBacK "../../" == 1
count4=$((count4+1))
echo $k $count4 $dirNameLinkTarget
relativePathField=`echo $dirNameLinkTarget | cut -f $count4 -d '/'`
echo relativePathField=$relativePathField

if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $dirNameLinkTarget | cut -f $count4 -d '/'`" != "`echo $dirNameLinkToRm | cut -f $count4 -d '/'`" ]] ; then
echo $dirNameLinkTarget | cut -f $count4 -d '/'
echo $dirNameLinkToRm | cut -f $count4 -d '/'
relativePath=`echo $relativePath | sed 's#^#\.\.\/#' | tr -s '/'`
else
echo 'else'
echo $dirNameLinkTarget | cut -f $count4 -d '/'
echo $dirNameLinkToRm | cut -f $count4 -d '/'
relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"`
fi
else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done
relativePath=`echo $relativePath | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e $relativePath/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo "creating link .."
echo $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
ln -s $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[1;31m""WARNING: $relativePath/$baseNameLinkTarget does not exists""\e[0;39m"
sleep 5s
fi 
#pathWayBack='';pathWayBack=''
#pattern1='';pattern11='';pattern111='';pattern1111=''
#pattern2='';pattern22='';pattern222='';pattern2222=''

elif [[ "`echo  "$pattern1" | wc -w`" == "`echo "$pattern2" | wc -w`" ]] ; then
echo "same above sub dir"
baseNameLinkTarget2222=`basename $dirNameLinkTarget`
echo "removing $link"
rm $link
echo "creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm

elif [[ -n "`echo "$dirNameLinkTarget" | grep "^$dirNameLinkToRm"`" ]] ; then
echo "same sub dir"
baseNameLinkTarget2222=`basename $dirNameLinkTarget`
echo "removing $link"
rm $link
echo "creating ../$baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm"
ln -s $baseNameLinkTarget2222/$baseNameLinkTarget $currentDir/$baseNameLinkToRm

else
echo "pattern2222 turn ..."

count3=0; wayBack=0
for content in $pattern2222 ; do
echo $content
count3=$((count3+1))
if [[ "$content" != "`echo $pattern1111 | cut -f $count3 -d ' '`" ]] ; then
wayBack=$((wayBack+1))
echo wayBack=$wayBack
fi
done

for k in `seq 1 $wayBack` ; do  ##for k in $wayBack == 1
pathWayBack="${pathWayBack}../"
done
echo pathWayBack=$pathWayBack

relativePath=$dirNameLinkTarget
echo relativePath=$relativePath
count4=0
for k in `seq 1 $wayBack` ; do  ##for k in $pathWayBacK "../../" == 1
count4=$((count4+1))
echo $k $count4 $dirNameLinkTarget
relativePathField=`echo $pattern2222 | cut -f $count4 -d ' '`
echo relativePathField=$relativePathField
if [ "$relativePathField" ] ; then
echo "relativePathField not empty"
if [[ "`echo $pattern2222 | cut -f $count4 -d ' '`" == "`echo $pattern2222 | cut -f $count4 -d ' '`" ]] ; then
################################################### !=
echo $dirNameLinkTarget | cut -f $((count4+1)) -d '/'
echo $dirNameLinkToRm | cut -f $((count4+1)) -d '/'
relativePath=`echo $relativePath | sed "s/^/\\.\\.\\//"`
echo relativePathField=$relativePathField
else
echo 'else'
echo $dirNameLinkTarget | cut -f $((count4+1)) -d '/'
echo $dirNameLinkToRm | cut -f $((count4+1)) -d '/'
relativePath=`echo $relativePath | sed "s/$relativePathField/\\.\\./"`
fi
else
echo -e "\e[1;31m""WARNING: Link PATH not ok""\e[0;39m"
fi
done
relativePath=`echo $relativePath | sed 's#^\/\.\.#\.\.#' | tr -s '/'`
echo relativePath=$relativePath

if [ -e $relativePath/$baseNameLinkTarget ] ; then
echo "removing $link"
rm $link
echo "creating link .."
echo $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
ln -s $relativePath/$baseNameLinkTarget $currentDir/$baseNameLinkToRm
else
echo -e "\e[1;31m""WARNING: $relativePath/$baseNameLinkTarget does not exists""\e[0;39m"
sleep 5s
fi 

fi
pathWayBack='';pathWayBack=''
pattern1='';pattern11='';pattern111='';pattern1111=''
pattern2='';pattern22='';pattern222='';pattern2222=''

fi
else
echo -e "\e[1;32m""OK , $lsl""\n""is a leative link""\e[\0;39m"
fi

fi

done
}

check_func







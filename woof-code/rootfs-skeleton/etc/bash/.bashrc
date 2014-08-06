echo "$0"
echo "/etc/bash/.bashrc"
echo `pwd`
echo "fin"

echo "$0"
echo "/etc/bash/.bashrc.system"
echo PWD=`pwd`
#PATH="$PATH:/usr/local/bin"
#PATH="$PATH:/usr/local/sbin"
PATH=/bin:/sbin:\
/usr/bin:/usr/sbin:\
/usr/local/bin:/usr/local/sbin:\
/usr/X11R7/bin:\
/usr/SVC/bin:\
/root/my-applications/bin:/root/my-applications/sbin:\
/root/my-roxapps:/var/sbin

for dir in `echo $PATH | tr ':' ' '`;do
for char in a-e f-j k-o p-t u-z ;do
add="$dir/$char"
PATH="${PATH}:${add}"
done
done
PATH=`echo $PATH | sed 's% %%g;s%^:%%;s%:$%%'`

echo "Line $LINENO . parsed . fin."

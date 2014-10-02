Q=
ps-FULL -o ppid,lwp,tty,start,s,psr,pcpu,args -C pup_event_frontend_d
ps-FULL -o ppid,lwp,tty,start,s,psr,pcpu,args -C pup_event_frontend_d --no-headers
ps-FULL -o ppid,lwp,tty,start,s,psr,pcpu,args -C pup_event_frontend_d --no-headers | while read PPid Pid rest ; do
#PPids="$PPids
#$PPid"
Pids="$Pids
$Pid"
#if [ "`echo "$Pids" | grep -w "$PPid"`" ] ; then
#echo "$Pids" | grep -w "$PPid" && echo -e ": Current pid \n$Pid\n is child of above pid"
echo "$Pids" | grep $Q -w "$PPid" && echo "$Pid"
#fi
done

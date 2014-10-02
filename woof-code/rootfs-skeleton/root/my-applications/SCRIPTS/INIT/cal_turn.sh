


#   42  cal 11 2012 |tr -s ' '
#   43  cal 11 2012 |sed 's|   | - |g' |tr -s ' ' |sed 's|^ *||'
#   44  cal 11 2012 |sed 's|   | - |g' |tr -s ' ' |sed 's|^ *||' |for i in `seq 1 7`; do cat -f $i -d ' '; done
#   45  cal 11 2012 |sed 's|   | - |g' |tr -s ' ' |sed 's|^ *||' |for i in `seq 1 7`; do cut -f $i -d ' '; done
#   46  cal 11 2012 |sed 's|   | - |g' |tr -s ' ' |sed 's|^ *||' |for i in `seq 1 1 7`; do cut -f $i -d ' '; done
#   47  M=`cal 11 2012 |sed 's|   | - |g' |tr -s ' ' |sed 's|^ *||'`
#   48  echo "$M"
#   49  for i in `seq 1 7`;do echo "$M" |cut -f $i -d ' '|tr '\n' ' '; done
#   50  for i in `seq 1 7`;do echo "$M" |cut -f $i -d ' '|tr '\n' ' '; echo;done
#   51  M=`cal 11 2012 |sed '1d;s|   | - |g' |tr -s ' ' |sed 's|^ *||'`
#   52  for i in `seq 1 7`;do echo "$M" |cut -f $i -d ' '|tr '\n' ' '; echo;done
#   53  echo 'M=`cal 11 2012 |sed \'1d;s|   | - |g\' |tr -s \' \' |sed \'s|^ *||\'`" >/root/cal_turn.sh
#   54  echo 'M=`cal 11 2012 |sed \'1d;s|   | - |g\' |tr -s \' \' |sed \'s|^ *||\'`' >/root/cal_turn.sh
#   55  M=`cal 11 2012 |sed '1d;s|   | - |g' |tr -s ' ' |sed 's|^ *||'`






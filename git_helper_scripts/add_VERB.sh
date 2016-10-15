#!/bin/ash
# possible to source it while script is located in other directory
# 2016-10-15 will be deprecated. Should use alias cmd="cmd $VERB" block
# either in f4puppy5 or on top of scripts for that.

# coreutils
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%mkdir %mkdir \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%rmdir -%rmdir \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%ln -%ln \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%cp -%cp \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%mv %mv \$VERB %g' "$f" || break;done
# passwd
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%chown %chown \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%chmod %chmod \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%chgrp %chgrp \$VERB %g' "$f" || break;done
# chattr
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%chattr %chattr \${VERB:+"-V"} %g' "$f" || break;done
# df, ps
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%`df %`/bin/df %g' "$f" || break;done
   for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%`ps %`/bin/ps %g' "$f" || break;done

# modprobe
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%modprobe %modprobe \$Q \$VERB %g' "$f" || break;done

# repair doublettes
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% \$VERB \$VERB % \$VERB %g' "$f" || break;done

# mount busybox mount prints only something if -vv given
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%mount -%mount \${VERB:+"-vv"} -%g' "$f" || break;done

## ash instead sh
#for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%#! /bin/sh%#!/bin/sh%g' "$f" || break;done
#for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%#!/bin/sh%#!/bin/ash%g' "$f" || break;done
# ash instead sh
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%#! /bin/sh%#!/bin/sh%' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%#!/bin/sh%#!/bin/ash%' "$f" || break;done

#  $Q instead -q
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% -q % \$Q %g' "$f" || break;done
#  $QUIET instead --quiet
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% --quiet % \$QUIET %g' "$f" || break;done

# no echo -n
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%echo -n %echo %g' "$f" || break;done
#repair above
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%echo  %echo %g' "$f"   || break;done

# use ERR and OUT
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% 2> /dev/null% 2>>\$ERR%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% 2>/dev/null% 2>>\$ERR%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% > /dev/null% >>\$OUT%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% >/dev/null% >>\$OUT%g' "$f" || break;done
#repair inside backticks to use /dev/null
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% 2>>\$ERR`% 2>/dev/null`%g' "$f" || break;done

# remove space after >, >>
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% >> /% >>/%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% > /% >/%g' "$f" || break;done

# shorten tests
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] && % ] && %g' "$f" || break;done
#repair above
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] &&  != "" ] %  %g' "$f" || break;done
#repair above
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%   &&  % \&\& %g' "$f" || break;done

for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% = "" ] && % ] \|\| %g' "$f" || break;done

for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ];then% ]; then%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ]; then% ]; then%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] ; then% ]; then%g' "$f" || break;done




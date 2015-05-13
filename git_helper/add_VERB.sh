#!/bin/ash
# possible to source it while script is located in other directory

   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%mkdir %mkdir \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%ln -%ln \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%cp -%cp \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%rmdir -%rmdir \$VERB -%g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%mv %mv \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%chown %chown \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%chmod %chmod \$VERB %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%chgrp %chgrp \$VERB %g' "$f" || break;done

   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%`df %`/bin/df %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%`ps %`/bin/ps %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%#! /bin/sh%#!/bin/sh%g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%#!/bin/sh%#!/bin/ash%g' "$f" || break;done


for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%modprobe %modprobe \$VERB %g' "$f" || break;done

for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% \$VERB \$VERB % \$VERB %g' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%mount -%mount \$VERB \$VERB -%g' "$f" || break;done
# end verbose

# ash instead sh
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%#! /bin/sh%#!/bin/sh%' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%#!/bin/sh%#!/bin/ash%' "$f" || break;done

#  $Q instead -q
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% -q % \$Q %g' "$f" || break;done

# no echo -n
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%echo -n %echo %g' "$f" || break;done
   for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's%echo  %echo %g' "$f" || break;done

# use ERR and OUT
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% 2> /dev/null% 2>\$ERR%g' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% 2>/dev/null% 2>\$ERR%g' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% > /dev/null% >\$OUT%g' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% >/dev/null% >\$OUT%g' "$f" || break;done

for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% >> /% >>/%g' "$f" || break;done
for f in *; do test -L "$f" && continue;echo "$f"; sed -i 's% > /% >/%g' "$f" || break;done

# shorten tests
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] && % ] && %g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ];then% ]; then%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ]; then% ]; then%g' "$f" || break;done
for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] ; then% ]; then%g' "$f" || break;done




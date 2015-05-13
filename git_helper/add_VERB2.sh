#!/bin/ash

# repair sed && mistake
#for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] && % ] \&\& %g' "$f" || break;done

for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's% != "" ] &&  != "" ] %  %g' "$f" || break;done

for f in *; do test -L "$f" -o -d "$f" && continue;echo "$f"; sed -i 's%   &&  % \&\& %g' "$f" || break;done

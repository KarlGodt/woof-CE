#!/usr/bin/perl

#use strict;

use feature say; # since perl5.10

#print "draw 0 $0:$#ARGV:$ARGV[0]:$_:begin\n";
say "draw 0 $0:$#ARGV:$ARGV[0]:$_:begin";

#my MyNUMBER;

if ( $#ARGV != 0 ) {
    die "Usage: $0 <number>";
}

for (1 .. $ARGV[0]) {
        print "issue 1 1 use_skill pray \n";
}

print "draw 1 $0:$#ARGV:$ARGV[0]:$_:finished\n";

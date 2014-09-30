#!/usr/bin/perl

use File::stat;
if (  scalar( @ARGV ) == 0 ) {
 die("type  a file  name  ex:perl filestat.pl <filename>");
}
my $filename =  $ARGV[0] ;
my @info = stat($filename);
print "Change time :",scalar localtime stat($filename)->ctime;
print "\n";
print "Creation time :",scalar localtime stat($filename)->crtime;
print "\n";

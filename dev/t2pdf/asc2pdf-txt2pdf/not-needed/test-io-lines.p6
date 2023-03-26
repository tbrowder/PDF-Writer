#!/usr/bin/env perl6

my $ifile = "tlines.asc";
my $fh = open $ifile;
for $fh.lines.kv -> $i is copy, $line {
    ++$i;
    say "line $i = '$line'";
    last if $i > 9;
}



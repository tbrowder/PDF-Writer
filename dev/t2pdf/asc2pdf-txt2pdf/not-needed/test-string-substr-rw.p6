#!/usr/bin/env perl6

my $s = 'the quick fox';
my $nsc = $s.chars;

my $s2 = '[insert]';
my $nsc2 = $s2.chars;

say "String \$s '$s' has '$nsc' characters.";
say "String \$s2 '$s2' has '$nsc2' characters.";

say "Inserting \$s2 into \$s at position 3:";
$s.substr-rw(3, 0) = $s2;
$nsc = $s.chars;
say "String \$s '$s' now has '$nsc' characters.";

say "Appending \$s2 to \$s";
$s.substr-rw($nsc, 0) = $s2;
$nsc = $s.chars;
say "String \$s '$s' now has '$nsc' characters.";

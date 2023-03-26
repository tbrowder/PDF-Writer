#!/usr/bin/env perl6

use Font::AFM;

my $a = Font::AFM.new: :name<Helvetica>;
my $b = Font::AFM.new: :name<Courier>;

say $a.IsFixedPitch;
say $b.IsFixedPitch;

my $ab = $a.IsFixedPitch;
my $bb = $b.IsFixedPitch;

say "expect False for Helvetica:";
say $ab;
say "expect True for Courier:";
say $bb;




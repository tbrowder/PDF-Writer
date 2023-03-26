use v6;
use Test;

plan 2;

#my $prog = '../bin/txt2pdf';
my $prog = './txt2pdf';

lives-ok { $prog };

#my $args = '-p=14 -n';
my $args = '-n';
my $ifil = './t/data/some-ascii.txt';

my $cmd = "$prog $args $ifil";
lives-ok { run $cmd.words };

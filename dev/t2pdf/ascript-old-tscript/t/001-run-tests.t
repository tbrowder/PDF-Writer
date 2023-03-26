use Test;
use IO::Capture::Simple;
plan 2;

my $prog = './ascript';

lives-ok { capture_stdout { $prog } };

#my $args = '-p=14 -n';
my $args = '-n';
my $ifil = 't/data/some.txt';

lives-ok { capture_stdout { shell "$prog $args $ifil > /dev/null 2> /dev/null" } };

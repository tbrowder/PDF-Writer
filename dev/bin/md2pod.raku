#!/bin/env raku

use Markdown::Grammar:ver<0.4.0>;

use lib "./lib";
use Vars;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | md=X

    Converts one external or two internal Markdown files to Rakupod
    HERE
    exit
}

my $mdfil;

for @*ARGS {
    when /^ :i d / { ++$debug }
    when /^ :i md '=' (\S+) / {
        $mdfil = ~$0;
    }
}

if $mdfil.IO.r {
    my $text = slurp $mdfil;
    my $pod-fil = $mdfil;
    $pod-fil ~~ s/'.' md $/.pod/;
    $pod-fil ~~ s/^md/pod/;

    my $pod-str = from-markdown($text, to => 'pod6');
    my @pod-lines = $pod-str.lines;

    if $debug {
        say "line: |$_" for @pod-lines;
        say "DEBUG exit"; exit;
    }

    $pod-str = @pod-lines.join("\n");
    spurt $pod-fil, $pod-str;
    say "See output pod file: $pod-fil";
    exit;
}

# convert 2 md files to pod
for %md.keys -> $md {
    my $pod-fil = %md{$md}<pod>;
    my $pdf-fil = %md{$md}<pdf>;

    my $text = slurp $md;
    my $pod-str = from-markdown($text, to => 'pod6');
    my @pod-lines = $pod-str.lines;

    if $debug {
        say "line: |$_" for @pod-lines;
        say "DEBUG exit"; exit;
    }

    $pod-str = @pod-lines.join("\n");
    spurt $pod-fil, $pod-str;
    say "See output pod file: $pod-fil";
}

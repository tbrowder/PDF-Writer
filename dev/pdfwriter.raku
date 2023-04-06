#!/usr/bin/env raku

class Node {...}
class Node {
    has Node @.children;
    has Node $.parent;
    has Node $.siblings;
}

my $dfil = "test-pod/zef.pod";
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <Rakudoc> [...options...] [debug]

    Reads a Rakudoc file and converts it to
    word-processed PDF.

    Note the entire input file must be pure
    Rakudoc.

    With the 'go' mode the input file is:
        {$dfil}
    HERE
    exit
}

my $ifil;
my $debug = 0;
for @*ARGS {
    when /^:i g/ { 
        $ifil = $dfil;
    }
    when $_.IO.r {
        $ifil = $_;
    }
    when /^:i d/ { ++$debug }
    default {
        die "FATAL: Unknown arg '$_'";
    }
}

if not $ifil.defined {
    $ifil = $dfil;
}
die "FATAL: No input file entered." if not $ifil.IO.r;
say "Processing input file '$ifil'...";
say "  Debug is true." if $debug;

use Text::Utils :ALL;

my @nodes;
my @lines = $ifil.IO.lines;

my $typename;
my $in-block = 0:
for @lines -> $line is copy {
    if $line !~~ /\S/ {
        # a blank line: ends a block UNLESS in a =begin code block
    }
    elsif $line ~~ /^ \h* '=begin' \h+ (\S+) [\h+ (':' \N+)]? / {
        # a begin X line with possible config info
        if $in-block {
            # end block
        }
        # start new block
    }
    elsif $line ~~ /^ \h* '=for' \h+ (\S+) [\h+ (':' \N+)]? / {
        # a for X line with possible config info
        if $in-block {
            # end block
        }
        # start new block
    }
    elsif $line ~~ /^ \h+ (\N+) / {
        # a possible code line with indent OR a text line
    }
    elsif $line ~~ /^ (\N+) / {
        # a text line
    }
    else {
        die "FATAL: unknown type of line: |$line|";
    }
}


=finish

use PDF::Content:ver<0.4.9+>;
use PDF::Lite;
use Font::AFM;

my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
my $fnam = "Courier";
my $font = get-font $pdf, $fnam;
#$font = Font::AFM.new: :name<Helvetica>;

for 0..3 -> $i {
    # put some text on the page
    $page.text: {
        .font = $font, 12;
        .say("howdy");
    }

    last if $i == 3;
    # get a new page
    $page = $pdf.add-page;
}

# save the doc and quit
my $ofil = 'sample.pdf';
$pdf.save-as: $ofil;
say "Normal end. See new file '$ofil'.";

sub get-font($pdf, $name, :$weight, :$style) {
    my @f = <
        Courier
    >;

    my %f;
    given $name {
        when /Courier/ {
            $pdf.core-font(:family<Courier>);
        }
        default {
            $pdf.core-font(:family<Courier>);
        }
    }
}




=finish

my $ifil = "page-13-of-16-mods.pdf";
my $ofil = "page-13-of-16-mods-2.pdf";

# Open an existing PDF file
$pdf .= open($ifil);

# Add a blank page
#my $page = $pdf.add-page();

# Retrieve an existing page
my $page = $pdf.page(1);

# Set the default page size for all pages
$pdf.media-box = Letter;

# Use a standard PDF core font
#my CoreFont $font = $pdf.core-font('Helvetica-Bold');
my $font = $pdf.core-font: :family<Helvetica>; #, :weight<Bold>;

# Add some text to the page
$page.text: {
    .font = $font, 9;
    .text-position = 40, 645;
    .say('100 sh XYZ');
}

# Save the new PDF
$pdf.save-as($ofil);
say "See file '$ofil'";

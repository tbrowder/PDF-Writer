#!/bin/env raku

use Pod::To::PDF::Lite:ver<0.1.6>;
use PDF::Lite;
use PDF::Font::Loader;
use RakupodObject;

use lib "./lib";
use Vars;

# Source Code Pro (Google font) # font used by Tony-o for cro article
my @fonts = (
    %(:file<SourceCodePro/static/SourceCodePro-Regular.ttf>),
    %(:file<SourceCodePro/static/SourceCodePro-Bold.ttf>, :bold),
    %(:file<SourceCodePro/static/SourceCodePro-Italic.ttf>, :italic),
    %(:file<SourceCodePro/static/SourceCodePro-BoldItalic.ttf>, :bold, :italic),
);

my enum Paper <Letter A4>;
my $debug   = 0;
my $left    = 1 * 72; # inches => PS points
my $right   = 1 * 72; # inches => PS points
my $top     = 1 * 72; # inches => PS points
my $bottom  = 1 * 72; # inches => PS points
my $margin  = 1 * 72; # inches => PS points
my Paper $paper = Letter;
my $page-numbers = False;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | pod=X [...options...]

    Options
      paper=X    - Paper name: A4, Letter [default: Letter]
      margin=X   - default: 1"
      numbers    - Produces page numbers on each page
                   (bottom right of page: 'Page N of M')

    Converts Rakupod to PDF
    HERE
    exit
}

# defaults for US Letter paper
my $height = 11.0 * 72;
my $width  =  8.5 * 72;
# for A4
# $height =; # 11.7 in
# $width = ; #  8.3 in

my $podfil;

for @*ARGS {
    when /^ :i n[umbers]? / {
        $page-numbers = True;
    }
    when /^ :i p[aper]? '=' (\S+) / {
        $paper = ~$0;
        if $paper ~~ /^ :i a4 $/ {
            $height = 11.7 * 72;
            $width  =  8.3 * 72;
        }
        elsif $paper ~~ /^ :i L / {
            $height = 11.0 * 72;
            $width  =  8.5 * 72;
        }
        else {
            die "FATAL: Unknown paper type '$paper'";
        }
    }
    when /^ :i l[eft]? '=' (\S+) / {
        $left = +$0 * 72;
    }
    when /^ :i r[ight] '=' (\S+) / {
        $right = +$0 * 72;
    }
    when /^ :i t[op]? '=' (\S+) / {
        $right = +$0 * 72;
    }
    when /^ :i b[ottom]? '=' (\S+) / {
        $bottom = +$0 * 72;
    }
    when /^ :i m[argin]? '=' (\S+) / {
        $margin = +$0 * 72;
    }
    when /^ :i d / { ++$debug }
    when /^ :i pod '=' (\S+) / {
         $podfil = ~$0.IO;
    }
}

die "FATAL: '$podfil' is not a valid file" if not $podfil.IO.r;

# title of output pdf
my $new-doc   = "An-Apache-Cro-Web-Server.pdf";
# title on cover
my $new-title = "An Apache/CRO Web Server";

if $podfil.IO.r {
    my $pdffil = $podfil;
    $pdffil ~~ s/'.pod' $/.pdf/;
    $pdffil ~~ s/^'pod-src'/pdf-docs/;

    # Extract the pod object from the pod
    if $debug {
        note "DEBUG pod file: '$podfil'"; exit;
    }

    my $pod-obj = extract-rakupod-object $podfil.IO;

    if $debug {
        say $pod-obj.raku;
        say "DEBUG exit"; exit;
    }

    # Then convert the pod object to pdf
    my PDF::Lite $pdf = pod2pdf $pod-obj,
        :$height, :$width, :$margin, :$page-numbers; #, :@fonts;

    my $pdf-tmp = "pdf-tmp.pdf";
    $pdf.save-as: $pdf-tmp.pdf;

    # final file name: $pdffil;

    # add a cover page
    # do we need to specify 'media-box'?
    $pdf = PDF::Lite.new;
    $pdf.media-box = 'Letter';
    my $centerx    = 4.25*72;

    # manipulate the PDF some more
    my $tot-pages = 0;
    # add a cover for the collection
    my PDF::Lite::Page $page = $pdf.add-page;
    my $font  = $pdf.core-font(:family<Times-RomanBold>);
    my $font2 = $pdf.core-font(:family<Times-Roman>);
    # make this a sub: sub make-cover-page(PDF::Lite::Page $page, |c) is export

    $page.text: -> $txt {
        my ($text, $baseline);
        $baseline = 7*72;
        $txt.font = $font, 16;
        $text = $new-title;
        $txt.text-position = 0, $baseline; # baseline height is determined here
        # output aligned text
        $txt.say: $text, :align<center>, :position[$centerx];
        $txt.font = $font2, 14;
        $baseline -= 60;
        $txt.text-position = 0, $baseline; # baseline height is determined here
        $txt.say: "by", :align<center>, :position[$centerx];
        $baseline -= 30;
        my @text = "Tony O'Dell", "2022-09-23", "[https://deathbykeystroke.com]";
        for @text -> $text {
            $baseline -= 20;
            $txt.text-position = 0, $baseline; # baseline height is determined here
            $txt.say: $text, :align<center>, :position[$centerx];
        }

        # add the original doc's pages to the new, combined doc
        my $pdf-obj = PDF::Lite.open: $pdf-tmp;

        my $pc = $pdf-obj.page-count;
        say "Input doc $pdf-tmp: $pc pages";
        $tot-pages += $pc;
        for 1..$pc -> $page-num {
            $pdf.add-page: $pdf-obj.page($page-num);
        }
    }

    $pdf.save-as: $pdffil;
    unlink $pdf-tmp unless $debug;

    say "See output pdf file: $pdffil";
    exit;
}

for %md.keys -> $md {
    my $pod-fil = %md{$md}<pod>.IO; #= Note the '.IO' is needed here
    my $pdf-fil = %md{$md}<pdf>;

    # Extract the pod object from the pod
    my $pod-obj = extract-rakupod-object $pod-fil;

    if $debug {
        say $pod-obj.raku;
        say "DEBUG exit"; exit;
    }

    # Then convert the pod object to pdf
    my PDF::Lite $pdf = pod2pdf $pod-obj,
        :$height, :$width, :$margin, :$page-numbers; #, :@fonts;

    $pdf.save-as: $pdf-fil;
    say "See output pdf file: $pdf-fil";
}

unit module PDF::Writer:ver<0.0.6>:auth<cpan:TBROWDER>;

use PDF:ver<0.4.5+>;
use PDF::Lite;

#enum Font is export <Courier Times Helvetica>;
enum Weight is export <Bold>;
enum Style is export <Regular Italic Slant>;

class Doc is export {
    # doc attrs that depend upon PDF::API6
    has $.Page is rw;
    has $.Pdf  is rw;
    has $.Font is rw;
    has Real $.Size is rw;

    has $.ofil is rw;

    # all attrs below here may be defined in the TOML file
    # doc attrs with defaults:
    has $.font  is rw = "Courier";
    has Real $.size  is rw = 9.5;
    has $.paper is rw = 'Letter';
    has $.title is rw = 1;

    # margins
    has $.left   is rw = 72; # PS points (1 inch)
    has $.right  is rw = 72; # PS points (1 inch)
    has $.top    is rw = 72; # PS points (1 inch)
    has $.bottom is rw = 72; # PS points (1 inch)

    # the following doc attrs have false defaults (i.e., not defined):
    has $.height        is rw;
    has $.width         is rw;

    has $.number        is rw;
    has $.underline     is rw;
    has $.style         is rw;
    has $.weight        is rw;
    has $.truncate      is rw;
    has $.wrap          is rw;
    # some defaults
    has $.leading       is rw = 9.5 * 1.25; # space between baselines
    has $.leading-ratio is rw = 1.25;       # used as font size times ratio equals leading distance

    # want some special methods
    method set-leading() {
        $!leading = $!size * $!leading-ratio;
    }
    multi method set-size($val, :$leading-ratio) {
        $!size          = $val;
        $!leading-ratio = $leading-ratio;
        $!leading       = $!size * $!leading-ratio;
    }
    multi method set-size($val, :$leading) {
        $!size          = $val;
        $!leading       = $leading;
        $!leading-ratio = $!leading / $!size;
    }

    method get-font($name, :$weight, :$style) {
        # Given a valid core-font name, and optional weight and style,
        # return the PDF font object for it.
        my $w = $weight;
        my $s = $style;
        given $name {
            when $name eq 'Courier' {
                when $weight eq '' {
                }
            }
            when $name eq 'Helvetica' {
            }
            when $name eq 'Times' {
            }
            default {
                die "FATAL: Unknown font name '$name'.";
            }
        }
    }

}

sub text2pdf(@lines, :$doc, :$debug,
            ) is export {
    # line-by-line (the original method

    # for now we just need a conversion to pdf
    # determine how many pages:
    my $lines-per-page = (($doc.height - ($doc.top - $doc.bottom)) / $doc.leading).floor;
    my $npages = (@lines.elems / $lines-per-page).ceiling;

=begin comment
    $page.text: {
        .font = $font, 12;
        .say("howdy");
    }
=end comment

    # Add a blank page to start
    my $page = $doc.Pdf.add-page();
    my $font = $page.core-font(:family<Courier>);
    #my $font = $doc.Pdf.core-font(:family<Helvetica>, :weight<Bold>, :Style<Italic>);
    my $size = $doc.size;

    my $x  = $doc.left;
    my $y0 = $doc.height - $doc.top - $doc.leading;
    my $y  = $y0;
    my $pnum      = 1; # for page numbering and control
    my $pnumbered = 0; # for page numbering and control
    for @lines -> $line {
        # add the line's text to the page
        $page.text: {
            .font = $font, $doc.size;
            .text-position = $x, $y;
            .say($line);
        }
        if $doc.underline {
            my $xx = $doc.width - $doc.right;
            $page.graphics: {
                # automatically protects with a Save/Restore
                # need thinnest line from $x to $width-$right
                .LineWidth = 0; # thin as possible
                .MoveTo($x, $y-1);
                .LineTo($xx, $y-1);
                .Stroke;
            }
        }

        $y -= $doc.leading;
        if $y <= $doc.bottom {
            note "DEBUG: numbering page $pnum of $npages" if $debug;
            # add a page number
            ++$pnumbered;
            my $pp;
            if $doc.title {
                $pp = "Page $pnum of $npages ({$doc.title})";
            }
            else {
                $pp = "Page $pnum of $npages";
            }
            my $yy = 36; # 1/2 inches from the bottom
            $page.text: {
                .font = $font, $doc.size;
                .text-position = $x, $yy;
                .say($pp);
            }

            # start a new page
            $page = $doc.Pdf.add-page();
            ++$pnum;
            # reset y
            $y  = $y0;
        }
    }
    # make sure the last page is numbered

    note "DEBUG: finished page $pnum of $npages" if $debug;
    note "DEBUG: actually numbered $pnumbered pages" if $debug and $pnumbered != $npages;
    if $pnum <= $npages and $pnumbered != $npages {
        # add a page number
        ++$pnumbered;
        my $pp;
        if $doc.title {
            $pp = "Page $pnum of $npages ({$doc.title})";
        }
        else {
            $pp = "Page $pnum of $npages";
        }
        my $yy = 36; # 1/2 inches from the bottom
        $page.text: {
            .font = $font, $doc.size;
            .text-position = $x, $yy;
            .say($pp);
        }
    }
    note "DEBUG: have now numbered $pnumbered pages" if $debug and $pnumbered == $npages;

} # make-text-by-lines

unit module ASsubs;

use ASvars;
use ASclasses;

sub write-pdf($psf, $pdf) is export {
    my $cmd = "ps2pdf $psf $pdf";
    run $cmd.words;
    # delete the ps file if all went well
    if !$save-ps && $pdf.IO.f {
	unlink $psf;
    }
}

sub wrap-line($line is copy,
              $max-length    # inches
              --> List) is export {
    # this function will return a list of the wrapped lines
    # the actual length depends on the fixed-font size
    # since this function only works for source input, not
    # word processing

    # note: see Damian Conway's August 2019 entry at blog.perl.org
    # for the ultimate word on word-wrapping!

}

sub show-font-names() is export {
    print q:to/HERE/;
    tscript font names:

      Proportional:
      ------------
      Times-Roman
      Times-Bold
      Times-Italic
      Times-BoldItalic
      Helvetica
      Helvetica-Bold
      Helvetica-Oblique
      Helvetica-BoldOblique

      Fixed-pitch (monospace):
      -----------------------
      Courier       [default]
      Courier-Bold
      Courier-Oblique
      Courier-BoldOblique
    HERE
    exit 0;
}

sub set-vars-after-input(Portrait $portrait,
                         Landscape $landscape,
                         PSDoc $doc
                        ) is export {
    $outfile-ps = $outfile-pdf;
    $outfile-ps ~~ s:i/\.pdf$/\.ps/;

    # get system date
    $date-string   = Date.today;
    $portrait.xll  = $left-margin    * $IN2PT;
    $portrait.yll  = $bottom-margin  * $IN2PT;
    $portrait.xur  =  8.5 * $IN2PT - $right-margin * $IN2PT;
    $portrait.yur  = 11.0 * $IN2PT - $top-margin * $IN2PT;

    $landscape.xll = $left-margin    * $IN2PT;
    $landscape.yll = $bottom-margin  * $IN2PT;
    $landscape.xur = 11.0 * $IN2PT - $right-margin * $IN2PT;
    $landscape.yur =  8.5 * $IN2PT - $top-margin * $IN2PT;

    $font-name = $default-font-name if !$font-name;
    $font-size = $default-font-size if !$font-size;

    if !$doc.landscape {
	$page-top  = 11.0 * $IN2PT;
	$page-left = $portrait.xll;
    }
    else {
	$page-top  = 8.5 * $IN2PT;
	$page-left = $landscape.xll;
    }
}

sub prep-line($line is copy, $linenum --> Str) is export {
    # do some initial line handling on the input line
    #   check for back-slashes
    #   change tabs to spaces
    #   protect parens for PostScript

    # slashes
    my $has-slashes = index $line, '\\';
    if $has-slashes {
        say "WARNING: Input line $linenum has back-slashes, results may be unexpected.";
    }

    # tabs
    my $has-tabs = index $line, '\t';
    if $has-tabs {
        say "DEBUG: Input line $linenum has tabs." if $debug;
        my $spaces = ' ' x $tabspaces;
        $line ~~ s:g/\\t/$spaces/;
    }

    #=begin comment
    # parens '(' and ')'
    $line ~~ s:g/\(/\\\(/;
    $line ~~ s:g/\)/\\\)/;
    #=end comment

    $line .= trim-trailing;
    return $line;
}

sub end-ps-page($fh, PSDoc $d) is export {
    $fh.say: "showpage";
    $fh.say: "restore";
    $fh.say: "%%ENDPAGE";
}

sub show-page-header($fh, PSDoc $d, $hostname) is export {
    $fh.say: "gsave";
    $fh.printf: "/%s findfont\n", "Courier-Bold";
    $fh.printf: "%d scalefont setfont\n", 7;
    $fh.printf: "%.4f %.4f moveto\n", $page-left, $page-top - 0.4 * $IN2PT;

    $fh.printf: "(File: %s:%s      Page: %d) show\n", $hostname, $outfile-ps, $d.page-num;

    $fh.printf: "%.4f %.4f moveto\n", $page-left, $page-top - 0.4 * $IN2PT - 7.0;
    $fh.printf: "(Date: %s) show\n", $date-string;
    $fh.say: "grestore";
}

sub start-ps-page($fh, PSDoc $d) is export {
    ++$d.page-num;
    $fh.say: "%%PAGE: {$d.page-num} {$d.page-num}";
    $fh.say: 'save';
}


sub start-ps-doc($fh, PSDoc $d) is export {
    # prologue, if any, and outer save
    $fh.say: q:to/HERE/;
    %%!PS-Adobe-3.0
    %%Pages: (atend)
    %%PageOrder: Ascend
    save
    HERE
}

sub end-ps-doc($fh, PSDoc $d) is export {
    # total number of pages should be $d.page-num
    $fh.say: "restore";
    $fh.say: "%%Trailer";
    $fh.say: "%%Pages: {$d.page-num}";
    $fh.say: "%%EOF";
}

sub read-code-for-pdf(
    $f, 
    :$number-lines, 
    :$line-wrap, 
    :$font-size = 9,
    :$left-margin   = 1.0, # inches
    :$right-margin  = 1.0, # inches
    :$top-margin    = 1.0, # inches
    :$bottom-margin = 1.0, # inches
    :$line-spacing  = 1.3, # multiple of font size
    :$debug, 
    ) {

    # reading code for Courier font and using David Warring's Raku PDF modules
    for $f.IO.lines -> $line is copy {
        $line .= trim-right;
        my $nc = $line.chars;
        # TODO from PS experience, spaces are slightly narrower than stroked letters 
        #      even with Courier font, so I may have to adjust for that if PDF
        #      modules show the same effect

    }
} # sub read-code-for-pdf


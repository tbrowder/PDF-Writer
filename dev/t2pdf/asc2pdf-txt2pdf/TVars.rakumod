unit module TVars;

my package EXPORT::DEFAULT {
# defaults:
our constant $default-font-name = "Courier";
our constant $default-font-size = 10.0;
our constant $default-margins = 1.0;
our constant $I2P       = 72.0;
our constant $IN2PT     = 72.0;
our constant $FF        = "<FF>";
our constant $FF2       = "<ff>";
our constant $TABS      = 8;
our constant $SPACE     = ' ';

# initialize global vars
# candidates for PSDoc:

# candidates for PSPage:
our $form-feed = False;
our $hpos;
our $vpos;
our $xll;
our $xur;
our $yll;
our $yur;
our $linenum = 0;

# flags:
our $header-flag = True;
our $page-flag = False;
our $line-number-flag = False;
our $line-wrap = True;
our $mono-flag = True;

our $max-line-length;
our $hsize;
our $afm;
our $bottom-margin = $default-margins;
our $char-width;
our $chars-per-line;
our $date-string;
our $debug = False;
our $font-name  = 0;
our $font-size  = 0;

our $infile;
our $left-margin = $default-margins;
our $line-number = 0;
our $num-lines-wrapped = 0;
our $outfile-pdf;
our $outfile-ps;
our $page-left;
our $page-top;
our $right-margin = $default-margins;
our $save-ps      = False;
our $tabspaces = $TABS;
our $tmpbuf-start = 0;
our $top-margin = $default-margins;
our $vsize;
our $word-process = False;
}


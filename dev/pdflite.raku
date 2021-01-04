#!/usr/bin/env raku

use PDF::Lite;

my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
my $fnam = "Courier";
my $font = $pdf.core-font($fnam);

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

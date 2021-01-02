use Test;
use PDF::Writer;

plan 1;


lives-ok {
    shell "./bin/pdfwriter examples/80col.txt";
}

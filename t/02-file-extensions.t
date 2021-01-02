use Test;
use PDF::Writer;

plan 1;

dies-ok {
    shell "./bin/pdfwriter examples/dummy.pdf 2>/dev/null";
}

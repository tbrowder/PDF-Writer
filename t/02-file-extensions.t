use Test;
use PDF::Writer;

plan 1;

dies-ok {
    shell "raku -Ilib ./bin/pdfwriter examples/dummy.pdf 2>/dev/null";
}

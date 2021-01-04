use Test;
use PDF::Writer;

plan 1;

lives-ok {
    shell "raku -Ilib ./bin/pdfwriter size=20 examples/80col.txt";
}

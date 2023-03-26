unit module TClasses;

class PSObject is export {
    has $.xll is rw = 0;
    has $.yll is rw = 0;
    has $.xur is rw = 0;
    has $.yur is rw = 0;

    has $!font-name = 'Courier';
    has $!font-size = 10;
}

class PSDoc is PSObject is export {
    has $.landscape is rw = False;
    has $.page-num  is rw = 0;
}

class PSPage is PSObject is export {
    has PSDoc $!d;
    has $.hpos is rw = 0;
    has $.vpos is rw = 0;

    method reset() {
        $.hpos = $!d.xll;
        $.vpos = $!d.yur;
    }
    
}

=begin comment
class line-t is export {
  has line-t $.prev is rw;
  has line-t $.next is rw;
  has $line;
}
=end comment

class Portrait is export {
    has $.xll is rw;
    has $.yll is rw;
    has $.xur is rw;
    has $.yur is rw;
}

class Landscape is export {
    has $.xll is rw;
    has $.yll is rw;
    has $.xur is rw;
    has $.yur is rw;
}

class Tmpbuf is export {
    has Str $.buf is rw = '';

    method insert(Str:D $s, UInt $pos) {
        # insert string $s at $pos of $.buf
    }
    method append(Str:D $s, UInt $pos) {
        # append string $s  to $.buf
        $.buf ~= $s;
    }
    method replace(Str:D $s, UInt $pos) {
        # replace $s.chars of $.buf at $pos with $s
    }
    method chars() {
        # return length of $.buf
        return $.buf.chars;
    }

    =begin comment
    # wanted a setter, use instead "$tbuf.buf = 'some string'";
    method equate(Str:D $s) {
        # replace contents of $.buf with $s
        $.buf = $s;
    }
    =end comment
}


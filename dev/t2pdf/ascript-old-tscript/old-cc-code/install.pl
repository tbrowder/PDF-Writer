#!/usr/bin/perl
require 5.003;

# prcs keyword update:
# $Format: "\$version = \"$ProjectVersion$\";"$ 
$version = "2.1";

# prcs keyword update:
# $Format: "\@datetxt = qw($ProjectDate$);"$ 
@datetxt = qw(Mon, 12 May 1997 12:10:05 +0000);

# strip out desired info (day, month, year only)
$date = sprintf("%s %s %s", @datetext[1..3]);

$LIBDIR = "/usr/asi/lib";
$INCDIR = "/usr/asi/include";

# create version-specific files
@LIBFILES = qw(
libtbrowde.a
);

@INCFILES = qw(
tbrowde.h
feltmatrix.h
listclass.h
PStypes.h
);

foreach $TFILE (@LIBFILES)
{
    $FILE = sprintf("%s.%s", $TFILE, $version);
    `cp $TFILE $LIBDIR/$FILE`;
    `ln -sf $LIBDIR/$FILE $LIBDIR/$TFILE`;
}

foreach $TFILE (@INCFILES)
{
    $FILE = sprintf("%s.%s", $TFILE, $version);
    `cp $TFILE $INCDIR/$FILE`;
    `ln -sf $INCDIR/$FILE $INCDIR/$TFILE`;
}

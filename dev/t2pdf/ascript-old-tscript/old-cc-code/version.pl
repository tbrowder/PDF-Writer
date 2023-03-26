#!/usr/bin/perl
require 5.003;

$code = "tl";

# prcs keyword update:
# $Format: "\$version = \"$ProjectVersion$\";"$ 
$version = "2.1";

# prcs keyword update:
# $Format: "\@datetxt = qw($ProjectDate$);"$ 
@datetxt = qw(Mon, 12 May 1997 12:10:05 +0000);

# strip out desired info (day, month, year only)
$date = sprintf("%s %s %s", @datetxt[1..3]);

# create version.cc
$file = "version.cc";
if ( -e $file ) 
{ 
    printf("Removing old version of $file\n");
    `rm $file`; 
}
`echo 'char *brltoolversion = "$version";' >> version.cc`;
`echo 'char *releasedate = "$date";' >> version.cc`;

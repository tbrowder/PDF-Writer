#!/usr/bin/perl -w

# splits a large source file into library files--one per function

require 5.004;

$basename = "LTB_";
$lname = "newfiles.list";

open(FP2, ">$lname"); # file of file names

$h1 = "\n/* produced automatically by 'splitit.pl' */\n\n";
$h2 = "/* Author: Thomas M. Browder, Jr.           */\n";
$h3 = "/*         ASI Systems International        */\n";
$h4 = "/*         12 august 1997                   */\n\n";
$h5 = "#include <tbrowde.h>\n\n";

$num = 0;
# loop through all lines, 
while(defined($_ = <STDIN>))
{
    # if we find a keyword starting a function, 
    #  assign to a file name, open file,
    #  add headers, etc.
    # else if we find keyword ending a function, close file;
    # otherwise next
    if ((index $_,"STARTFUNCTION") >= 0)
    {
	$oname = sprintf("%s_%04d.cc", $basename, $num++);

	printf(FP2 "%s\n", $oname);

 	open(FP, ">$oname"); # output file
	#headers
	printf(FP "%s", $h1);
	printf(FP "%s", $h2);
	printf(FP "%s", $h3);
	printf(FP "%s", $h4);
	printf(FP "%s", $h5);

	while(defined($_ = <STDIN>) && (index $_,"ENDFUNCTION") < 0)
	{
	    printf(FP "%s", $_);
	}
	close(FP);
    }
}
printf("Library functions processed: %d\n", $num);

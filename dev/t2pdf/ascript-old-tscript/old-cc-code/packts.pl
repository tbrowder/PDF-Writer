#!/usr/bin/perl -w

# packs tscript for transfer

require 5.003;

$tmpdir = "./tmp";

if ( -d $tmpdir ) 
{ 
    @files =  glob("${tmpdir}/*");
    foreach (@files)
    { 
	if ( $_ ne "." && $_ ne "..") { qx(rm $_); }
    }
   qx(chmod 777 $tmpdir);
   qx(rm -rf $tmpdir);
}
qx(mkdir $tmpdir);

@files = glob( "* .*" );

foreach (@files)
{ if ( ! -d $_ ) 
  { 
#    printf("file: %s\n", $_);
    qx(  cp -fp $_ ${tmpdir} ); 
  }
}
#exit;



if (!chdir($tmpdir)) {  printf("No chdir...exiting\n"); exit; }
else { printf("In directory $tmpdir\n"); }

# trash files for transfer of tscript
@files = glob("t test TAR btest*  t1 t2 core *.a *.o *.d *~ *.flc DRIVER.out TAR.ORIG comb* fonts.orig ld_info bridgetest.c *.tgz");
foreach (@files)
{ qx(  rm -f $_ ); }

qx( tar -czvf tscript.tgz *);

#!/usr/bin/env perl6

use strict;
use warnings;
use lib(
	'./web-sites',
	'./rtf-modules',
       );
use Data::Dumper;
use Carp;

# for GEO info (google not working)
use Geo::Ellipsoid;

# other data and functions
use GEO_DATA_TBS; # auto-generated
use CLASSMATES_FUNCS qw(:all);

use GENFUNCS;
use Member;
use KIA;

# for rtf
#use Biblio;
use MyRTF;
#use GenFuncs qw(:all);

my @wkeys = qw(tbs);
my %wkeys;
@wkeys{@wkeys} = ();

if (!@ARGV) {
  print <<"HERE";
Usage: $0 <key name> map | geo | mem | reunion | admin

Makes a map page (or member list) from appropriate contact data
where <key name> is one of:

HERE

  print "  $_\n" for @wkeys;

  print <<"HERE2";

modes

    geo - write a geocode file for use with Google maps for finding lat/long

    map - use geocode data to produce a map of member locations

    mem - write a new member text source file (without deceased)

    admin - write a member file with deceased and KIA at the end

    reunion - write a member rtf file for reunion attendees

HERE2

  exit;
}

my $map     = 0;
my $geo     = 0;
my $mem     = 0;
my $admin   = 0;
my $reunion = 0;

my $wkey     = '';
my $map_page = '';
my $pdir     = '';

sub zero_modes {
  $map     = 0;
  $geo     = 0;
  $mem     = 0;
  $admin   = 0;
  $reunion = 0;
}

foreach my $arg (@ARGV) {
  if ($arg eq 'tbs') {
    die "FATAL:  Attempting to use multiple web site keys: '$wkey' and '$arg'.\n"
      if ($wkey);
    my $domain = 'novco1968tbs.com';
    $wkey      = 'tbs';
    $pdir      = './web-sites/${domain}/public';
    $map_page  = "${pdir}/map-all.html";
  }
  elsif ($arg eq 'map') {
    zero_modes();
    $map = 1;
  }
  elsif ($arg eq 'geo') {
    zero_modes();
    $geo = 1;
  }
  elsif ($arg eq 'mem') {
    zero_modes();
    $mem = 1;
  }
  elsif ($arg eq 'admin') {
    zero_modes();
    $mem   = 1;
    $admin = 1;
  }
  elsif ($arg =~ /^re/) {
    zero_modes();
    $reunion = 1;
  }
  else {
    die "FATAL:  Unknown arg '$arg'.\n";
  }
}

die "FATAL:  No web site key entered.\n"
  if !$wkey;

die "FATAL:  Unknown web site key '$wkey'.\n"
  if (! exists $wkeys{$wkey});

die "FATAL:  Need to choose one mode of: 'map', 'geo', 'mem', or 'reunion'.\n"
  if (!$map && !$geo && !$mem && !$reunion);

my @ofils = ();

if ($wkey eq 'tbs') {
  my $dir = 'web-sites/novco1968tbs.com/public';
  my $ifil = "$dir/brothers.source";

  open my $fp, '<', $ifil
    or die "$ifil: $!";

  # get the current members data
  my %members = ();
  my $m = 0;
  while (defined(my $line = <$fp>)) {
    chomp $line;
    my ($ltyp, $key, $text) = GENFUNCS::get_line_type_member($line);
    my @toks = split ' ', $text;

    if ($key eq 'name') {
      # starting a new member object
      # new object
      # $text = name
      my $name = $text;

      my ($last, $first, $middle, $suff) = GENFUNCS::split_name($name);
      $m = Member->new();
      $m->name($name);
      $m->lastname($last);
      $m->firstname($first);
      $m->middlename($middle);
      $m->suffix($suff);

      # we need a key for file names and hashes
      $m->create_name_key();
      my $nk = $m->name_key();
      die "FATAL:  Duplicate name key '$nk'"
	if exists $members{$nk};
      $members{$nk} = $m;
    }
    elsif ($key eq 'pic') {
      ; # ignore
    }
    elsif ($key) {
      # now handle the key/value pair
      no strict 'refs';
      $m-> $key ($text);
    }
  }

  #print Dumper(\%members); die "debug exit";

  if ($map) {
    # generate the appropriate map page
    print_member_map('tbs', \@ofils, \%members);
  }
  elsif ($geo) {
    # print geo data
    print_geo_data2('tbs', \@ofils, \%members);
  }
  elsif ($mem || $admin) {
    # print member data
    print_member_data('tbs', \@ofils, \%members, $admin);
  }
  elsif ($reunion) {
    # print member data
    print_member_data_rtf({
			   key          => 'tbs',
			   ofils_aref   => \@ofils,
			   members_href => \%members,
			   reunion      => 1,
			  });
  }
}

print "Normal end.\n";
if (@ofils) {
  my $s = @ofils > 1 ? 's' : '';
  print "See file$s:\n";
  print "  $_\n" for @ofils;
}
else {
  print "No files generated.\n";
}

##### subroutines #####
sub print_member_map {
  # prints an output file of Google map data for member locations
  my $key          = shift @_; # 'tbs'
  my $ofils_aref   = shift @_; # an array ref for generated files
  my $members_href = shift @_; # a hash ref of member objects

  my $dir          = '';
  my $geodata_href = '';
  if ($key eq 'tbs') {
    $dir          = 'web-sites/novco1968tbs.com/public';
    $geodata_href =  \%GEO_DATA_TBS::geodata;
  }

  my $ofil = "${dir}/map-all.html";
  open my $fp, '>', $ofil
    or die "$ofil: $!";

  push @{$ofils_aref}, $ofil;

  my @names = (keys %{$members_href});

  my $p = MapParams->new();
  # set values
  $p->ctr_lat($GEO_DATA_TBS::ctr_lat);
  $p->ctr_lng($GEO_DATA_TBS::ctr_lng);
  $p->min_lat($GEO_DATA_TBS::min_lat);
  $p->min_lng($GEO_DATA_TBS::min_lng);
  $p->max_lat($GEO_DATA_TBS::max_lat);
  $p->max_lng($GEO_DATA_TBS::max_lng);

  # normal entry function
  # CLASSMATES_FUNCS::print_map_data
  print_map_header_tbs($fp, 'tbs', $p);

  # get geo ellipsoid data
  use Geo::Ellipsoid;
  my $geoid = Geo::Ellipsoid->new(
				  ellipsoid      =>'WGS84', #the default ('NAD27' used in example),
				  units          =>'degrees',
				  distance_units => 'mile',
				  longitude      => 1, # +/- pi radians
				  bearing        => 0, # 0-360 degrees
				 );
  # establish a random seed
  srand(1);

  # write array of markers
  print_map_markers_tbs($fp
			, $geoid
			, $members_href
			, $geodata_href
		       );

  print_close_function_initialize($fp);

  print_map_end($fp);
  close $fp;
  # finished with html file

} # print_member_map

=pod

sub print_map_data_tbs {
  my $href = shift @_;

  # error check
  my $reftyp = ref $href;
  if ($reftyp ne 'HASH') {
    confess "ERROR: \$href is not a HASH reference!  It's a '$reftyp'.";
  }

  my $typ            = $href->{type};      # '$HSHS1961' or '$USAFA1965'
  my $ofils_aref     = $href->{ofilsref};  # an array ref of all output files
  my $cmates_aref    = $href->{cmatesref}; # an array ref of all classmates
  my $cmate_href     = $href->{cmateref};  # a hash ref of all classmates
  my $geodata_href   = $href->{georef};    # a hash ref of all classmates' geo data

  my $mparams        = $href->{mparams}; # center and bounds

  if ($typ eq $CLASSMATES_FUNCS::TBS) {
    ; # ok
  }
  else {
    die "ERROR: Unknown collection type '$typ'!";
  }

  my $mapfil = 'web-site/classmates-map.html';

  push @{$ofils_aref}, $mapfil;

  my $fp;

  # now write the html file
  open $fp, '>', $mapfil
    or die "$mapfil: $!";

  print_map_header($fp, $typ, $mparams, undef, undef);

  # get geo ellipsoid data
  use Geo::Ellipsoid;
  my $geo = Geo::Ellipsoid->new(
				ellipsoid      =>'WGS84', #the default ('NAD27' used in example),
				units          =>'degrees',
				distance_units => 'mile',
				longitude      => 1, # +/- pi radians
				bearing        => 0, # 0-360 degrees
			       );
  # establish a random seed
  srand(1);

  # write array of markers
  print_map_markers_tbs($fp
			, $geo

			, $cmates_aref
			, $cmate_href

			, $geodata_href
		       );

  print_close_function_initialize($fp);

  print_map_end($fp);
  close $fp;
  # finished with html file

} # print_map_data_tbs

=cut

sub print_geo_data2 {
  # prints an output file of geodata for querying google
  my $typ          = shift @_;
  my $ofils_aref   = shift @_; # an array ref for generated files
  my $members_href = shift @_; # a hash ref of member objects

  my $ofil = "${typ}.geocode-data.txt";
  open my $fp, '>', $ofil
    or die "$ofil: $!";

  my @names = (sort keys %{$members_href});

  my $printed = 0;
  foreach my $n (@names) {
    my $m = $members_href->{$n};
    my $n = $m->name_key();
    print "Member '$n'...\n";

    my $stat = $m->get_status();
    $stat =~ s{,}{}g;
    my @s = split ' ', $stat;
    my %s;
    @s{@s} = ();
    next if exists $s{U};
    next if exists $s{K};
    next if exists $s{D};
    next if !defined $m->state() || !$m->state();
    next if !defined $m->city()  || !$m->city();

=pod

    # keep the geocode data, just don't show it when making
    # the map overlay

    # skip those not wanting to be on the map
    my $onmap = defined $m->onmap() ? $m->onmap() : '';
    next if ($onmap =~ /no/i);

=cut

    # put address in geo request form
    # watch for state code errors
    my $state = $m->state();
    my $len = length $state;
    if ($len != 2) {
      print "WARNING:  State must be the official abbreviation: '$state'\n";
      print "  Skipping name key '$n'...\n";
      next;
    }
    my $city = $m->city();

    # screen out some addresses
    # the '#' char is not accepted by google geocode request, try to remove it

    my $addr = $m->address1();
    die "bad address for name '$n': '# followed by space: '$addr'" if ($addr =~ /\#\s/);
    next if ($addr =~ m{\A psc}xmsi);
    $addr = '' if ($addr =~ m{\A po \s+ box}xmsi);
    $addr = '' if ($addr =~ m{\A dept \s+ of \s+ psy}xmsi);
    $addr = '' if ($addr =~ m{\A rr \s+}xmsi);
    if ($addr && $addr =~ m{\#}) {
      my @t = split(' ', $addr);
      my @a = ();
      foreach my $t (@t) {
	next if $t =~ /\#/;
	push @a, $t;
      }
      $addr = join ' ', @a;
    }

    my $addr2 = $m->address2();
    $addr2 = '' if !defined $addr2;
    die "bad address for key '$n': '# followed by space: '$addr2'"
      if ($addr2 =~ /\#\s/);
    next if ($addr2 =~ m{\A psc}xmsi);
    $addr2 = '' if ($addr2 =~ m{\A po \s+ box}xmsi);
    $addr2 = '' if ($addr2 =~ m{\A dept \s+ of \s+ psy}xmsi);
    $addr2 = '' if ($addr2 =~ m{\A rr \s+}xmsi);
    if ($addr2 && $addr2 =~ m{\#}) {
      my @t = split(' ', $addr2);
      my @a = ();
      foreach my $t (@t) {
	next if $t =~ /\#/;
	push @a, $t;
      }
      $addr2 = join ' ', @a;
    }

    my $cntry = $typ eq 'tbs' ? 'USA' : '';
    my @addrs
      = (
	 $addr,
	 $addr2,
	 $city,
	 $state,
	 # don't use zip code--confuses things for google
	);
    if ($cntry) {
      push @addrs, $cntry;
    }

    my $geodata = '';
    foreach my $s (@addrs) {
      next if !defined $s;
      next if !$s;
      # eliminate sequences of multiple
      $s =~ s{  }{ }g;
      # replace spaces with '+'
      $s =~ s{ }{+}g;
      # make lower case
      $s = lc $s;
      $geodata .= ',+'
	if $geodata;
      $geodata .= $s;
    }
    if (!$geodata) {
      print "WARNING: No geodata for key '$n'...\n";
    }
    next if !$geodata;
    print $fp "$typ $n $geodata\n";
    ++$printed;
  }

  if ($printed) {
    push @{$ofils_aref}, $ofil;
  }
  else {
    unlink $ofil if !$printed;
  }
} # print_geo_data2

sub print_map_markers_tbs {
  my $fp    = shift @_;
  my $geoid = shift @_;

  my $members_href = shift @_; # a hash ref
  my $geodata_href = shift @_; # a hash ref

  my %members = %{$members_href};
  my %geodata = %{$geodata_href};

  my $min_dist = 1; # mile
  my $max_dist = 5; # mile
  my $dist_range = $max_dist - $min_dist;

  my $debug = 0;

  my $i = 0;

  #print Dumper($members_href); die "debug exit";
  #print Dumper(\%members); die "debug exit";

  # print images first
  print $fp "    var images = [];\n";
  foreach my $i (1..4) {
    print $fp <<"HERE"
    images[$i] = new google.maps.MarkerImage('./map-icons/novco68-$i-plt-icon-45x45.svg',
      // This marker is 45 pixels wide by 45 pixels tall.
      new google.maps.Size(45, 45),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 1,44.
      new google.maps.Point(1, 44)
    );
HERE
  }

  print $fp <<"HERE3";

    var markers = [];
    var latlng  = [];
    var wid     = [];
    var hwid    = [];

HERE3

  my $typ = '';
  my $px_per_char = 6; # char width for 10px font

  foreach my $n (keys %geodata) {

    print "DEBUG: working name key '$n'\n"
      if $debug;

    my $name  = $members{$n}->name;
    my $rank  = $members{$n}->rank;
    my $onmap = $members{$n}->onmap;

    # some don't want to be shown on the map
    next if (defined $onmap && $onmap =~ /no/i);

    # note that the name below normally needs to be placed inside
    # single quotes since many names have a nickname inside double
    # quotes, thus we need to escape any apostrophes such as in "O'Brien"
    my $first_last = GENFUNCS::insert_rank_first_last($name, $rank);
    $first_last =~ s{'}{\\'}g;

    my $plt = $members{$n}->platoon;

    my $lat = $geodata{$n}{lat};
    my $lng = $geodata{$n}{lng};

    my $inum;
    if ($plt =~ /1/) {
      $inum = 1;
    }
    elsif ($plt =~ /2/) {
      $inum = 2;
    }
    elsif ($plt =~ /3/) {
      $inum = 3;
    }
    elsif ($plt =~ /4/) {
      $inum = 4;
    }
    else {
      die "FATAL:  Unknown platoon '$plt' for name key '$n'";
    }

    my $marker_type = 'MarkerWithLabel';

    my $fontname  = 'CousineBold';
    my $fontsize  = 10; # px;
    my $padding   =  2; # px
    my $borderwid =  2; # px

    print $fp <<"HERE2";

    latlng[$i]  = new google.maps.LatLng($lat, $lng);
    wid[$i]     = textWidth('$first_last', '${fontsize}px ${fontname}');
    hwid[$i]    = 0.5 * wid[$i] + $padding + $borderwid;
    markers[$i] = new ${marker_type}({
      position: latlng[$i],
      map: map,
      icon: images[$inum],
      labelContent: '$first_last',
      labelAnchor: new google.maps.Point(hwid[$i],1),
      //labelAnchor: new google.maps.Point(0,1),
      labelClass: 'mlabels', // the CSS class for the label
      labelStyle: {opacity: 1}
    });
HERE2

    last if $debug;

    ++$i;
  }

} # print_map_markers_tbs

sub print_member_data {
  # prints an output file of member data
  my $key          = shift @_; # 'tbs'
  my $ofils_aref   = shift @_; # an array ref for generated files
  my $members_href = shift @_; # a hash ref of member objects
  my $admin = shift @_ || 0;

  my $ofil = "./${key}-member-data.txt";
  if ($admin) {
    $ofil = "./${key}-brothers.source.txt";
  }
  open my $fp, '>', $ofil
    or die "$ofil: $!";

  push @{$ofils_aref}, $ofil;

  my @names = (sort keys %{$members_href});

  # need some headers
  {
    print $fp <<"HERE";
# This file is for the NovCo1968TBS Brothers' list.

# If a brother is going to a reunion, put the appropriate year after
# the 'reunion:' field; if he is taking his wife add a 'W' or 'w'
# immediately following the apprpriate year. See "Brooke, Robert
# O. Jr." for an example.

# If a brother does NOT want to be shown on the map, put 'no' in the
# 'onmap:' field.

# If a brother is found to be deceased, place the date of death after
# the 'deceased:' field in 'YYYY-MM-DD' format.  Use zeroes for unknown
# parts of the date, e.g., for a known death but unknown date you would
# use '0000-00-00', and for a known year but nothing else you would use
# 'YYYY-00-00', etc.

HERE
  }

  if ($admin) {
    print $fp <<"HERE";
# Known deceased and KIA brothers are at the end of the known living or
# status unknown brothers.

HERE
  }
  else {
    print $fp <<"HERE";
# Known deceased and KIA brothers are not shown in this file.  Check the
# web site private roster for those data.

HERE
  }

  my (@deceased) = ();

  foreach my $n (@names) {

    my $m = $members_href->{$n};
    my $n = $m->name_key();
    print "Member '$n'...\n";

    # skip deceased members
    my $stat = $m->get_status();
    $m->status($stat);

    if ($m->deceased || $m->kia) {
      push @deceased, $m;
      next;
    }

    # print most data fields
    print $fp "name: " . $m->name() . "\n";

    my $rank     = $m->rank     ? ' ' . $m->rank : '';

    my $platoon  = $m->platoon  ? ' ' . $m->platoon : '';
    my $home     = $m->home     ? ' ' . $m->home : '';
    my $home2    = $m->home2    ? ' ' . $m->home2 : '';
    my $mobile2  = $m->mobile2  ? ' ' . $m->mobile2 : '';
    my $fax      = $m->fax      ? ' ' . $m->fax : '';
    my $url      = $m->url      ? ' ' . $m->url : '';
    my $notes    = $m->notes    ? ' ' . $m->notes : '';

    my $address1 = $m->address1 ? ' ' . $m->address1 : '';
    my $address2 = $m->address2 ? ' ' . $m->address2 : '';
    my $city     = $m->city     ? ' ' . $m->city : '';
    my $state    = $m->state    ? ' ' . $m->state : '';
    my $zip      = $m->zip      ? ' ' . $m->zip : '';
    my $email    = $m->email    ? ' ' . $m->email : '';
    my $email2   = $m->email2   ? ' ' . $m->email2 : '';
    my $mobile   = $m->mobile   ? ' ' . $m->mobile : '';
    my $wife     = $m->wife     ? ' ' . $m->wife : '';
    my $reunion  = $m->reunion  ? ' ' . $m->reunion : '';
    my $status   = $m->status   ? ' ' . $m->status : '';
    my $deceased = $m->deceased ? ' ' . $m->deceased : '';
    my $dob      = $m->dob      ? ' ' . $m->dob : '';
    my $onmap    = $m->onmap    ? ' ' . $m->onmap : '';
    if ($onmap && $onmap !~ /no/) {
      $onmap = '';
    }

    print $fp "rank:$rank\n";
    print $fp "platoon:$platoon\n";
    #print $fp "status:$status\n";
    print $fp "address1:$address1\n";
    print $fp "address2:$address2\n";
    print $fp "city:$city\n";
    print $fp "state:$state\n";
    print $fp "zip:$zip\n";
    print $fp "email:$email\n";
    print $fp "email2:$email2\n";
    print $fp "mobile:$mobile\n";
    print $fp "mobile2:$mobile2\n";
    print $fp "home:$home\n";
    print $fp "home2:$home2\n";
    print $fp "fax:$fax\n";
    print $fp "url:$url\n";
    print $fp "wife:$wife\n";
    print $fp "reunion:$reunion\n";
    print $fp "dob:$dob\n";
    print $fp "onmap:$onmap\n";
    if ($admin) {
      print $fp "deceased:$deceased\n";
    }
    print $fp "notes:$notes\n";

    print $fp "\n";
  }

  return if (!($admin && @deceased));

  print $fp "\n##### KIA and deceased #####\n\n";

  foreach my $m (@deceased) {
    # print most data fields
    print $fp "name: " . $m->name() . "\n";

    my $rank     = $m->rank     ? ' ' . $m->rank : '';
    my $platoon  = $m->platoon  ? ' ' . $m->platoon : '';
    my $deceased = $m->deceased ? ' ' . $m->deceased : '';
    my $kia      = $m->kia      ? ' ' . $m->kia : '';

    print $fp "rank:$rank\n";
    print $fp "platoon:$platoon\n";
    if ($kia) {
      print $fp "kia:$kia\n";
    }
    elsif ($deceased) {
      print $fp "deceased:$deceased\n";
    }

    print $fp "\n";
  }

} # print_member_data

sub print_map_header_tbs {
  my $fp      = shift @_;
  my $typ     = shift @_;
  my $mparams = shift @_;
  my $sqdn    = shift @_;
  my $debug   = shift @_;

  $sqdn       = 0 if !defined $sqdn;
  $debug      = 0 if !defined $debug;

  confess "ERROR: undefined mparams for typ '$typ'" if !defined $mparams;

  my $ctr_lat = $mparams->ctr_lat();
  my $ctr_lng = $mparams->ctr_lng();
  my $min_lat = $mparams->min_lat();
  my $min_lng = $mparams->min_lng();
  my $max_lat = $mparams->max_lat();
  my $max_lng = $mparams->max_lng();

=pod

  see this link for tutorial help:

    http://code.google.com/apis/maps/documentation/javascript/tutorial.html

  see this link for static geocoding

    http://code.google.com/apis/maps/documentation/geocoding/index.html

  example of a geocoding request

    http://maps.googleapis.com/maps/api/geocode/json?address=113+canterbury+circle,+niceville,+fl&sensor=false

=cut

  my $unav = '';

  my $title = '';
  $title = 'Brothers Map' if ($typ eq 'tbs');

  # for the labels and box
  my $fontname  = 'CousineBold';
  my $fontsize  = 10; # px
  my $padding   =  2; # px
  my $borderwid =  2; # px

  print $fp <<"COMMON";
<!doctype html>
<html>
<head>
<title>$title</title>
<meta charset='UTF-8'>
<meta name='viewport' content='initial-scale=1.0, user-scalable=yes' />
$unav
<style type='text/css'>
  html { height: 100% }
  body { height: 100%; margin: 0; padding: 0 }
  /* map_canvas { height: 100% } */
  \@font-face {
    font-family: 'CousineBold';
    src: url('./Resources/fonts/Cousine-Bold-Latin-webfont.ttf');
  }
</style>
<style type='text/css'>
  .mlabels {
    color: gold;
    background-color: red;
    font-family: CousineBold;
    font-size: ${fontsize}px;
    font-weight: normal;
    padding: ${padding}px;
    text-align: center;
    border: ${borderwid}px solid black;
    white-space: nowrap;
  }
</style>
<script
  src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyBVk99PhQvaBG8lmCX_MX3EJ2n5kRHaun0'
></script>
<script
  src = './Resources/js-google/markerwithlabel_packed.js'
></script>

<script type='text/javascript'>

  function initialize() {

    function get_viewport_size(w) {
       // Javascript: The Definitive Guide, p. 391, Ex. 15-9
       // use the specified window or the current window if no argument
       w = w || window;

       // this works for all browsers except IE8 and before
       if (w.innerWidth != null)
         return { w: w.innerWidth,
                  h: w.innerHeight };

       // for IE (or any browser) in Standards mode
       var d = w.document;
       if (document.compatMode == 'CSS1Compat')
         return { w: d.documentElement.clientWidth,
                  h: d.documentElement.clientHeight };

       // for browsers in Quirks mode
       return { w: d.body.clientWidth,
                h: d.body.clientHeight };

    }

    function calc_zoom() {
      // given length of bounds' sides, calculate the correct zoom level;
      // depends on viewport size

      // sides in degrees (lat, lng)
      var xlen = $max_lng - $min_lng;
      var ylen = $max_lat - $min_lat;

      // convert to world coords (same as zoom level 0)
      var xworld = xlen / 360 * 256;
      var yworld = ylen / 170 * 256;

      // add a bit of border for flags to be in view
      var border = 44;

      // get the viewport in pixels
      var viewport = get_viewport_size();
      var xpixel = viewport.w;
      var ypixel = viewport.h;

      // convert to pixel coords at zero zoom
      // iterate over zoom levels until len is too great
      var tz = 0;
      for (var z = 1; z <= 19; ++z) {
        var xp = xworld * Math.pow(2, z) + border;
        var yp = yworld * Math.pow(2, z) + border;
        if (xp > xpixel || yp > ypixel) {
          tz = z - 1;
          break;
        }
        tz = z;
      }
      return tz;
    }

    var this_zoom = calc_zoom();

    // initialize to center of array
    var ctr_latlng = new google.maps.LatLng($ctr_lat, $ctr_lng);
    var myOptions = {
      zoom: this_zoom,
      center: ctr_latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    var map = new google.maps.Map(document.getElementById(\"map_canvas\"),
      myOptions);

    // write array of markers
    // we want the base of the flag pole to be at the location
    // Marker sizes are expressed as a Size of X,Y
    // where the origin of the image (0,0) is located
    // in the top left of the image.

    // Origins, anchor positions and coordinates of the marker
    // increase in the X direction to the right and in
    // the Y direction down.

    // define clickable area
    // Shapes define the clickable region of the icon.
    // The type defines an HTML <area> element 'poly' which
    // traces out a polygon as a series of X,Y points. The final
    // coordinate closes the poly by connecting to the first
    // coordinate.

    function textWidth(text, fontProp) {
        var tag = document.createElement("div");
        tag.style.position = "absolute";
        tag.style.left = "-999em";
        tag.style.whiteSpace = "nowrap";
        tag.style.font = fontProp;
        tag.innerHTML = text;

        document.body.appendChild(tag);

        var result = tag.clientWidth;

        document.body.removeChild(tag);

        return result;
    }
    // usage:
    //   var w = textWidth("Text", "bold 13px Verdana")

COMMON

} # print_map_header_tbs

sub print_member_data_rtf {
  # prints an output file of member data
  my $argref = shift @_;
  my $key          = $argref->{key}; # 'tbs'
  my $ofils_aref   = $argref->{ofils_aref}; # an array ref for generated files
  my $members_href = $argref->{members_href}; # a hash ref of member objects
  my $admin        = $argref->{admin} || 0;
  my $REUNION      = $argref->{reunion} || 0;

  my $ofil = "./${key}-member-data.rtf";
  if ($REUNION) {
    $ofil = "./${key}-reunion-list.rtf";
  }
  elsif ($admin) {
    $ofil = "./${key}-brothers.source.rtf";
  }

  open my $fp, '>', $ofil
    or die "$ofil: $!";

  push @{$ofils_aref}, $ofil;

  my $r  = RTF::Writer->new_to_handle($fp);

  # header info
  # "constants"
  my $tab = 0.25; # inches

  # other vars
  my $sb = 12./72.; # input must be in inches for my functions

  my @fonts
    = (
        'Times New Roman',
      );
  my $date = GENFUNCS::get_datetime();

  $r->prolog('fonts' => \@fonts,);

  # set document flags
  MyRTF::write_rtf_prelims($fp,
			   {
			    LM => 1.25,
			    RM => 1,
			    TM => 1,
			    BM => 1,
			    gutters => 1,
			   });
  MyRTF::set_rtf_pagenumber($fp,
			    {
			     #prefix   => 'R-',
			     justify  => 'r',
			     position => 'f'
			    });

  MyRTF::write_rtf_para($r, $fp, "TBS REUNION ATTENDEES",
			{
			 sb => 0,
			 justify => 'c',
			 bold => 1
			});
  MyRTF::write_rtf_para($r, $fp, "As of $date.",
			{
			 sb => 0.2,
			 justify => 'c',
			 bold => 1
			});
  MyRTF::write_rtf_para($r, $fp, "(Please notify Ed Browder of any errors or omissions.)",
			{
			 sb => 0.2,
			 sa => 0.2,
			 justify => 'c',
			 #bold => 0,
			});

  my @names = (sort keys %{$members_href});

  # first pass to get body count
  my $peeps = 0;
  foreach my $n (@names) {
    my $m = $members_href->{$n};
    my $n = $m->name_key();

    # skip deceased members
    my $stat = $m->get_status();
    $m->status($stat);
    next if ($m->deceased || $m->kia);

    # skip non-attendees
    my $reunion  = $m->reunion  ? $m->reunion : '';
    next if ($REUNION && !$reunion);

    ++$peeps;

    my $wife   = $m->wife ? $m->wife : '';
    my $friend = $m->friend ? $m->friend : '';
    my $status = $m->status   ? ' ' . $m->status : '';

    if ($status =~ /rw/i && $wife) {
      ++$peeps;
    }
    elsif ($status =~ /rf/i && $friend) {
      ++$peeps;
    }
  }

  # body count
  MyRTF::write_rtf_para($r, $fp, "\nTotal number people: $peeps", {bold => 1});

  my $tabg = 1.5; # inches

  my $num = 0;
  foreach my $n (@names) {

    my $m = $members_href->{$n};
    my $n = $m->name_key();
    print "Member '$n'...\n";

    # skip deceased members
    my $stat = $m->get_status();
    $m->status($stat);
    next if ($m->deceased || $m->kia);

    # skip non-attendees
    my $reunion  = $m->reunion  ? $m->reunion : '';
    next if ($REUNION && !$reunion);

    ++$num;

    # print some data fields
    my $rname  = GENFUNCS::insert_rank_last_first($m->name, $m->rank);
    my $wife   = $m->wife ? $m->wife : '';
    my $friend = $m->friend ? $m->friend : '';
    my $status = $m->status   ? ' ' . $m->status : '';

    my $Name;
    if ($status =~ /rw/i && $wife) {
      $Name = sprintf "%2d.\t$rname (wife: $wife)", $num;
    }
    elsif ($status =~ /rf/i && $friend) {
      $Name = sprintf "%2d.\t$rname (friend: $friend)", $num;
    }
    else {
      if ($n =~ /^browder/i) {
	$Name = sprintf "%2d.\t$rname (girl friend: Becky)", $num;
      }
      else {
	$Name = sprintf "%2d.\t$rname", $num;
      }
    }

    if ($n =~ /^hova/) {
	$Name .= ' (Silver Star)';
    }

    MyRTF::write_rtf_para($r, $fp, $Name, {sb => .1}); #, {fi => $tabg});

    my $platoon = $m->platoon  ? $m->platoon : '';
    MyRTF::write_rtf_para($r, $fp, "\t$platoon Platoon") if $platoon;

    # phones ==================================
    my $p = '';
    my @p = ();
    my %t =
      (
       0 => 'M',
       1 => 'M',
       2 => 'H',
       3 => 'H',
      );
    $p[0] = $m->mobile   ? $m->mobile : '';
    $p[1] = $m->mobile2  ? $m->mobile2 : '';
    $p[2] = $m->home     ? $m->home : '';
    $p[3] = $m->home2    ? $m->home2 : '';
    for (my $i = 0; $i < 4; ++$i) {
      my $val = $p[$i];
      next if !$val;
      my $typ = $t{$i};
      $p .= ', ' if $p;
      $p .= "$val ($typ)";
    }
    MyRTF::write_rtf_para($r, $fp, "\t$p")
	if $p;

    # emails ==================================
    my $e = '';
    my $email = $m->email ? $m->email : '';
    $e = "email: $email" if $email;
    my $email2 = $m->email2 ? $m->email2 : '';
    die "???" if ($email2 && !$email);
    $e .= ", $email2" if $email2;
    MyRTF::write_rtf_para($r, $fp, "\t$e")
	if $e;

    # address ==================================
    my $address1 = $m->address1 ? $m->address1 : '';
    MyRTF::write_rtf_para($r, $fp, "\t$address1")
	if $address1;
    my $address2 = $m->address2 ? $m->address2 : '';
    MyRTF::write_rtf_para($r, $fp, "\t$address2")
	if $address2;
    my $city = $m->city ? $m->city : '';
    my $state = $m->state ? $m->state : '';
    my $zip = $m->zip ? $m->zip : '';

    my $town;
    if ($city) {
      $town = $city;
    }
    if ($state) {
      $town .= ', ' if $town;
      $town .= $state;
    }
    if ($zip) {
      $town .= '  'if $town;
      $town .= $zip;
    }
    MyRTF::write_rtf_para($r, $fp, "\t$town")
	if $town;

    # may need to start a new page at some point
    if ($n =~ /^davis/i
       || $n =~ /^sloan/i
       #|| $n =~ /^saunders/i
       #|| $n =~ /^oliveri/i
       #|| $n =~ /^ryan/i
       ) {
      # page break AFTER the name above
      $r->Page();
    }

  }

  # repeat body count
  #MyRTF::write_rtf_para($r, $fp, "\nTotal number people: $peeps", {bold => 1});

  # close the file
  $r->close();

} # print_member_data_rtf

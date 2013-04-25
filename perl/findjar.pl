#!/usr/bin/perl -w
use strict;

use File::Find;

find( \&visitor, @ARGV );

my $filename;
my $filepath;
my $filedir;
my $filesize;
my $fileversion;

sub visitor {
    $filename = $_;
    $filepath = $File::Find::name;
    $filedir = $File::Find::dir;

    if ( -f $filepath && $filename =~ /.jar$/ ) {

	my @stats = stat( $filepath );
	$filesize = $stats[7];

	my $syscmd = "unzip -q -c $filepath META-INF/MANIFEST.MF  | grep -i Implementation-Version";

	$fileversion = qx( $syscmd );

	$fileversion =~ s/\n.*//s;
	$fileversion =~ s/Implem[-\w]*\s*:\s*//i;

	#print "$filename version: $fileversion\n";
	#print "$filename\t$filesize\t$filedir\n";
	write();
    }
}

format STDOUT =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<< @##########  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$filename,   $fileversion, $filesize,     $filedir
.


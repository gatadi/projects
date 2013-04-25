#!/usr/bin/perl

use Data::Dumper;

my $base_dir = "e:/development/snapfish/dev/public_html/" ;
open(FILE, "E:/Workarea/bin/page_to_script_popup.txt") || die "Cannot open pagenames_to_script_popup.csv";
@list = <FILE>;
close FILE;

foreach (@list) {
  chomp;
  local @parms=split /;/, $_;
  local $ifile = $base_dir.$parms[0];
  local $flag = $parms[1];
  local $title = $parms[2];
  local $ofile = $ifile . ".tmp";
  local $replace_title = 0;
  if ($flag eq "Y") { $replace_title = 1; }
  local $replace_title = ($flag eq "Y");
  print ". processing $ifile and flag is $flag (replace title: $replace_title)\n";
  open(IFILE, "<$ifile") || die "Cannot open $ifile";
  @icontent = <IFILE>;
  close IFILE;
  open(OFILE, ">$ifile") || die "Cannot open $ifile for editing";
  local $after_body_open = 0;
  local $after_body_close = 0;
  local $omniture_added = 0;
  local $after_title = 0;
  foreach (@icontent) {
    $line = $_;
    if ($line =~ /<title>.*?<\/title>/i) {
        print ". . title found\n";
        if ($replace_title) {
          $line =~ s/(.*?)<title>.*?<\/title>(.*?)/${1}<title><%= siteName %> $title<\/title>${2}/;
        }
        $after_title = 1;
    }
    if (!$omniture_added) {
      if ($after_body_close) {
        if (!$replace_title) {
          print ". . setting pagename\n";
          print OFILE "<% sPageName=\"$title\"; %>\n";
        }
        print ". . adding Omniture include\n";
        print OFILE "<%@ include file=\"/default/jsp/include/tracking/omniture_tracking.jsp\" %>\n";
        $omniture_added = 1;
      }
    }
    if ($line =~ /<body.*?[^%]>/i) {
      print ". . full body found\n";
      $after_body_close = 1;
    }
    if ($line =~ /<body.*?/i) {
      print ". . body open found\n";
      $after_body_open = 1;
    }
    if ($after_body_open && !$after_body_close) {
      if ($line =~ /[^%]>/) {
        print ". . body close found\n";
        $after_body_close = 1;
      }
    }
    print OFILE $line;
  }
  close OFILE;
  if (!$after_title) {
    print ". . title not found for $ifile\n";
  }
  if (!$after_body_close) {
    print ". . body not found for $ifile\n";
  }
}

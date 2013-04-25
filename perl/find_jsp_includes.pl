#!/usr/bin/perl

#require 5.006;

use warnings;
use strict;

use English;
use Carp;
use File::Find;

if (@ARGV < 1 || grep { m{ ^ -?-h(?:elp)? $ }mxs } @ARGV) {
    croak <<USAGE;
Usage: $0 [directory] [filelist.txt]
    Where:

    [directory]    is the directory to look in for jsp files. These
                   files will be parsed for jsp include statements
                   and the names of the jsps that are included will
                   be the output of this program.

    [filelist.txt] is optional, and is the list of possible jsp
                   includes. Any files not in this list will not
                   be reported as includes by this program. This is
                   useful if you're only interested in getting a list
                   of some of the included jsps.

    --help, -h     generate this help output
USAGE
}

my ($directory, $filelist) = @ARGV;

my $filelist_re = "";
if (defined $filelist) {
    open my $filelist_h, '<', $filelist or croak "Cannot open $filelist: $!";
    my $raw_filelist_re;
    while (my $file = <$filelist_h>) {
        chomp $file;
        $file = quotemeta $file;
        $filelist_re .= "(?:$file)|";
    }
    # remove extra |
    chop $filelist_re;
    close $filelist_h or croak "Cannot close $filelist: $!";
}

my @include_list = find_includes($directory);

if ($filelist_re) {
    @include_list = grep { m{ $filelist_re }mxs } @include_list;
}

print join("\n", @include_list), "\n";

## SUBS ##

sub find_includes {
    my ($dir) = @_;

    my %includes = ();
    find(
        sub {
            eval {
                if ( -f && m{ [.]jsp $ }mxs ) {
                    #print "Looking at $File::Find::name\n";
                    # it's a file, and it's a jsp
                    open my $jsp_h, '<', $_ or croak "Open failed: $!";
                    my $jsp = do { local $RS; <$jsp_h>; };
                    close $jsp_h or croak "Close failed: $!";
                    while (
                        $jsp =~ m{ [<][%][@]
                                        \s*
                                        include \s* file
                                        \s* = \s* 
                                        " ([^"]*) "
                                        \s*
                                    [%][>]
                                }mxsg
                    ) {
                        my $include_name = $1;
                        # make sure there are no dupes
                        $includes{$include_name} = 1;
                        #print "Found $include_name\n";
                    }
                }
            };

            if ($EVAL_ERROR) {
                # a problem with one file shouldn't ruin the fun
                # for everyone
                carp "$File::Find::name: $EVAL_ERROR\n";
            }
        },
        $dir
    );

    return keys %includes;
}

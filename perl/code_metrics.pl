#!/bin/perl -w
use Date::Parse;
use Getopt::Long;


# Extract P4 activity data by using P4's command line interface and parsing  P4 command output.



# Does an analysis of P4 activity for the specified p4_users.
# This is done by retrieving all changelists and examining the
# contents of the changelists.
sub do_p4_analysis() {
    my ($startDate, $endDate) = @_;
    my (%line_counts_added_files_ref, %lineCountsModifiedFiles_ref, $change_desc_lines_ref, @change_lists);
    my (@merged_files);
    my ($p4_user, $list_of_lists_ref);
    my ($modified_files_ref, $added_files_ref );

    foreach $p4_user (@p4_users) {
        #Get change lists for the date range
        @change_lists=&get_change_lists_for_date_range($p4_user, $startDate, $endDate);
        $change_desc_lines_ref = execute("p4 describe @change_lists");
        $list_of_lists_ref = &decompose_changelists_into_files($change_desc_lines_ref);
        $added_files_ref = $list_of_lists_ref->[0];
        $modified_files_ref = $list_of_lists_ref->[1];
        #&dump_list_ref($added_files_ref, "added files");
        my $list_of_file_tables_ref = [];
        $list_of_file_tables_ref ->[0] = &get_line_counts_for_added_files($added_files_ref);
        $list_of_file_tables_ref ->[1] = &get_line_counts_for_modified_files($change_desc_lines_ref);
        #&dump_hash($list_of_file_tables_ref ->[1]);
        $p4_userActivity {$p4_user} = $list_of_file_tables_ref;
    }
    &print_summary();
    &print_report();
}


# Find all P4 changelists submitted by $name that lie in the
# specified date range.
#
sub get_change_lists_for_date_range {
    my($name, $startDate, $endDate)=@_;
    my(@clists, @changelist, $clist, @c);
    @clists=`p4 changelists -u $name`;
    #@clists = `cat changelists`;
    foreach  $clist (@clists) {
        @c=split /\s+/, $clist;
        if ( &does_date_lie_in_range($c[3], $startDate, $endDate)){
            push(@changelist, $c[1]);
        }
    }
    return @changelist;
}



# Takes in a list of changelists and breaks them down into 4 lists
# - newly added files
# - modified filed... //depot/Snapfish/Projects/Absol/install/spec/shamla-spec.pl#1 add
#- deleted files
# merged files
#

sub decompose_changelists_into_files {
    my($change_desc_lines_ref) = shift;
    my(@addedFiles, @modifiedFiles, @mergedFiles);
    my @decomposed_file_list;
    foreach  (my $i = 0; $i <= $#$change_desc_lines_ref; $i++) {
            chomp $change_desc_lines_ref->[$i];
            #print " looking at $change_desc_lines_ref->[$i] \n"; #/\.\.\.[ ]+(.*)#[0-9]+add/
           if ( $change_desc_lines_ref->[$i] =~ /^\.\.\.(.*)#\d+.*add$/) { # Add branch check
                push(@addedFiles, $1);
           } elsif ( $change_desc_lines_ref->[$i] =~ /^\.\.\.(.*)#\d+.*edit$/) { # Add branch check
                push(@modifiedFiles, $1);
           } elsif ( $change_desc_lines_ref->[$i] =~ /^\.\.\.(.*)#\d+.*edit$/) { # Add branch check
                push(@mergedFiles, $1);
           }
    }
    push(@decomposed_file_list,  \@addedFiles);
    push(@decomposed_file_list,  \@modifiedFiles);
    push(@decomposed_file_list,  \@mergedFiles);
    return \@decomposed_file_list;

}

# Convert file paths of the ...//depot/Snapfish/Projects/Venusaur////.Blah.java
# to C:/development /etc/etc/Blah.java
#
sub convert_p4_path_to_windows_path {
    my ($files_ref) = shift;
    foreach (@$files_ref) {
        s/^\.\.\.//;
        s/#.*$//;
    }
}


# Exclusion  filter for taking files out of consideration.
sub exclude_file {
    my $file = shift;
    my $exclude = 0;
    #Check file extension. Exclude .doc,, .xls
    if ( $file=~/.*\.doc/) {
        $exclude = 1;
    } elsif ($file=~/.*\.xls/) {
        $exclude = 1;
    } elsif ($file=~/.*config\.xml/) { # avoid config.xml files
        $exclude =1;
    } elsif ($file =~ /.*\.png/) {
        $exclude =1;
    } elsif ($file =~ /.*\.gif/) {
        $exclude =1;
    } elsif ($file =~ /.*\.jpg/) {
        $exclude =1;
    }
    return $exclude;
}


# Run a remote fstat on the file and obtain file size
sub get_fstat_on_added_files {
    my $added_files_ref  = shift;
    my ($str_to_exec, $fstat_info_ref);
    $str_to_exec = "p4 fstat -Ol ";
    if ( $#$added_files_ref == 0) {
        print " get_fstat_on_added_files returning nothing ";
        return ();
    }
    for(my $i = 0; $i <= $#$added_files_ref; $i++)  {
         $str_to_exec = $str_to_exec.$added_files_ref->[$i]." ";
    }
    $fstat_info_ref = execute($str_to_exec);
    return $fstat_info_ref;
}


# Execute a command and return the results
sub execute {
    my ($exec_command) = shift;
    my (@return_values);
    #print "Executing command $exec_command\n";
    @return_values=`$exec_command`;
    return \@return_values;
}


#Parse diff output to figure out what to hom many lines are added, modified etc.
sub get_line_counts_for_modified_files {
my %lineCounts;
my $lines_ref = shift;
my ($linesAdded, $linesModified, $file);

foreach (@$lines_ref){
    chomp;
    if ( $_ eq "" )  {
        next;
    }elsif ( /^===.*(\/\/depot.*)#.*/){
        $file = $1;
        $linesAdded = $linesModified = 0;
        } elsif (/^([\d]+a[\d]+)$/) { # diff output lines of the form 3a4
                #print " got 3a4--> $1\n";
            $linesAdded++;
            $lineCounts{$file} = &updateCounts($linesAdded, $linesModified, $lineCounts{$file});
            $linesAdded = $linesModified = 0;
        }elsif (/^([\d]+c[\d]+)$/) { # diff output lines of the form 3c4
            #print " got 3c4--> $1\n";
            $linesModified++;
            $lineCounts{$file} = &updateCounts($linesAdded, $linesModified, $lineCounts{$file});
            $linesAdded = $linesModified = 0;
        }elsif (/^([\d]+a[\d]+[,][\d]+)$/) { # diff output lines of the form 3a10,14
            #print " got 3a10,14--> $1\n";
            $linesAdded += &analyze_diff_output_line($1);
            $lineCounts{$file} = &updateCounts($linesAdded, $linesModified, $lineCounts{$file});
            $linesAdded = $linesModified = 0;
        }elsif (/^([\d]+c[\d]+,[\d]+)$/) { #diff output of the form 3c10, 14
            #print " got 3a4,14--> $1\n";
            $linesModified += &analyze_diff_output_line($1);
            $lineCounts{$file} = &updateCounts($linesAdded, $linesModified, $lineCounts{$file});
            $linesAdded = $linesModified = 0;
        } elsif (/^([\d]+,[\d]+c[\d]+[,][\d]+)$/) {#diff outtput of the form 10, 20 c 120, 140
            #print " got 3,4c10,14--> $1\n";
            $linesModified += &analyze_diff_output_line($1);
            $lineCounts{$file} = &updateCounts($linesAdded, $linesModified, $lineCounts{$file});
            $linesAdded = $linesModified = 0;
        }
    }
    return \%lineCounts;
}



# Returns line counts for the newly added files.
# Uses p4 fstat to get bytes in the file and then estimates line count
#This is approximate but better than doing a wc -l which requires sync'ing the file over which
# is major pain., especially as the branch in question may not be in your client spec.

sub get_line_counts_for_added_files {
    my ($files_added_ref) = shift;
    my ($file, %lineCounts, $fstatInfo_ref, @windowsFiles, $fileLineCount, $fileSize);
    &convert_p4_path_to_windows_path($files_added_ref);

    $fstatInfo_ref = &get_fstat_on_added_files($files_added_ref);
    #@fstatInfo = `cat fstat`;
    for (my $i = 0; $i <= $#$fstatInfo_ref; $i++) {
        my $fstat_line = $fstatInfo_ref->[$i];
        if ($fstat_line =~ /^...[\s]*.*File[\s+](.*$)/) {
            $file = $1;
        } elsif ($fstat_line =~ /^...[\s]*fileSize[\s+]([\d]+)/) {
            $fileSize = $1;
            $fileLineCount = $fileSize/$BYTES_PER_LINE;
            if ( ! &exclude_file($file)) {
                $lineCounts{$file} = int($fileLineCount);
            }
        }
    }
    return \%lineCounts;
}


#Accepts String of the form 3a4,40 || 3,5c10,15
#Only the last 2 digits are of interest.
#Number of lines changed or added = the difference of the two last digits +1
sub analyze_diff_output_line {
    my($diffOutput) = @_;
    my($startLineNum, $endLineNum);
    #print "diffOutput = $diffOutput\n";
    /.*[ac](.*)/, $diffOutput; # drop everything including the letter
    ($startLineNum, $endLineNum) = split /,/, $1;
    return $endLineNum - $startLineNum + 1;
}


# Returns true if a date of the form 3/6/2008 lies in between a range of dates in
# the same format
#
 sub does_date_lie_in_range {
    my ($date, $startDate, $endDate) = @_;
    $date = &flip_date($date);
    $time = str2time($date);
    $startTime = str2time($startDate);
    $endTime = str2time($endDate);
    if ( $time > $startTime && $time < $endTime) {
        return 1;
    }
    return 0;
}

#Perforce dates have the year in the beginning which perl doesn'nt like
# This flips it around. 2008/6/13 becomes 6/13/2008
#
sub flip_date {
    my ($date) = @_;
    my ($month, $day, $year);
    $month = $day = $year = "";
    ($year, $month, $day) = split /\//,$date;
    return $month."/".$day."/".$year;
}


# Given an offset in seconds,, Return's date in format m/dd/yyyy.  To get current date, set offset to 0

sub get_date {
    my ($offset_from_today);
    $current_time= getTime();
    $future_time = $current_time + $offset_from_today;
    return str2time($future_time);
}

sub get_user_list {
    my $file_name = shift;
    my @user_list;
    open IN_FILE , $file_name or die " Cannot open $file_name for read \n";
    while (<IN_FILE>) {
        chomp;
        push(@user_list, $_);
    }

    return @user_list;
}


sub print_summary {
    my ($p4_user, $listOfFileTables_ref, $lineCountsAddedFiles_ref, $lineCountsModifiedFiles_ref);
    my ($numAddedFiles, $numAddedLines, $numModifiedFiles, $totalModifiedLineCounts);
    &printHeader();
    foreach $p4_user (keys %p4_userActivity) {
        $listOfFileTables_ref  = $p4_userActivity{$p4_user};
        $lineCountsAddedFiles_ref = $$listOfFileTables_ref[0];
        $lineCountsModifiedFiles_ref = $$listOfFileTables_ref[1];
        $numAddedFiles = &getNumKeysInHash($lineCountsAddedFiles_ref);
        $numAddedLines = getSumValuesOfHash($lineCountsAddedFiles_ref);
        $numModifiedFiles = &getNumKeysInHash($lineCountsModifiedFiles_ref);
        $totalModifiedLineCounts = &getTotalModifiedLineCounts($lineCountsModifiedFiles_ref);
        printf '%12s', "$p4_user     ";
        printf '%17s', "$numAddedFiles($numAddedLines)";
        printf '%27s', "$numModifiedFiles, $totalModifiedLineCounts\n ";
    }
}


sub print_report {
    my ($list, $p4_user, $listOfFileTables_ref);
    my($lineCountsAddedFiles_ref, $lineCountsModifiedFiles_ref);
    foreach $p4_user (keys %p4_userActivity) {
        &printReportHeader($p4_user);
        $listOfFileTables_ref  = $p4_userActivity{$p4_user};
        $lineCountsAddedFiles_ref = $$listOfFileTables_ref[0];
        $lineCountsModifiedFiles_ref = $$listOfFileTables_ref[1];
        &dump_hash($lineCountsAddedFiles_ref);
        &printReportDivider();
        &dump_hash($lineCountsModifiedFiles_ref);
    }
}


sub printReportHeader {
    my ($p4_user) = @_;
    print"\n\n\n\n";
    print "\t\t\t\t";
    print "P4 Activity Report for $p4_user $startDate - $endDate\n\n\n";
    &printSeparator();
    printf '%10s', "New Files Added"; printf '%19s', "Line Count\n";
    &printSeparator();
}



sub printHeader {
    print"\n\n\n\n";
    print "\t\t\t\t";
    print "P4 Activity Report  $startDate - $endDate\n\n\n";
    &printSeparator();
    printf '%10s', "\t\t\tNew Files \t\t\t Modified Files(a,c) \n";
    &printSeparator();
}

sub printReportDivider {
    print"\n\n\n\n";
    print "\t\t\t\t";
    &printSeparator();
    printf '%10s', "Files Modified"; printf '%19s', "Line Added       Lines Modified\n";
    &printSeparator();
}

sub printSeparator {
    print "--------------------------------------------------------------------------\n";
}


sub getNumKeysInHash {
    my $hash_ref = shift;
    my $num_keys = 0;
    foreach my $key (keys %$hash_ref) {
        $num_keys++;
    }
    return $num_keys;
}

sub dump_hash {
    my $hash_ref = shift;
    my $file_cnt = 1;
    foreach my $key (keys %$hash_ref) {
        printf "$file_cnt.  \t\t\t $key $$hash_ref{$key}\n";
        $file_cnt++;
    }
}

sub getSumValuesOfHash {
    my $hash_ref = shift;
    my $sigma_values=0;
    foreach my $key (keys %$hash_ref) {
        $sigma_values += $$hash_ref{$key};
    }
    return $sigma_values;
}


sub getTotalModifiedLineCounts {
    my $file_line_counts_ref = shift;
    my $tot_lines_modified = 0;
    my $tot_lines_added = 0;
    my  ($value, $lines_added, $lines_modified);
    foreach my $key (keys %$file_line_counts_ref) {
        $value = $$file_line_counts_ref{$key};
        ($lines_added, $lines_modified) = split ',', $value;
        $tot_lines_modified += $lines_modified;
        $tot_lines_added += $lines_added;
    }
    return "($tot_lines_added, $tot_lines_modified)";
}

sub print_p4_userReport {
    ($p4_user) = @_;
    print"\n\n\n\n";
    print "\t\t\t\t";
    print "P4 Report - $p4_user \n\n\n";
}




# List dump for debugging
#
sub dump_list {
    my(@list, $str) = @_;
    print "$str \n $#list";
    foreach (@list) {
        chomp;
        print "$_\n";
    }
}

sub dump_list_ref {
    my ($list_ref, $str) = @_;
    print "$str \n";
    for (my $i = 0; $i < $#$list_ref; $i++) {
            print "$list_ref->[$i] \n";
    }
}
#Returns line counts for modified files. Modified files can have added lines, modified lines and deleted lines
#
#

sub updateCounts {
    my ($linesAdded, $linesModified, $oldValues) =@_;
    my($oldValLinesAdded, $oldValLinesModified);
    if ( $oldValues) {
        ($oldValLinesAdded, $oldValLinesModified) = split ',', $oldValues;
    } else {
        $oldValLinesAdded = 0;
        $oldValLinesModified = 0;
    }
    $linesAdded +=  $oldValLinesAdded;
    $linesModified +=  $oldValLinesModified;
    #print "New values -->$linesAdded, $linesModified\n";
    return "$linesAdded, $linesModified";
}
sub usage {
    print "Usage : perl code_metrics.pl [-h] [-startDate m/dd/yyyy] \n";
    print "\t[-endDate m/dd/yyyy] in_file \n";
    print "Where :\n";
    print "in_file must contain p4 user names, one per line";
}


#start main()
$BYTES_PER_LINE = 39; #Average number of bytes/line for Snapfish
%options=();
%options=();
GetOptions( "h"=>\$help_flag,
            "startDate=s"=>\$startDate,
            "endDate=s"=> \$endDate);
$file_name = $ARGV[0];
if ( $help_flag) {
    &usage();
    exit();
}
$file_name = $ARGV[0];
&usage() if (! $file_name);
@p4_users = &get_user_list($file_name);
&do_p4_analysis( $startDate, $endDate);
#end main()



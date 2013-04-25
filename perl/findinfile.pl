#!/usr/local/bin/perl

use strict;

use File::Find;
use File::Listing ;

use File::Listing qw(parse_dir);

my $doc_root = "e:/development/snapfish/dev/public_html/" ;
my $JSP_ROOT = "e:/development/snapfish/dev/public_html/default/jsp/uk/popups" ;

my (@list_file_paths) ;
my (@list_file_names) ;
my $jsp_count = 0 ;






main() ;




sub main
{
    list($JSP_ROOT);
    #search_file_usage_in_files() ;
    #print "search"  ;
    #search();

}




sub search
{
    my $file = "E:/development/snapfish/dev/compiled/jsplist/corejsplist.txt" ;
    my @list_of_files_used_in_workflow ;

    if(open(MYFILE, $file))
    {
        my $line = "/".<MYFILE>;
        $line =~ s/[\n]+//g ;
        $line =~ s/\/\//\//g;
        while($line ne "")
        {
            my $count = @list_of_files_used_in_workflow ;
            $list_of_files_used_in_workflow[$count] = $line ;
            $line = "/".<MYFILE>;
            $line =~ s/[\n]+//g ;
            $line =~ s/\/\//\//g;
        }
    }

    close(MYFILE) ;

    my $file_count = @list_of_files_used_in_workflow ;
    my @list_of_all_files = list($JSP_ROOT) ;

    my $count =  @list_of_all_files ;
    for(my $i=0; $i<$count ; $i++)
    {
        my $file = $list_of_all_files[$i] ;
        if( search_file_in_filelist( $file, @list_of_files_used_in_workflow) ){
        }else{
            print "\n$file" ;
        }
    }

    $count = @list_of_files_used_in_workflow ;
    print "\nworkflow list count=$count" ;

}







#list(dir)
sub list
{
    my $dir = $_[0] ;
    for(parse_dir(`ls $dir -l`))
    {
        my ($name, $type, $size, $mtime, $mode) = @$_;
        if($type eq 'd')
        {
            list($dir."/".$name) ;
        }

        if($type eq 'f')
        {
            my $count = @list_file_paths ;
            $list_file_names[$count] = $name ;
            my $file_path = "$dir/$name" ;
            $file_path =~  s/($doc_root)//g ;
            $list_file_paths[$count] = $file_path ;
            #print "[$jsp_count] $file_path\n" ;
            print "$file_path\n" ;
            $jsp_count++ ;
        }
    }

    return @list_file_paths ;
}   #end of list




sub search_file_usage_in_files
{
    my $file_count = @list_file_names ;
    for(my $c=0; $c<$file_count ; $c++)
    {
        my $pattern = $list_file_names[$c] ;
        my $count = @list_file_paths ;
        my $found = 0 ;
        for(my $i=0; $i<$count ; $i++)
        {
            #print "\n$i=$list_file_paths[$i]\n";
            next if $found ne 0 ;

            if(search_pattern_in_file($pattern, $list_file_paths[$i])){
                $found = 1 ;
            }else{
                $found = 0 ;
            }
        }

        if( $found eq 0 ){
            print "$pattern is not found in any file\n" ;
        }
    }
}   #end of search


sub search_pattern_in_file
{
    my $pattern = $_[0] ;
    my $file = $_[1] ;

    if(open(MYFILE, $file))
    {
        my $line = <MYFILE>;
        while($line ne "")
        {
            my $found = $line =~ /($pattern)/ ;
            if( $found )
            {
                print "\n$line\n" ;
                return 1 ;
            }

            $line = <MYFILE>;
        }
    }

    close(MYFILE) ;
    return 0 ;
}


sub search_file_in_filelist
{
    my ($file, @file_list) = @_ ;
    my $count = @file_list ;

    print "$file\n=>\n" ;
    for(my $i=0; $i<$count; $i++)
    {
        print "[$i] $file_list[$i]\n" ;
        if( $file eq $file_list[$i] ){
            print "Equals" ;
            return 0 ;
        }
    }
    return 1 ;
}




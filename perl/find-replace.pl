use Getopt::Long;
use File::Find ;

my $match = "" ;
my $replace = "" ;
my $searchFolder = "WebContent" ;
my @searchresults = () ;
my @filesToAdd = () ;
my $p4Path = "WebContent/components/" ;

main() ;

sub main()
{
    if(@ARGV < 2){
        die "Usage : perl $0 search-string replace-string\n" ;
    }
    ($match, $replace) = @ARGV ;
    
    print "\nSearching for $match...\n" ; 
    find(\&wanted, $searchFolder);

    my $count = @searchresults;
    print "\nFound following $count file(s) :" ;
    print "\n==============================================================\n";
    foreach(@searchresults){
        print $_ ;
    }
    print "\n==============================================================\n";
    
    executeCMD("ant cloneComponent -Dpath=$match -DnewPath=$replace -DnewVariation=default") ;
    executeCMD("p4 delete $p4Path$match/...");
    find(\&findFilesToAdd, "$p4Path$replace");
    foreach(@filesToAdd){
        executeCMD("p4 add $_");
    }
    
    foreach(@searchresults)
    { 
        my $file = $_ ; 
        if( /^WebContent\/frameworksf/ ){
            $file =~ s/WebContent\/frameworksf/..\/..\/components\/snapfish-fe-framework\/javascript\/frameworksf/ ;
        }else
        {
            if( /^WebContent\/framework/ ){
                $file =~ s/WebContent\/frameworksf/..\/..\/components\/fe-framework\/javascript\/framework/ ;
            }
        }
        
        print "\n------------------------------------------------------------------------\n";
        print "Updating file:\n$file" ;
        print "\n------------------------------------------------------------------------\n\n";
        
        executeCMD("p4 edit $file");
        
        open($FILE, "<$file") || die "Can not open file : $!" ;
        my @content = <$FILE> ;
        close $FILE;
        
        my @newcontent = () ;
        foreach(@content)
        {
            my $line = $_ ;                
            if( $line =~ /['"]($match)['"]/)
            {
                print $line ;
                $line =~ s/($match)/$replace/ ;                
                print $line."\n" ;                
            }
            push(@newcontent, $line);
        }
        
        open($OUTFILE, ">$file") ||  "Can not open file: $!" ;
        print $OUTFILE @newcontent ;
        close $OUTFILE;
    }
}

sub wanted 
{ 
    eval 
    {
        if(-f && (/.js/ || /.html/ || /.properties/) )
        {            
            my  $found = 0 ;
            open my $INFILE, '<', $_ or die "Open failed: $!";
            my @lines = <$INFILE> ;
            close $INFILE;      
            foreach(@lines)
            {
                my $line = $_ ;                
                if( $line =~ /['"]($match)['"]/)
                {
                    print $line ;                    
                    $found = 1 ;
                }
            }
            
            if( $found == 1)
            {
                #print "\n$File::Find::name\n\n\n";
                push(@searchresults, "$File::Find::name\n");                
            }
        }
    }
}



sub findFilesToAdd 
{ 
    eval 
    {
        if(-f)
        {            
            push(@filesToAdd, "$File::Find::name\n");                            
        }
    }
}
sub executeCMD()
{
    my ($cmd) = @_ ;
    print $cmd ;
    system($cmd) ;
}






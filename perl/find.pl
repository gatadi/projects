use Getopt::Long;
use File::Find ;

my $match = "" ;
my $replace = "" ;
my $searchFolder = "WebContent" ;
my @searchresults = () ;

main() ;

sub main()
{
    if(@ARGV < 1){
        die "Usage:  perl $0 [search-string]" ;
    }
    
    ($match) = @ARGV ;
    
    find(\&wanted, $searchFolder);
    print "==============================================================\n";
    foreach(@searchresults)
    {
        print $_ ;
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
                print "\n$File::Find::name\n\n\n";
                push(@searchresults, "$File::Find::name\n");                
            }
        }
    }
}

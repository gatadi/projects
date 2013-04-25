use Getopt::Long;
use File::Find ;

my $match = "" ;
my $replace = "" ;
my $searchFolder = "WebContent" ;

main() ;

sub main()
{
    GetOptions(
        "o|old=s" => \$match, 
        "n|new=s" => \$replace) ;
        
    if($match eq "" || $replace eq ""){
        die "Usage perl find-component-usage.pl -old shared/widgets/other/Pagination -new widgets/util/Pagination\n";
    } 
    find(\&wanted, $searchFolder);
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
            foreach(@lines)
            {
                my $line = $_ ;                
                if( $line =~ /['"]($match)['"]/)
                {
                    print $line ;
                    $line =~ s/($match)/$replace/ ;                
                    print $line ;
                    $found = 1 ;
                }
            }
            close $INFILE;      
            if( $found == 1){
                print "$File::Find::name\n\n\n\n";
            }
        }
    }
}


sub renameComponent()
{
    print "Cloning Component...\n" ;
    #system("ant cloneComponent -Dpath=$match -DnewPath=$replace -DnewVariation=default") ;
    print "p4 delete $p4Path$match/...\n" ;
    #system("p4 delete $p4Path$match/...");
    print "p4 add $p4Path$replace/...\n" ;
    #system("p4 add $p4Path$replace/...");
}

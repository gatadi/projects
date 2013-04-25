use LWP::UserAgent;
use Net::HTTP ;
 
my $ua = LWP::UserAgent->new;
$ua->timeout(5);
$ua->env_proxy;

open(my $fin, "<", "..\/4136445008.txt") ;

my $count = 1 ;
while(<$fin>)
{
    my $line = $_ ;
    chomp($line) ;
    print "\n[$count] => ".$line ;
    
    my $response = $ua->get( $line, ":content_file" => $count.".jpg");
    if(length($line)>5){
        $count = $count+1 ;
    }
}


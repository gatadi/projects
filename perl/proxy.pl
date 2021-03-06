#!/usr/bin/perl  #use strict;
use URI;
use IO::Socket;
use strict;
use warnings ;
use threads('yield', 'stack_size' => 128*4096);
# don't want to die on 'Broken pipe' or Ctrl-C $SIG{PIPE} = 'IGNORE';



my $swiftPort = 8080 ;
my $proxyHost = "web-proxy";
my $proxyPort = 8088 ;
    
    
my $showOpenedSockets=1;
  
my $server = IO::Socket::INET->new (    
        LocalPort => 3128,    
        Type      => SOCK_STREAM,    
        Reuse     => 1,    
        Listen    => 100);

binmode $server;
  
while (my $browsera = $server->accept()) 
{   
    #print "\n\n----Accepted Connection--------\n";
    binmode $browsera;
    my $t = threads->new(\&fetch, $browsera);
    $t->detach;
}   

sub fetch
{      
    my $browser = $_[0];
    my $method              ="";
    my $content_length      = 0;
    my $content             = 0;
    my $accu_content_length = 0;
    my $host;
    my $hostAddr;
    my $httpVer;
    my $swiftServer = "localhost" ;
    my $isSwiftUrl = 0 ;
        
    while(my $browser_line = <$browser>) 
    {     
        unless ($method) 
        {       
            ($method, $hostAddr, $httpVer) = $browser_line =~ /^(\w+) +(\S+) +(\S+)/;
            #print "$hostAddr";
            my $uri = URI->new($hostAddr) or print "Could not build URI for $hostAddr";
            if( $uri->path_query =~ /^\/[a-z]+\/fe\/[a-z]+/)
            {
                #send the requests to local swift server
                print $browser_line ;
                print "\n\n";
                $host = IO::Socket::INET->new (         
                    PeerAddr=> $swiftServer,  
                    Type      => SOCK_STREAM,                        
                    PeerPort=> $swiftPort );
                die "couldn't open $hostAddr" unless $host;
                $isSwiftUrl =1 ;

            }else
            {
                $isSwiftUrl = 0 ;
                if($proxyHost)
                {
                    print "Connecting through proxy: $proxyHost:$proxyPort\n" ;
                    #send the requests to proxy
                    $host = IO::Socket::INET->new (         
                        PeerAddr=> $proxyHost,  
                        Type      => SOCK_STREAM,    
                        PeerPort=> $proxyPort );
                    die "couldn't open $hostAddr" unless $host;                                        
                }else
                {
                    #send the requests to remote
                    $host = IO::Socket::INET->new (         
                        PeerAddr=> $uri->host,    
                        Type      => SOCK_STREAM,    
                        PeerPort=> $uri->port );
                    die "couldn't open $hostAddr" unless $host;
                    
                }
            }
            
            if ($showOpenedSockets) 
            {         
                #print "Opened ".$uri->host." , port ".$uri->port."\n";
            }
            
            if($isSwiftUrl == 1 || !$proxyHost)
            {
                
                print $host "$method ".$uri->path_query." $httpVer\n";
            }
            else
            {                
                print $host $browser_line;                                   
            }
            
            print $browser_line ;
            binmode $host;              
            
            next;
        }      
        
        $content_length = $1 if      $browser_line=~/Content-length: +(\d+)/i;
        $accu_content_length+=length $browser_line;
        #print $browser_line;
        binmode $host;
        print $host $browser_line;
        last if $browser_line =~ /^\s*$/ and $method ne 'POST';
        if ($browser_line =~ /^\s*$/ and $method eq "POST") 
        {       
            $content = 1;
            last unless $content_length;
            next;
        }     
        if ($content) 
        {       
            $accu_content_length+=length $browser_line;
            last if $accu_content_length >= $content_length;
        }   
    }   
    #print "\n\nThread id --> ".threads->self->tid()."\n";
    #print "No of. threads at present --> ".threads->list()."\n";
    #print "Stack size --> ".threads->get_stack_size()."\n";
    $content_length      = 0;
    $content             = 0;
    $accu_content_length = 0;
    while (my $host_line = <$host>) 
    {     
        #print $host_line;
        binmode $browser ;                
        print $browser $host_line;
        $content_length = $1 if $host_line=~/Content-length: +(\d+)/i;
        if ($host_line =~ m/^\s*$/ and not $content) {       
            $content = 1;
            #last unless $content_length;
            next;
        }     
        if ($content) 
        {       
            if ($content_length) 
            {         
                $accu_content_length+=length $host_line;
                #print "\nContent Length: $content_length, accu: $accu_content_length\n";
                last if $accu_content_length >= $content_length;
            }     
        }   
    }   
    $browser-> close;
    $host   -> close;
    #print "---- End thread ----\n";
 } 
 
 
 
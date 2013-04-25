use Net::FTP;


my $from_file = "e:\\workarea\\bin\\myftp.pl" ;

my $ftp ;




ftp_a_file();



sub ftp_a_file
{
    do_ftp_login();
    do_chdir("/export/home/dev/vijay/deploy") ;
    do_put($from_file);
    do_ls() ;
    do_ftp_logout() ;

}   #end of ftp_a_file()




sub do_ftp_login
{
    print "\nOpening FTP Connection..." ;

    $ftp = Net::FTP->new("localhost", Timeout => 15, Debug => 0) ;
    $login_status = $ftp->login("dev", "dlyl00n");

    if( $login_status ){
        print "CONNECTED";
    }else{
        print "FAILED" ;
    }
    print "\n" ;

}   #end of do_ftp_login

sub do_ftp_logout
{
    print "\n\nClosing FTP Connection..." ;
    $ftp->close() ;
    print "CLOSED\n\n" ;
}   #end of do_ftp_logout()

sub do_get
{
    my ($file) = @_ ;

    print "\ndo_get(\"$file\")" ;
    $ftp->get($file) or die "", $ftp->message ;

}   #end of do_get


sub do_put
{
    my ($file) = @_ ;

    print "\ndo_put($file)" ;
    $ftp->put($file) or die "", $ftp->message ;

}   #end of do_put


sub do_chdir
{
    my ($dir) = @_ ;
    print "\ndo_chdir($dir)" ;

    $ftp->cwd($dir) or die "", $ftp->message ;

}   #end of do_chdir()


sub do_ls
{
    $pwd = $ftp->pwd() ;
    print "\ndo_ls($pwd)" ;

    @ls = $ftp->ls() or die "", $ftp->message;
    foreach my $type (@ls){
        print "\n$type" ;
    }

}   #end of do_ls()


sub do_mkdir
{
    my ($dir) = @_ ;
    print "\ndo_mkdir($dir)" ;

    $ftp->mkdir($dir) or die "", $ftp->message ;
}   #end of do_mkdir()

use Net::Telnet;



my ($file) = "myftp.pl" ;
my ($to_dir) = "/opt/usr/apps/snapcat/webapps/ROOT/default/jsp/ad" ;

my ($backup_file) = $file.".bak" ;
my ($SCP_COMMAND) = "scp dev\@nice:/export/home/dev/vijay/deploy/$file $to_dir" ;

my $telnet ;


main();



sub main()
{
    do_telnet_login();
    do_ssh_login("fell") ;
    do_scp();
    do_ssh_logout();
    do_telnet_logout() ;

}   # end of main()





sub do_telnet_login
{
    print "\nOpening TELNET Connection ..." ;
    $telnet = Net::Telnet->new(Timeout => 20);
    $telnet->errmode('return');
    $telnet->open("localhost");
    $telnet->login("dev", "dlyl00n");
    $telnet->cmd("cd /export/home/dev/vijay/deploy");
    print "CONNECTED" ;

}   #end of do_telnet_login()


sub do_ssh_login
{
    my ($args) = @_ ;
    my ($host) = $args ;
    my ($SSH_STRING) = "ssh -l dev $host" ;

    print "\n\nSSH to $host" ;  print flush ;

    $telnet->print($SSH_STRING);

    if (!$telnet->waitfor('/password[: ]*$/i'))
    {
        die "\n\ncould not connect to $host";
    }
    else
    {
        $telnet->print('dlyl00n'); $telnet->waitfor(Timeout => 5);
    }

    $telnet->cmd("hostname");
    $telnet->cmd("pwd");
    $telnet->cmd("cd $to_dir");

    print "\n\nHostname: ".($telnet->cmd("hostname"))[0] ;
    print "\nPWD: ".($telnet->cmd("pwd"))[0] ;
    print flush ;

}   #end do_ssh_login()


sub do_scp
{
    print "\n\nAdding write permissions...." ;
    $telnet->cmd("chmod +w $file");   print "DONE" ;
    do_println($telnet->cmd("ls -l $file"));

    print "\n\nCreating backup file..." ;
    $telnet->cmd("cp $file $backup_file"); print "DONE\n" ;

    print "\n\nCopying file securely(scp)..." ; print flush;
    $telnet->print($SCP_COMMAND);
    if (!$telnet->waitfor('/password[: ]*$/i'))
    {
        die "\ncould not connect to nice";
    }
    else
    {
        $telnet->print('dlyl00n'); $telnet->waitfor(Timeout => 5);
    }
    print "DONE" ;

    print "\n\nRemoving write permissions...." ;
    $telnet->cmd("chmod -w $file");   print "DONE" ;
    do_println($telnet->cmd("ls -l $file"));

}   #end of do_scp()


sub do_ssh_logout
{
    #closiong SSH
    $telnet->cmd("exit");
}   #end of do_ssh_logout()


sub do_telnet_logout
{
    $telnet->close() ;
}   #end of do_telnet_logout()


sub do_println
{
    print "\n";
    my $line = "" ;
    foreach my $type (@_){
        print $line ;
        $line = $type ;
    }
}

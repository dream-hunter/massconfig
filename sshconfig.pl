#!/usr/bin/perl -w

use strict;
use warnings;
use Net::SSH2;

my $username = 'admin';             # Juniper SSH user
my $password = 'adminpassword';     # Juniper SSH password

my @cmd12 = (
    'op url pasvftp://ftpbackup:ftppass@10.10.10.10/slax/chpass-12.slax key md5 5b01b11f19c40430134db2a825126abe'
);
my @cmd15 = (
    'op url pasvftp://ftpbackup:ftppass@10.10.10.10/slax/chpass.slax key md5 ece7bf69c28a79803939c486458198f7'
);
my @cmd20 = (
    'op url pasvftp://ftpbackup:ftppass@10.10.10.10/slax/chpass-20.slax key 02f120a7f290f336860efa4070eeb5084f317c6eca95ba0fb0109c4bae074ad9'
);

my $rtrlist="./devices_juniper.css";

open (RTR, "$rtrlist") || die "Can't open $rtrlist file";
while (<RTR>) {
    chomp(my $rtr="$_");
    my @str = split(",", $rtr);
    $rtr = $str[0];
    my $version = $str[3];
    my @cmd;
    if ($version =~ '12.*') { print "Ver12\n"; @cmd = @cmd12 }
    if ($version =~ '15.*') { print "Ver15\n"; @cmd = @cmd15 }
    if ($version =~ '20.*') { print "Ver20\n"; @cmd = @cmd20 }
    print "Trying to configure $rtr\n";
    my $ssh2 = Net::SSH2->new(timeout => 30000);
    if ($ssh2->connect($rtr) or print "Timeout error\n") {
        if ($ssh2->auth_password($username,$password)) {
            foreach my $command (@cmd) {
                my $chan = $ssh2->channel();
                print "Applying command: '$command'\n";
                $chan->exec($command);
                while (<$chan>) {
                    print $_;
                }
                $chan->close;
            }
        } else {
            print "auth failed.\n";
        }
    } else {
        print "Unable to connect Host $@ \n";
    }
    $ssh2->disconnect();
}

print "END\n";
#!/usr/bin/perl -w
#
#    snmpcfg.pl -- a script to perform mass configuration changes to
#                  a list of routers using SNMP.
#
#
$workingdir  = ".";                            # Path to this script

$snmprw      = "RWCOMMUNITY";                  # SNMPv2 community string read documentation how to restict access to snmp

$ftpsrv      = "x.x.x.x";                      # Ip address your FTP server. Read how to configure user access to your config folder
$ftproot     = "/backupftp";                   # Local root folder on your FTP server that stores configs (FTProot)
$ftpdir      = "out";                          # Nested folder on your FTP server that stores configs
$ftpuser     = "ftpbackup";                    # Unix/FTP user
$ftpgroup    = "nogroup";                      # Unix group (requires for grant access)
$ftppass     = "ftppass";                      # FTP password
$ftpmconf    = "SNMPCFG";                      # Config filename
$ftprconf    = "";                             # Config revision (not required)

$rtrlistfile = "devices_cisco.css";            # File with cisco IP list

$logfile     = "RESULT.log";                   # Log file

$filecat     = `chmod 664 $ftproot/$ftpdir/$ftpmconf$ftprconf | chown $ftpuser:$ftpgroup $ftproot/$ftpdir/$ftpmconf$ftprconf`;
if ($filecat) { }
#
$rtrlist="$workingdir/$rtrlistfile";
open (RTR, "$rtrlist") || die "Can't open $rtrlist file";
open (LOG, ">$workingdir/$logfile") || die "Can't open $workingdir/$logfile file";
#
  $rnd = int(rand(999));
  $rnd1= $rnd+1;
while (<RTR>) {
  chomp($rtr="$_");

  my @str = split(",", $rtr);
  $rtr = $str[0];

  print LOG "= = = = = = = = = = = = = = = = = = = = = = = = \n";
  print "= = = = = = = = = = = = = = = = = = = = = = = = \n";
  $snmpset="/usr/bin/snmpset -t 20 -r 1 -t 2 -v 2c -c $snmprw $rtr ";
# We will use FTP
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.2.$rnd i 2`);
#ccCopySourceFileType: networkFile
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rnd i 1`);
#ccCopyDestFileType: runningConfig
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rnd i 4`);
#Ftp server address
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$rnd a $ftpsrv`);
#Filename
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$rnd s $ftpdir/$ftpmconf$ftprconf`);
#FTP Username
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.7.$rnd s $ftpuser`);
#FTP password
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.8.$rnd s $ftppass`);
#ccCopyEntryRowStatus:
  chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd i 1`);

  if ($result eq "SNMPv2-SMI::enterprises.9.9.96.1.1.1.1.14.$rnd = INTEGER: 1" || $result eq "iso.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd = INTEGER: 1") {
        print LOG "$rtr - Update Successful\n";
        print "$rtr - Update Successful\n";
        $rnd = int(rand(999));
#ccCopySourceFileType: runningConfig
        chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rnd1 i 4`);
#ccCopyDestFileType: startupConfig
        chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rnd1 i 3`);
#ccCopyEntryRowStatus:
        chomp($result=`$snmpset 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd1 i 1`);
        if ($result eq "SNMPv2-SMI::enterprises.9.9.96.1.1.1.1.14.$rnd1 = INTEGER: 1" || $result eq "iso.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd1 = INTEGER: 1") {
            print LOG "$rtr - Wr Mem Successful\n";
            print "$rtr - Wr Mem Successful\n";
        }
        else {
            print LOG "$rtr - Wr Mem Failed Result = $result\n";
            print "$rtr - Wr Mem Failed Result = $result\n";
        }
  }
  else {
    print LOG "$rtr - Update Failed. Result = $result\n";
    print "$rtr - Update Failed Result = $result\n";
  }
}

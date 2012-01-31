#!/usr/bin/perl

use strict;
use lib "/opt/vyatta/share/perl5/";
use Vyatta::Config;
use Vyatta::Interface;
use Getopt::Long;

my ($init, $op_mode);
GetOptions(
    "init=s"       => \$init,
    "op-mode!"    => \$op_mode
);
my $exists = ($op_mode ? 'existsOrig' : 'exists');
my $returnValues = ($op_mode ? 'returnOrigValues' : 'returnValues');
my $returnValue = ($op_mode ? 'returnOrigValue' : 'returnValue');

my $vc     = new Vyatta::Config();
my $vcRoot = new Vyatta::Config();
my $cmd_args = "";

$vc->setLevel('service dhcp-relay');
if ( $vc->$exists('.') ) {

    my $port = $vc->$returnValue("relay-options port");
    if ( $port ne '' ) {
        $cmd_args .= " -p $port";
    }

    my @interfaces = $vc->$returnValues("interface");
    foreach my $ifname (@interfaces) {
        my $intf = new Vyatta::Interface($ifname);
        die "DHCP relay configuration error."
          . "Unable to determine type of interface \"$ifname\".\n"
          unless $intf;

        die
"DHCP relay configuration error.  DHCP relay interface \"$ifname\" specified has not been configured.\n"
          unless $vcRoot->$exists( $intf->path() );

        $cmd_args .= " -i " . $intf->name();
    }

    my $count = $vc->$returnValue("relay-options hop-count");
    if ( $count ne '' ) {
        $cmd_args .= " -c $count";
    }

    my $length = $vc->$returnValue("relay-options max-size");
    if ( $length ne '' ) {
        $cmd_args .= " -A $length";
    }

    my $rap = $vc->$returnValue("relay-options relay-agents-packets");
    if ( $rap ne '' ) {
        $cmd_args .= " -m $rap";
    }

    my @servers = $vc->$returnValues("server");
    if ( @servers == 0 ) {
        die
"DHCP relay configuration error.  No DHCP relay server(s) configured.  At least one DHCP relay server required.\n";
    }

    foreach my $server (@servers) {
        die
"DHCP relay configuration error.  DHCP relay server with an empty name specified.\n"
          if ( $server eq '' );

        $cmd_args .= " $server";
    }
}

if ( $init ne '' ) {
    if ( $cmd_args eq '' ) {
        exec "$init stop";
    }
    else {
        exec "$init restart $cmd_args";
    }
}


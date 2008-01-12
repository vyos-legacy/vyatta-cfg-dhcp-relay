#!/usr/bin/perl

use strict;
use lib "/opt/vyatta/share/perl5/";


my $error = 0;


use Getopt::Long;
my $change_dir;
my $modify_dir;
my $init;
GetOptions("change_dir=s" => \$change_dir, "modify_dir=s" => \$modify_dir, "init=s" => \$init);

use VyattaConfig;
my $vc = new VyattaConfig();
my $vcRoot = new VyattaConfig();

if ($change_dir ne '') {
        $vc->{_changes_only_dir_base} = $change_dir;
}
if ($modify_dir ne '') {
	$vc->{_new_config_dir_base} = $modify_dir;
}


my $cmd_args = "";

$vc->setLevel('service dhcp-relay');
if ($vc->exists('.')) {

	my $port = $vc->returnValue("relay-options port");
	if ($port ne '') {
		$cmd_args .= " -p $port";
	}

	my @interfaces = $vc->returnValues("interface");
	if (@interfaces == 0) {
		print stderr "DHCP relay configuration error.  No DHCP relay interface(s) configured.  At least one DHCP relay interface required.\n";
		$error = 1;
	} else {
		foreach my $interface (@interfaces) {
			if ($interface eq '') {
				print stderr "DHCP relay configuration error.  DHCP relay interface with an empty name specified.\n";
				$error = 1;
			} else {
				if (!$vcRoot->exists("interfaces ethernet $interface")) {
					$error = 1;
					print stderr "DHCP relay configuration error.  DHCP relay interface \"$interface\" specified has not been configured.\n";
				}
				$cmd_args .= " -i $interface";
			}
		}
	}

	my $count = $vc->returnValue("relay-options hop-count");
	if ($count ne '') {
		$cmd_args .= " -c $count";
	}

	my $length = $vc->returnValue("relay-options max-size");
	if ($length ne '') {
		$cmd_args .= " -A $length";
	}

	my $rap = $vc->returnValue("relay-options relay-agents-packets");
	if ($rap ne '') {
		$cmd_args .= " -m $rap";
	}

	my @servers = $vc->returnValues("server");
	if (@servers == 0) {
		print stderr "DHCP relay configuration error.  No DHCP relay server(s) configured.  At least one DHCP relay server required.\n";
		$error = 1;
	} else {
		foreach my $server (@servers) {
			if ($server eq '') {
				print stderr "DHCP relay configuration error.  DHCP relay server with an empty name specified.\n";
				$error = 1;
			} else {
				$cmd_args .= " $server";
			}
		}
	}
}

if ($error) {
	print stderr "DHCP relay configuration commit aborted due to error(s).\n";
	exit(1);
}


if ($init ne '') {
	if ($cmd_args eq '') {
		exec "$init stop";
	} else {
		exec "$init restart $cmd_args";
	}
}


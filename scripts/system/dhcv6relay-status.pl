#!/usr/bin/perl

# Module: dhcv6relay-status.pl
#
# **** License ****
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# A copy of the GNU General Public License is available as
# `/usr/share/common-licenses/GPL' in the Debian GNU/Linux distribution
# or on the World Wide Web at `http://www.gnu.org/copyleft/gpl.html'.
# You can also obtain it by writing to the Free Software Foundation,
# Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# This code was originally developed by Vyatta, Inc.
# Portions created by Vyatta are Copyright (C) 2010 Vyatta, Inc.
# All Rights Reserved.
#
# Author: Bob Gilligan
# Date: April 2010
# Description: Script to display status about DHCPv6 relay agent
#
# **** End License ****

use strict;
use lib "/opt/vyatta/share/perl5/";

use Getopt::Long;
use Vyatta::Config;

# Globals
my $op_mode_flag;       # Indicates we are running in op mode if set.

GetOptions(
    "op_mode"           => \$op_mode_flag,
);

#
# Main Section
#

my $vcDHCP = new Vyatta::Config();

my $exists=$vcDHCP->existsOrig('service dhcpv6-relay');

my $configured_count=0;
if ($exists) {
    printf("DHCPv6 Relay Agent is configured ");
    $configured_count++;
} else {
    printf("DHCPv6 Relay Agent is not configured ");
}

my $ps_output=`ps -C dhcrelay -o args --no-headers`;

my $running_count=0;

my @output = split(/\n/, $ps_output);

foreach my $line (@output) {
    if ($line =~ m/ -6 /) {
	if ($configured_count == 0) {
	    printf("but ");
	} else {
	    printf("and ");
	}
		   
	printf("is running.\n");
	$running_count++;
    }
}

if ($running_count == 0) {
	if ($configured_count == 0) {
	    printf("and ");
	} else {
	    printf("but ");
	}
    printf("is not running.\n");
}

exit 0;


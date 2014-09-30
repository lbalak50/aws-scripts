#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

my $sqlite = '/usr/bin/sqlite3';
my $db = '/www/db/useragents';
my ($ua);
my (%uas, %dbdata);

#open IN, "</var/log/nginx/access.log" or die "Couldn't access /var/log/nginx/access.log: $! \n";
open IN, "</tmp/access_log" or die "Couldn't access /var/log/nginx/access.log: $! \n";
while (my $line = <IN>) {
	chomp($line);
	if ($line =~ /((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\s*\-\s*.*?\s*\[(.*?)\]\s*\"(.*?)\"\s*(\d+)\s*\d+\s*\".*?\"\s*\"(.*?)\"/) {
		$ua = $5;
		# FIX ME!!!
		# Temporary fix for bash UA bug checking
		#$ua =~ s/&//g;
		#$ua =~ s#\/##g;
		#$ua = quotemeta($ua);
		if ($ua =~ /[&\\]/) { print STDERR "$ua\n"; next; }
		$uas{$ua}++;
	}
}
close IN;

my @data = `$sqlite $db "select uas,hitcount from useragents"`;
#print Dumper(@data);
foreach my $line ( @data ) {
	chomp($line);
	my ($dbua, $hc) = split(/\|/, $line);
	#print "$dbua\t$hc\n";
	if ((!defined($hc)) || ($hc eq "")) { $hc = 0; }
	$dbdata{$dbua} = $hc;
}

# update the user-agents we already know about
foreach my $dbua (keys %dbdata) {
	if (exists($uas{$dbua})) {
		my $cnt = $uas{$dbua} + $dbdata{$dbua};
		system("$sqlite $db \"update useragents set hitcount='$cnt' where uas='$dbua'\"");
		delete($uas{$dbua});
	}
}

# insert whatever is left
foreach my $ua ( keys %uas ) {
	given ($ua) {
		when (/bot/) {
			system("$sqlite $db \"insert into useragents values('$ua','bot','$uas{$ua}')\"");
		}
		when (/\(\)\s*\{\s*\:\;\}/) {
			system("$sqlite $db \"insert into useragents values('$ua','shellshock','$uas{$ua}')\"");
		}
		default {
			system("$sqlite $db \"insert into useragents values('$ua','','$uas{$ua}')\"");
		}
	}
}


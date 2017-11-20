#!/usr/bin/perl

use strict;
use Switch;
use Sys::Hostname;

# --------- base config -------------
my $ZabbixServer = "Hostname or IP";
my $HostName = hostname();
# ----------------------------------

switch ($ARGV[0]){
  case "discovery" {
    my $first = 1;

    print "{\n";
    print "\t\"data\":[\n\n";

    my $result = `/usr/bin/supervisorctl status`;

    my @lines = split /\n/, $result;
    foreach my $l (@lines) {
            my @stat = split / +/, $l;
    #        my $status = substr($stat[1], 0, -1);

                    print ",\n" if not $first;
                    $first = 0;

                    print "\t{\n";
                    print "\t\t\"{#NAME}\":\"$stat[0]\",\n";
                    print "\t\t\"{#STATUS}\":\"$stat[1]\"\n";
                    print "\t}";
    }

    print "\n\t]\n";
    print "}\n";
  }
  case "status" {
    my $result = `/usr/bin/supervisorctl pid`;

    if ( $result =~ m/^\d+$/ ) {
            $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s "$HostName" -k "supervisor.status" -o "OK"`;
            print $result;

            $result = `/usr/bin/supervisorctl status`;

            my @lines = split /\n/, $result;
            foreach my $l (@lines) {
                    my @stat = split / +/, $l;

                    $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s "$HostName" -k "supervisor.check[$stat[0],Status]" -o $stat[1]`;
                    print $result;
            }
    }
    else {
            # error supervisor not runing
            $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s "$HostName" -k "supervisor.status" -o "FAIL"`;
            print $result;
    }
  }
  case "active" {
    my $percent = 50;
    my $numrun = 0;
    my $numsum = 0;
    my $result = `/usr/bin/supervisorctl pid`;
    if ( $result =~ m/^\d+$/ ) {
            $result = `/usr/bin/supervisorctl status`;
            my @lines = split /\n/, $result;
            foreach my $l (@lines) {
                    my @stat = split / +/, $l;
                    if ($stat[0] =~ m/beanstalkdWorkers/) {
                        $numsum++;
                        if ($stat[1] =~ m/RUNNING/) {
                                $numrun++;
                        }
                    }
            }
        if ($percent*$numsum/100 > $numrun) {
                # error less than 50% workers not runing
                $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s "$HostName" -k "supervisor.active" -o "Alert $numrun of $numsum active workers !"`;
                print $result;
        }
      	else {
      		$result = `/usr/bin/zabbix_sender -z $ZabbixServer -s "$HostName" -k "supervisor.active" -o "OK"`;
      		print $result;
      	}
    }
  }
}

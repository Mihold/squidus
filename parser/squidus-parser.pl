#!/usr/bin/perl

# Squidus (c) 2012 Mykhaylo Kutsenko
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 
# For details see http://www.gnu.org/licenses/gpl-2.0.html

# usage: squidus-parser.pl [date]
#	today		 - only current day
#	yesterday	 - yesterday
#	YYYYMMDD	 - parse day

use URI;
use DBI;
use Time::Local;

sub printlog {
	my @logtime=localtime();
	open (SQUIDUSLOG, ">>", $logpath . "squidus.log") or die ">>>> cannot open log file $!";
	printf SQUIDUSLOG "%04u-%02u-%02u %02u:%02u:%02u %s\n", $logtime[5]+1900, $logtime[4]+1, $logtime[3], $logtime[2], $logtime[1], $logtime[0], shift(@_);
	close (SQUIDUSLOG);
}

#Defaults
my $filter_date	= 0;
my $debug = 0;
my $file_log = "";
	#squid native log
	#970313965.619 1249	  denis.local TCP_MISS/200 2598 GET	   http://www.emalecentral.com/tasha/thm_4374x013.jpg -		DIRECT/www.emalecentral.com image/jpeg
	# timestamp	  elapsed host		  type		   size method url													user  hierarechy					type
my $logline_col_timestamp	= 0;	# squid native log format
my $logline_col_userhost	= 2;	# squid native log format
my $logline_col_type		= 3;	# squid native log format
my $logline_col_size		= 4;	# squid native log format
my $logline_col_method		= 5;	# squid native log format
my $logline_col_url			= 6;	# squid native log format
my $logline_col_username	= 7;	# squid native log format
my $accesslogpath	= "";			# Path to access log files
my @filelist	= ("access.log");	# parse access.log only
my $squidus_server_id 	= 1;		# Proxy server ID
my $dbi_driver		= "mysql";		# DBS type
my $dbi_hostname	= "localhost";	# DB server host name or IP
my $dbi_db_name		= "squidus";	# Database name
my $dbi_user		= "parser";		# DB user name
my $dbi_password	= ''; 			# DB user haven't password

my $logpath		= "";
if (-d "/var/log/") {
	$logpath = "/var/log/";
}
my $file_conf	= "squidus.conf";
if (-d "/etc/") {
	$file_conf = "/etc/squidus.conf";
}

printlog ">>>> Start parsing.";

# Get parameters from config file
if (open (CONFIG, "<", $file_conf)) {
	while ($config_line = <CONFIG>) {
		chomp ($config_line);
		$config_line =~ s/#.*//;		# Remove coments
		$config_line =~ s/^\s*//;		# Remove spaces at the start of the line
		$config_line =~ s/\s*$//;		# Remove spaces at the end of the line
		if ($config_line ne ""){		# Ignore lines starting with blank lines
			($config_param, $Value) = split (/=/, $config_line);	# Split each line into name value pairs
			$config_param =~ s/^\s*//;
			$config_param =~ s/\s*$//;
			$Value =~ s/^\s*//;
			$Value =~ s/\s*$//;
			if ($config_param eq "proxy_logfilelist") {
				@filelist = reverse split (/[;\,\s]+/, $Value);
				if (@filelist == 0) {
					printlog ">>>>Error! File list is empty. Program terminated.";
					exit;
				}
			}
			elsif ($config_param eq "proxy_logfilepath") {
				$accesslogpath = $Value;
			}
			elsif ($config_param eq "dbs_hostname") {
				$dbi_hostname = $Value;
			}
			elsif ($config_param eq "dbs_username") {
				$dbi_user = $Value;
			}
			elsif ($config_param eq "dbs_userpass") {
				$dbi_password = $Value;
			}
			elsif ($config_param eq "dbs_database") {
				$dbi_db_name = $Value;
			}
			elsif ($config_param eq "squidus_proxyid") {
				if ($Value > 0) {
					$squidus_server_id = $Value;
				} else {
					printlog ">>>>Error! Unknown value in required parameter squidus_proxyid. Program terminated.";
					exit;
				}
			}
			elsif ($config_param eq "logcol_datetime") {
				$logline_col_timestamp = $Value;
			}
			elsif ($config_param eq "logcol_userhost") {
				$logline_col_userhost = $Value;
			}
			elsif ($config_param eq "logcol_status") {
				$logline_col_type = $Value;
			}
			elsif ($config_param eq "logcol_requestsize") {
				$logline_col_size = $Value;
			}
			elsif ($config_param eq "logcol_requestmethod") {
				$logline_col_method = $Value;
			}
			elsif ($config_param eq "logcol_requesturl") {
				$logline_col_url = $Value;
			}
			elsif ($config_param eq "logcol_username") {
				$logline_col_username = $Value;
			}
			elsif ($config_param eq "debug") {
				$debug = $Value;
			}
			else {
				printlog "Warning! Unknown parameter in config file - $config_param";
			}
        }
	}
	close (CONFIG);
} else {
	printlog "Warning! Can't open config file.";
}

# Check date filter
if (exists $ARGV[0]) {
	if ($ARGV[0] eq "today") {
		$filter_date = int(time()/86400)*86400;
	}
	elsif ($ARGV[0] eq "yesterday") {
		$filter_date = (int(time()/86400)-1)*86400;
	}
	elsif ($ARGV[0] =~ m/^(\d\d\d\d)(\d\d)(\d\d)$/) {
		$filter_date = timegm( 0, 0, 0,$3,$2-1,$1);
	} else {
		print "Unknown parameter.\nusage: squidus-parser.pl [date]\n\ttoday\t\t- only current day\n\tyesterday\t- yesterday\n\tYYYYMMDD\t- parse day";
		printlog ">>>>Error! Unknown command line parameter.";
		exit;
	}
}
if ($filter_date != 0) {
	my @ftime=gmtime($filter_date);
	printlog sprintf "Set date filter for today. [%04u-%02u-%02u %02u:%02u:%02u GMT]", $ftime[5]+1900, $ftime[4]+1, $ftime[3], $ftime[2], $ftime[1], $ftime[0];
}

# Connect to database server and set transaction mode
$dbh = DBI->connect("DBI:$dbi_driver:database=$dbi_db_name;host=$dbi_hostname",
    $dbi_user, $dbi_password, {AutoCommit => 0}) || die print "Can't connect";

my $logline_date	= 0;
foreach $filename (@filelist) {
	print ">>> use file :: $accesslogpath$filename\n" if ($debug > 0);
	printlog "Parsing file $accesslogpath$filename";
	open (ACCESSLOG, "<", "$accesslogpath$filename") or die "can't access log file\n";
	#open ACCESSLOG, "$catname $accesslogpath/$filename|" || die "can't access log file\n";
	$linenum = 0;

	while (<ACCESSLOG>) {
		chomp;
		$debug_loglines++;
		$linenum++;
		print ">>>> Parsing line $linenum\n$_\n" if ($debug > 9);

		(@logline) = split;
		$logline_timestamp = int($logline[$logline_col_timestamp]);
		

		# Filtering by date
		if ($filter_date != 0) {
			if ($logline_timestamp < $filter_date) {
				print ">>>> skipTimestampFilter skiping lines...\n" if (($debug > 1) and ($linenum == 1));
				print ">>>> skipTimestampFilter $logline_timestamp\n" if ($debug > 8);
				$debug_skipbyfilter++;
				next;
			}
			if ($logline_timestamp > $filter_date + 86399) {
				print ">>>> skipTimestampFilter end of date detected.\n" if ($debug > 1);
				last;
			}
		}
		
		if ($logline_date != int($logline_timestamp/86400)) {
			# Clear old data
			($day, $month, $year) = (gmtime($logline_timestamp)) [3,4,5];
			$month++;
			$year += 1900;
			print ">>> Clearing data for $year-$month-$day..." if ($debug > 0);
			$sql = "DELETE FROM stat_site WHERE Server_id=$squidus_server_id AND LogDate=DATE(FROM_UNIXTIME($logline_timestamp))";
			$dbh->do($sql) or die $dbh->errstr;
			print " done\n" if ($debug > 0);
			printlog "Clearing data for $year-$month-$day.";
			$logline_date = int($logline_timestamp/60/60/24);
		}
		$logline_user = ($logline[$logline_col_username] eq "-") ? $logline[$logline_col_userhost] : $logline[$logline_col_username];
		($logline_st_sq, $logline_st_http) = split("/", $logline[$logline_col_type]);
		if ($logline[$logline_col_method] eq "CONNECT" && $logline[$logline_col_url] !~ /^https:/i) {
			$logline_site = substr($logline[$logline_col_url], 0, index($logline[$logline_col_url], ':'));
		} else {
			if ($logline[$logline_col_url] =~ /.+ps?://///i) {
				$url = URI->new($logline[$logline_col_url]);
				$logline_site = $url->host;
			} else {
				if ($debug > 1) {
					print ">>>> skip unknown URL in line $linenum $logline[$logline_col_url]\n" ;
					printlog "Warning! skip unknown URL in line $linenum $logline[$logline_col_url]";
				}
				$debug_unknownurl++;
				next;
			}
		}
		$logline_size = $logline[$logline_col_size];

		#ToDo: check row with invalid record
		
		# Add row
		$sql = "INSERT INTO stat_site (Server_id, LogDate, UserName, StatusSquid, RequestSite, RequestBytes, RequestCount)
					VALUE ($squidus_server_id, DATE(FROM_UNIXTIME($logline_timestamp)), '$logline_user', '$logline_st_sq', '$logline_site', $logline_size, 1)
					ON DUPLICATE KEY UPDATE RequestCount=RequestCount+1, RequestBytes=RequestBytes+$logline_size";
		$dbh->do($sql) or die $dbh->errstr;
		
		$debug_parsed++;
	}
	close (ACCESSLOG);
}
printlog "Warning! $debug_unknownurl lines have unknown URL format" if ($debug_unknownurl > 0);
printlog ">>>> End parsing. (elapse " . ( time() - $^T ) . " sec)";

$dbh->commit;
$dbh->disconnect;

if ($debug > 0) {
	$worktime = ( time() - $^T );
	print "run TIME: $worktime sec\n";
	print "Squidus log parser statistic report\n\n";
	printf( "\t%10u lines processed\n",				 	$debug_loglines);
	printf( "\t%10u lines parsed\n",					$debug_parsed);
	printf( "\t%10u lines skiped by filters\n",	 		$debug_skipbyfilter);
	printf( "\t%10u lines have unknown URL format\n",	$debug_unknownurl);
}


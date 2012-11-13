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
	my $logpath		= "squidus.log";
	if (-d "/var/log/") {
		$logpath = "/var/log/squidus.log";
	}
	open (SQUIDUSLOG, ">>",  $logpath) or die ">>>> cannot open log file $!";
	printf SQUIDUSLOG "%04u-%02u-%02u %02u:%02u:%02u %s\n", $logtime[5]+1900, $logtime[4]+1, $logtime[3], $logtime[2], $logtime[1], $logtime[0], shift(@_);
	close (SQUIDUSLOG);
}

printlog ">>>> Start parsing.";

#Defaults
my $filter_date	= 0;
my $filter_gmt	= 0;
my $debug = 0;
my $file_log = "";
	#squid accsess log native format
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

my $file_conf	= "squidus.conf";
if (-d "/etc/") {
	$file_conf = "/etc/squidus.conf";
}

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
		if ($filter_gmt == 0) {
			$filter_date = timelocal( 0, 0, 0, (localtime())[3..5]);
			$filter_end  = timelocal( 59, 59, 23, (localtime())[3..5]);
		} else {
			$filter_date = int(time()/86400)*86400;
			$filter_end  = $filter_date + 86399;
		}
	}
	elsif ($ARGV[0] eq "yesterday") {
		if ($filter_gmt == 0) {
			$filter_date = timelocal( 0, 0, 0, (localtime(time()-86400))[3..5]);
			$filter_end  = timelocal( 59, 59, 23, (localtime(time()-86400))[3..5]);
		} else {
			$filter_date = (int(time()/86400)-1)*86400;
			$filter_end  = $filter_date + 86399;
		}
	}
	elsif ($ARGV[0] =~ m/^(\d\d\d\d)(\d\d)(\d\d)$/) {
		if ($filter_gmt == 0) {
			$filter_date = timelocal( 0, 0, 0, $3, $2-1, $1);
			$filter_end  = timelocal( 59, 59, 23, $3, $2-1, $1);
		} else {
			$filter_date = timegm( 0, 0, 0, $3, $2-1, $1);
			$filter_end  = $filter_date + 86399;
		}
	} else {
		print "Unknown parameter.\nusage: squidus-parser.pl [date]\n\ttoday\t\t- only current day\n\tyesterday\t- yesterday\n\tYYYYMMDD\t- parse day";
		printlog ">>>>Error! Unknown command line parameter.";
		exit;
	}
}

# Time zone offset
my $timeoffset =  0;
if ($filter_gmt == 0) {
	$timeoffset =  time();
	@ftime=localtime($timeoffset);
	$timeoffset =  timegm(@ftime) - $timeoffset;
	printlog sprintf("Time zone offset UTC%+d:%02u", int($timeoffset/3600), int(($timeoffset-int($timeoffset/3600)*3600)/60));
} else {
	printlog "Time in UTC";
}

if ($filter_date != 0) {
	my @ftime=gmtime($filter_date);
	printlog sprintf "Set date filter. [%04u-%02u-%02u / %u-%u]", $ftime[5]+1900, $ftime[4]+1, $ftime[3], $filter_date, $filter_end;
}

# Connect to database server and set transaction mode
$dbh = DBI->connect("DBI:$dbi_driver:database=$dbi_db_name;host=$dbi_hostname",
    $dbi_user, $dbi_password, {RaiseError => 1, AutoCommit => 0}) || die print "Can't connect";

# Clear temporary data
print "Clearing data for $sql_date..." if ($debug > 0);
printlog "Clearing temporary table.";
$sql = "DELETE FROM stat_site_tmp WHERE Server_id=$squidus_server_id";
$dbh->do($sql) or die $dbh->errstr;
$dbh->commit;
print " done\n" if ($debug > 0);

my $logline_end_day	= 0;
my $debug_filenum	= 0;
my $debug_loglines	= 0;
foreach $filename (@filelist) {
	$arch_proc = "";
	$arch_proc = "zcat" if ($filename =~ m/\.gz$/);
	$arch_proc = "bzcat" if ($filename =~ m/\.bz2$/);
	print ">>> read file $arch_proc $accesslogpath$filename\n" if ($debug > 0);
	printlog "Parsing file $arch_proc $accesslogpath$filename";
	if ((not -e "$accesslogpath$filename") and ($debug_filenum == 0) and ($filename ne $filelist[-1])){
		print ">>> oldest file $accesslogpath$filename do not exist\n" if ($debug > 0);
		printlog "Oldest file $accesslogpath$filename do not exist.";
		next;
	}
	if ($arch_proc ne "") {
		open ACCESSLOG, "$arch_proc $accesslogpath$filename |" || die "can't access log file $arch_proc $accesslogpath/$filename\n";
		$debug_filenum++;
	} else {
		open (ACCESSLOG, "<", "$accesslogpath$filename") or die "can't access log file\n";
		$debug_filenum++;
	}
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
				print "Timestamp filter - skiping lines...\n" if (($debug > 1) and ($linenum == 1));
				print "Timestamp filter - skip line $logline_timestamp\n" if ($debug > 8);
				$debug_skipbyfilter++;
				next;
			}
			if ($logline_timestamp > $filter_end) {
				print "Timestamp filter - end of date detected, stop working.\n" if ($debug > 1);
				last;
			}
		}
		
		if ($logline_end_day < $logline_timestamp) {		# New day
			($day, $month, $year) = ($filter_gmt == 0 ? (localtime($logline_timestamp)) [3,4,5] : (gmtime($logline_timestamp)) [3,4,5]);
			$month++;
			$year += 1900;
			$sql_date = "$year-$month-$day";
			# Clear old data
			print "Clearing data for $sql_date..." if ($debug > 0);
			printlog "Clearing data for $sql_date.";
			$sql = "DELETE FROM stat_site WHERE Server_id=$squidus_server_id AND LogDate='$sql_date'";
			$dbh->do($sql) or die $dbh->errstr;
			print " done\n" if ($debug > 0);
			$logline_end_day = ($filter_gmt == 0 ? timelocal(59, 59, 23, $day, $month-1, $year-1900) : timegm(59, 59, 23, $day, $month-1, $year-1900));
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
		#   - Site addres length
		
		# Add row
		$sql = "INSERT INTO stat_site_tmp (Server_id, LogDate, UserName, StatusSquid, RequestSite, RequestBytes, RequestCount)
					VALUE ($squidus_server_id, '$sql_date', '$logline_user', '$logline_st_sq', '$logline_site', $logline_size, 1)
					ON DUPLICATE KEY UPDATE RequestCount=RequestCount+1, RequestBytes=RequestBytes+$logline_size";
		$dbh->do($sql) or die $dbh->errstr;
		
		$debug_parsed++;
	}
	close (ACCESSLOG);
	last if (($filter_date != 0) and ($logline_timestamp > $filter_end));
}
printlog "Warning! $debug_unknownurl lines have unknown URL format" if ($debug_unknownurl > 0);
printlog ">>>> End parsing. (elapse " . ( time() - $^T ) . " sec)";

# Trasfer data from temporary table
#
# Add new domain names
print "SQL: Add new sites..." if ($debug > 0);
$sql = "INSERT INTO info_site (domain_name)
SELECT t1.RequestSite
FROM stat_site_tmp AS t1
	LEFT JOIN info_site AS t2 ON t1.RequestSite = t2.domain_name
WHERE t2.site_id IS NULL
GROUP BY t1.RequestSite
";
my $sql_rows = $dbh->do($sql) or die $dbh->errstr;
print " affected $sql_rows rows\n" if ($debug > 0);
printlog "Add new $sql_rows sites.";

# Add statistic data
print "SQL: Add statistic data..." if ($debug > 0);
$sql = "INSERT INTO stat_site (server_id, LogDate, UserName, RequestSite_id, RequestBytes, RequestCount)
SELECT t1.Server_id, t1.LogDate, t1.UserName, t2.site_id, SUM(t1.RequestBytes) AS RequestBytes, SUM(t1.RequestCount) AS RequestCount
FROM stat_site_tmp AS t1 
	LEFT JOIN info_site AS t2 ON t1.RequestSite = t2.domain_name
GROUP BY t1.Server_id, t1.LogDate, t1.UserName, t2.site_id
";
$sql_rows = $dbh->do($sql) or die $dbh->errstr;
print " affected $sql_rows rows\n" if ($debug > 0);
printlog "Add statistic data. ($sql_rows rows)";

# Clear temporary data
#print "Clearing data for $sql_date..." if ($debug > 0);
#printlog "Clearing temporary table.";
#$sql = "DELETE FROM stat_site_tmp WHERE Server_id=$squidus_server_id";
#$dbh->do($sql) or die $dbh->errstr;
#print " done\n" if ($debug > 0);


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


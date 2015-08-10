# File format #
The configuration file is simple text based file named `config.conf` and stored in directory with parser script.

Line format :
```
<parameter name> = <value> #Comments start with `#` and continue to the end of line.
```

# Database related parameters #
Now parser can work with MySQL servers only.

### dbs\_hostname ###
Database server host name or IP address.

**Default:** localhost

### dbs\_database ###
Database name.

**Default:** squidus

### dbs\_username ###
Database server user name.

**Default:** parser

### dbs\_userpass ###
Database server user password.

**Default:** no password

### dbs\_transaction ###
Enable (1) or disable (0) transactions in SQL queries.

**Default:** 0

# Access log file related parameters #
By default parser expect native Squid proxy access file format, but you can import Squid like file format.

To be sure in squid proxy access log format have right columns, you can redefine one in `squid.conf`:
```
logformat squid      %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %[un %Sh/%<a %mt
```

### proxy\_logfilelist ###
This parameter define log files chain for multifile operations. File list devidev comma or space and sorted in descending order.
Archived files gz and bz2 also allowed.

Exemple:
```
proxy_logfilelist = access.log, access.log.0.gz, access.log.1.bz2
or
proxy_logfilelist = access.log access.log.0.gz access.log.1.bz2
```

**Default:**
```
proxy_logfilelist = access.log
```

### proxy\_logfilepath ###
Diretory where stored access log files.

**Default:** empty

## Access log columns order ##
If You have access log file with not native fotmat, then You can redefine access log columns order.

**Default:**
```
logcol_datetime       = 0   # Curently only timestamp (seconds since epoch) format support
logcol_userhost       = 2
logcol_username       = 7
logcol_status         = 3   # [squid_flags]/[result_code]
logcol_requestmethod  = 5
logcol_requesturl     = 6
logcol_requestsize    = 4
```

# Squidus parameters #
### squidus\_proxyid ###
Proxy server ID in squidus proxy servers list.

**Default:** 1

### debug ###
Debug message level (0..10)

**Default:** 0
# Database functions for Binky    -*- perl -*-
#
# Copyright (C) 2002 - Binky development team
# Licensed under the GNU GPL software license.
# See the docs/LEGAL file for more information
# See http://binky.sourceforge.net/ for more information about Binky
#
# $Id$
#
# This will provide functions used to connect to, disconnect from, and
# manipulate the database a bit.

use strict;
use DBI;

my ($DBHandle);


# Reads the database connection information from the configuration
# file specified.
sub ReadConfig
{
    my (@FileNames) = @_;
    my (%Data, $Line, $FileName);

    foreach $FileName (@FileNames)
    {
        open(CONFIG_FILE, $FileName) || 
	    die "Can't read config file $FileName";
        while (! eof(CONFIG_FILE))
        {
            $Line = <CONFIG_FILE>;
  	    chomp($Line);
	    next if ($Line =~ /^#/);
            if ($Line =~ /^\s*([^ =]+)\s+=\s+(.*)\s*$/)
	    {
	        $Data{$1} = $2;
	    }
        }
	close(CONFIG_FILE);
    }
    return %Data;
}


# Initial connection to the database
sub DatabaseConnect {
   my ($ConfigFile) = @_;
   my (%CONFIG);
   
   %CONFIG = ReadConfig($ConfigFile);
   
   $DBHandle = DBI->connect($CONFIG{'DSN'}, $CONFIG{'USERNAME'}, 
      $CONFIG{'PASSWORD'});
}


# Utility function to get the handle anywhere.
sub DatabaseHandle {
   return $DBHandle;
}


# Loads the configuration value from the database
sub GetConfig {
   my ($Key) = @_;
   my ($dbh, $Value);
   
   $dbh = DatabaseHandle();
   $Value = $dbh->selectrow_array("SELECT config_value FROM config WHERE " .
      "config_key = " . $dbh->quote($Key));
   
   return $Value;
}
   

1;  # Must be the last line

#!/usr/bin/perl
#
# Web-based configuration for all of the database values
#
# Copyright (C) 2002 - Binky development team
# Licensed under the GNU GPL software license.
# See the docs/LEGAL file for more information
# See http://binky.sourceforge.net/ for more information about Binky
#
# $Id$
#
# Web-based configuration is designed to be easy to use.  Also, the
# values should automatically update the processes of any Binky
# dequeue engines running on any server that uses this database.

use strict;

my ($base_dir, $data_desc);

$base_dir = "..";

require "$base_dir/mods/read_cfg.pm";
require "$base_dir/mods/database.pm";

DatabaseConnect("$base_dir/config.cfg");


# Describe the data here.
$data_desc = {
   "DB_VERSION" => {
      "VALUE" => "1",
      "DESC" => "The version of the database currently running.",
      "INVALID_MESG" => "If the current database version is too large, " .
         "you need to upgrade the Binky scripts.  If the current " .
	 "database version is too small, you need to upgrade " .
	 "the database format.",
      "TYPE" => "FIXED",
   },
   "RUN_BINKY" => {
      "VALUE" => "[0|1]",
      "DESC" => "Should the dequeue engines be running?",
      "INVALID_MESG" => "This must be either 0 or 1.  Please pick " .
         "a new value from the form below.",
      "TYPE" => "SELECT",
      "DATA" => {
         "Enabled (1)" => 1,
	 "Disabled (0)" => 0,
      },
   },
}

# Check for invalids.
#   Verify each key and value with the value regex, as specified above.
#   Anything that is not described shouldn't be in the config table.


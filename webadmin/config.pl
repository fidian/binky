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
use CGI qw(:standard);

print header;

my ($base_dir, %data_desc, %CONFIG);

$base_dir = "..";

require "$base_dir/mods/database.pm";

DatabaseConnect("$base_dir/config.cfg");

# Describe the data here.
%data_desc = (
   "BINKY_ENABLED" => {
      "VALUE" => "[0|1]",
      "DESC" => "Should the dequeue engines be running?",
      "INVALID_MESG" => "This must be either 0 or 1.",
      "TYPE" => "SELECT",
      "DATA" => {
         "Enabled (1)" => 1,
	 "Disabled (0)" => 0,
      },
   },
   "DB_VERSION" => {
      "VALUE" => "1",
      "DESC" => "The version of the database currently running.",
      "INVALID_MESG" => "If the current database version is too large, " .
         "you need to upgrade the Binky scripts.  If the current " .
	 "database version is too small, you need to upgrade " .
	 "the database format.",
      "TYPE" => "FIXED",
   },
   "QUOTA_AMOUNT" => {
      "VALUE" => "[0-9]+",
      "DESC" => "How many kilobytes of data can the user download " .
         "within the QUOTA_PERIOD window?  Setting this to 0 will " .
	 "disable byte-related quotas.",
      "INVALID_MESG" => "This must be a positive number or zero.",
      "TYPE" => "NUMBER",
      "DEFAULT" => 0,
   },
   "QUOTA_PERIOD" => {
      "VALUE" => "[0-9]+",
      "DESC" => "Defines how big of a window is used for determining " .
         "if the user is over quota.  This setting is measured in " .
	 "days.  Setting this to 0 will disable byte-related quotas.",
      "INVALID_MESG" => "This must be a positive number.",
      "TYPE" => "NUMBER",
      "DEFAULT" => 14,
   },
);

print "<HTML><HEAD><TITLE>Configuration Variables</TITLE>
</HEAD>
<BODY BGCOLOR=\"#FFFFFF\">\n";

# Handle changes
if (param()) {
   HandleCGIPost();
}

# Grab all records from the config table
%CONFIG = GrabAllConfigVars();

print "<FORM METHOD=POST ACTION=config.pl>\n";

# Generate a hash for easy printing
my (%TableData, $key, $val, $isValid, $real, $bigKey);

%TableData = GenerateTableData(%data_desc);

foreach $key (sort(keys(%TableData))) {
   print "<h1>$key</h1>
<table border=1 cellpadding=2 cellspacing=0>
<tr bgcolor=#AFAFAF>
<th>Attribute</th>
<th>Current</th>
<th>Change To</th>
</tr>\n";
   foreach $val (sort(@{$TableData{$key}})) {
      $bigKey = $key . '_' . $val;
      $real = GetConfig($bigKey);
      if ($real =~ /^$data_desc{$bigKey}{'VALUE'}$/) {
         print "<tr>\n";
	 $isValid = 1;
      } else {
         print "<tr bgcolor=#FFAFAF>\n";
	 $isValid = 0;
      }
      print "<th align=left>$val</th>\n";
      print "<td align=center>$real";
      if (! $isValid) {
         print "<br><b><i>INVALID!</i></b>";
      }
      print "</td>\n";
      print "<td>";
      print GetInputBox($bigKey, $real, %{$data_desc{$bigKey}});
      print "</td>\n";
      print "</tr>\n";
      if (! $isValid) {
         print "<tr bgcolor=#FFAFAF>\n<Td colspan=3>" .
	    $data_desc{$bigKey}{'DESC'} . "<br><b>" .
	    $data_desc{$bigKey}{'INVALID_MESG'} . "</b></td>\n</tr>\n";
      } else {
         print "<tr bgcolor=#CFCFFF>\n<Td colspan=3>" .
            $data_desc{$bigKey}{'DESC'} . "</td>\n</tr>\n";
      }
      
      delete($CONFIG{$bigKey});
   }
   print "</table>\n";
   print "<br><input type=submit value=\"Commit Changes\">\n";
}

if (scalar(keys(%CONFIG))) {
   print "<h1>Invalid Entries</h1>
<table border=1 cellpadding=2 cellspacing=0>
<tr bgcolor=#AFAFAF>
<th>Attribute</th>
<th>Current</th>
<th>Delete?</th>
</tr>\n";

   foreach $key (sort(keys(%CONFIG))) {
      print "<tr>
<th align=left>$key</th>
<td align=center>" . $CONFIG{$key} . "</td>
<td align=center><input type=checkbox name=\"delete\" value=\"$key\"></td>
</tr>\n";
   }

   print "</table>\n";

   print "<br><input type=submit value=\"Commit Changes\">\n";
}

print "</FORM>
</BODY>
</HTML>\n";

# Check for invalids.
#   Verify each key and value with the value regex, as specified above.
#   Anything that is not described shouldn't be in the config table.


sub GrabAllConfigVars {
   my ($dbh, $sth, %CONFIG, $Result, $R);
   $dbh = DatabaseHandle();
   $sth = $dbh->prepare("SELECT config_key, config_value FROM config");
   $sth->execute();
   $Result = $sth->fetchall_arrayref();
   $sth->finish();
   foreach $R (@$Result) {
      $CONFIG{$$R[0]} = $$R[1];
   }
   return %CONFIG;
}

sub GenerateTableData {
   my (%data_desc) = @_;
   my ($key, @bits, %TableData);
   
   foreach $key (keys(%data_desc)) {
      @bits = split(/_/, $key);
      if (! defined($bits[1])) {
         die "Error with definition of configuration variable \"$key\"";
      }
      if (! defined($TableData{$bits[0]})) {
         $TableData{$bits[0]} = [$bits[1]];
      } else {
         push (@{$TableData{$bits[0]}}, $bits[1]);
      }
   }
   
   return %TableData;
}

   

sub HandleCGIPost {
   my ($dbh, $n, $key);
   
   $dbh = DatabaseHandle();
   
   foreach $n (param()) {
      if ($n =~ /_/) {
         if (GetConfig($n) ne param($n)) {
	    $dbh->do("DELETE FROM config WHERE config_key = " .
	       $dbh->quote($n));
	    $dbh->do("INSERT INTO config (config_key, config_value) " .
	       "VALUES (" . $dbh->quote($n) . ", " .
	       $dbh->quote(param($n)) . ")");
	    print "$n has been changed to " . param($n) . "<br>\n";
	 }
      } elsif ($n eq "delete") {
	 foreach $key (param($n)) {
	    $dbh->do("DELETE FROM config WHERE config_key = " .
	       $dbh->quote($key));
	    print "Extra variable $key has been deleted.<br>\n";
	 }
      }
   }
}


sub GetInputBox {
   my ($name, $real, %data) = @_;
   my ($str, $key, $found);
   
   $str = "Type " . $data{'TYPE'} . " is invalid!";
   
   if ($data{'TYPE'} eq 'FIXED') {
      # Unchangeable
      $str = "<b>$real</b> &nbsp; &nbsp; (Unchangeable)";
   } elsif ($data{'TYPE'} eq 'SELECT') {
      $found = 0;
      $str = "";
      foreach $key (keys(%{$data{'DATA'}})) {
         $str .= "<option value=\"" . $data{'DATA'}{$key} . "\"";
         if ($data{'DATA'}{$key} eq $real) {
	    $found = 1;
	    $str .= " SELECTED";
	 }
	 $str .= ">$key";
	 if ($found == 1) {
	    $found = 2;
	    $str .= " (Current Value)";
	 }
	 $str .= "</option>\n";
      }
      if (! $found) {
         $str = "<option value=\"$real\">$real (Current Value)" .
	    "</option>\n$str";
      }
      $str = "<select name=\"$name\">\n$str</select>\n";
   } elsif ($data{'TYPE'} eq 'NUMBER') {
      # Number field
      $str = "<input type=text name=$name size=20 value=\"$real\">";
   }
   
   return $str;
}
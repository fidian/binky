#!/usr/bin/perl
#
# Web-based configuration for all of the ads available to Binky
#
# Copyright (C) 2002 - Binky development team
# Licensed under the GNU GPL software license.
# See the docs/LEGAL file for more information
# See http://binky.sourceforge.net/ for more information about Binky
#
# $Id$
#
# Makes it easy for the admin to add tips or actual advertisements for the
# users of Binky to see.  In my experience, tips seem to go almost unnoticed,
# so it is likely that ads will be totally ignored.

use strict;
use CGI qw(:standard);

print header;

my ($base_dir, %ADS);

$base_dir = "..";

require "$base_dir/mods/database.pm";

DatabaseConnect("$base_dir/config.cfg");

print "<HTML><HEAD><TITLE>Ad Management</TITLE>
</HEAD>
<BODY BGCOLOR=\"#FFFFFF\">\n";

# Handle changes
if (defined(param('edit'))) {
   DoEdit(param('edit'));
   exit 0;
}

if (param('delete')) {
   DoDelete(param('delete'));
}

if (defined(param('save'))) {
   DoSave(param('save'), param('save_text'));
}

print "<p>[ <a href=\"ads.pl?edit=0\">Add New Ad</a> ]</p>\n";

# Grab all records from the ads table
%ADS = GrabAllAds();

if (scalar(keys(%ADS)) == 0) {
   print "<p>There are no ads currently defined.</p>\n";
} else {
   my ($ad);

   print "<table width=100% border=1 cellpadding=2 cellspacing=0>\n";
   foreach $ad (sort(keys(%ADS))) {
      print "<tr>\n<td bgcolor=#AFAFAF>";
      print "<a href=\"ads.pl?edit=$ad\">Edit</a><br>";
      print "Ad # <b>$ad</b><br>";
      print "<a href=\"ads.pl?delete=$ad\">Delete</a>";
      print "</td>\n";
      print "<td>";
      $_ = CGI::escapeHTML($ADS{$ad});
      s/\n/<br>/g;
      print;
      print "</td>\n</tr>\n";
   }
   print "</table>\n";
}

print "</BODY>
</HTML>\n";


sub GrabAllAds {
   my ($dbh, $sth, %ADS, $Result, $R);
   $dbh = DatabaseHandle();
   $sth = $dbh->prepare("SELECT id, message FROM ads");
   $sth->execute();
   $Result = $sth->fetchall_arrayref();
   $sth->finish();
   foreach $R (@$Result) {
      $ADS{$$R[0]} = $$R[1];
   }
   return %ADS;
}


sub DoEdit {
   my ($ad_id) = @_;
   my ($dbh, $CurrentText, $Title);
   
   if ($ad_id > 0) {
      $dbh = DatabaseHandle();
      $Title = "Edit Ad # $ad_id";
      $CurrentText = $dbh->selectrow_array("SELECT message FROM ads " .
         "WHERE id = " . $dbh->quote($ad_id));
   } else {
      $Title = "Add a New Ad";
      $CurrentText = "";
   }
   
   print "<h2>$Title</h2>\n";
   print "<form method=post action=ads.pl>\n";
   print "<input type=hidden name=save value=$ad_id>\n";
   print "<textarea name=save_text rows=5 cols=60>" .
      $CurrentText . "</textarea>\n";
   print "<br><input type=submit value=\"Save\"> - ";
   print "<a href=\"ads.pl\">Abort</a>\n";
   print "</form>\n";
   print "</body>\n</html>\n";
}


sub DoDelete{
   my (@id_list) = @_;
   my ($dbh, $key);
   
   $dbh = DatabaseHandle();
   foreach $key (@id_list) {
      $dbh->do("DELETE FROM ads WHERE id = " . $dbh->quote($key));
      print "Ad # " . CGI::escapeHTML($key) . " has been deleted.<br>\n";
   }
}


sub DoSave {
   my ($ad_id, $ad_text) = @_;
   my ($dbh);

   $dbh = DatabaseHandle();
   
   if ($ad_id > 0) {
      $dbh->do("UPDATE ads SET message = " . $dbh->quote($ad_text) .
         " WHERE id = " . $dbh->quote($ad_id));
      print "Changed ad # " . CGI::escapeHTML($ad_id) . ".<br>\n";
   } else {
      $dbh->do("INSERT INTO ads (id, message) values (0, " . 
         $dbh->quote($ad_text) . ")");
      print "Added new ad.<br>\n";
   }
}

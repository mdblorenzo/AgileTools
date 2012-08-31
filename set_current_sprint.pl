#!/usr/bin/perl -w
# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 2.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the AgileTools Bugzilla Extension.
#
# The Initial Developer of the Original Code is Pami Ketolainen
# Portions created by the Initial Developer are Copyright (C) 2012
# Jolla Ltd. All Rights Reserved.
#
# Contributor(s):
#   Pami Ketolainen <pami.ketolainen@jollamobile.com.com>
#
#
# Migration script to set the team current sprint.
#

use strict;
use warnings;
use lib qw(. lib);

use Bugzilla;
BEGIN { Bugzilla->extensions }

use Bugzilla::Extension::AgileTools::Constants;
use Bugzilla::Extension::AgileTools::Team;
use Bugzilla::Extension::AgileTools::Sprint;

use Data::Dumper;

my $dbh = Bugzilla->dbh;

my $teams = Bugzilla::Extension::AgileTools::Team->match(
    {process_id => AGILE_PROCESS_SCRUM});

my $now = Bugzilla->dbh->selectrow_array("SELECT NOW()");

for my $team (@$teams) {
    next if $team->current_sprint_id;
    my $sprint_id = $dbh->selectrow_array('SELECT id FROM agile_sprint '.
        'WHERE team_id = ? AND start_date <= ? '.
        'ORDER BY start_date DESC', undef, $team->id, $now);
    print $team->name." current sprint: ".$sprint_id."\n";
    $team->set_current_sprint_id($sprint_id) if ($sprint_id);
    $team->update();
}

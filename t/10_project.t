#!/usr/bin/perl -w
# $Id: 10_project.t 14 2007-04-03 15:30:08Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2001-2007 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use IO::File;
use strict;
use Test;

BEGIN { plan tests => 1 }
BEGIN { require "t/test_utils.pl"; }

use Dir::Project;
ok($Dir::Project::VERSION);

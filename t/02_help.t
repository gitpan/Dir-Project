#!/usr/bin/perl -w
# $Id: 02_help.t 49328 2008-01-07 16:28:25Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2007-2008 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License or the Perl Artistic License.

use strict;
use Test;

BEGIN { require "t/test_utils.pl"; }
my @execs = glob ("blib/script/[a-z]*");
plan tests => (3 * ($#execs+1));

# Make sure --help works without any setting of envvars
delete $ENV{DIRPROJECT_PREFIX};
delete $ENV{DIRPROJECT_PATH};

foreach my $exe (@execs) {
    print "Doc test of: $exe\n";
    my $pb = ($exe =~ /project_bin/ ? "project_bin-":"");

    ok (-e $exe);
    my $help = `$PERL $exe --${pb}help 2>&1`;
    ok ($help =~ /DISTRIBUTION/);
    $help = `$PERL $exe --${pb}version 2>&1`;
    ok ($help =~ /Version/);
}

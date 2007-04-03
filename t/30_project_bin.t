#!/usr/bin/perl -w
# $Id: 30_project_bin.t 14 2007-04-03 15:30:08Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2006-2007 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use IO::File;
use strict;
use Test;

BEGIN { plan tests => 2 }
BEGIN { require "t/test_utils.pl"; }

test_setup_area();

chdir 'test_dir';
{
    my $out = `${PERL} ../project_bin --project_bin-help 2>&1`;
    ok($out =~ /DESCRIPTION/);
}
{
    my $out = `${PERL} \$DIRPROJECT_PREFIX/bin/testprog arguments`;
    # This will execute 30_project_bin.pl
    ok($out =~ m!hello world!);
}

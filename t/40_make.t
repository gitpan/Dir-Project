#!/usr/bin/perl -w
# $Id: 40_make.t 14 2007-04-03 15:30:08Z wsnyder $
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
    my $out = `make -f ../t/40_make.mk default`;
    ok($out);
    ok($out =~ m!test_dir/checkout!);
}

#!/usr/bin/perl -w
# $Id: 40_make.t 18 2007-04-05 01:03:17Z wsnyder $
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

if (!$ENV{DIRPROJECT_AUTHOR_SITE}) {
    # Too unstable, and depends on specific version of
    # gnumake and Perl which messes up the automated CPAN testers.
    # Besides, using this in make is highly optional.
    skip("author only test (harmless)",1);
    skip("author only test (harmless)",1);
}
else {
    my $out = `make -f ../t/40_make.mk default`;
    ok($out);
    ok($out =~ m!test_dir/checkout!);
}


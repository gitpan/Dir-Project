#!/usr/bin/perl -w
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2006-2008 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use IO::File;
use strict;
use Test;

BEGIN { plan tests => 1 }
BEGIN { require "t/test_utils.pl"; }

test_setup_area();

chdir 'test_dir';
{
    my $out = `${PERL} ../project_dir --project`;
    ok($out =~ m!test_dir/checkout$!);
}

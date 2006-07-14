#!/usr/bin/perl -w
# $Id: 20_project_dir.t,v 1.1 2006/07/14 15:14:12 wsnyder Exp $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2006-2006 by Wilson Snyder.  This program is free software;
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

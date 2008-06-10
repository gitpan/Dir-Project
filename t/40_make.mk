#!/usr/bin/perl -w
# DESCRIPTION: Example makefile for project_dir.mk
#
# Copyright 2006-2008 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

include $(DIRPROJECT_PREFIX)/lib/project_dir.mk
default:
	@echo $(DIRPROJECT)

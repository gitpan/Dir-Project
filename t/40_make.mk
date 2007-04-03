#!/usr/bin/perl -w
# $Id: 40_make.mk 14 2007-04-03 15:30:08Z wsnyder $
# DESCRIPTION: Example makefile for project_dir.mk
#
# Copyright 2006-2007 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

include $(DIRPROJECT_PREFIX)/lib/project_dir.mk
default:
	@echo $(DIRPROJECT)

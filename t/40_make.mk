#!/usr/bin/perl -w
# $Id: 40_make.mk,v 1.1 2006/07/14 15:14:12 wsnyder Exp $
# DESCRIPTION: Example makefile for project_dir.mk
#
# Copyright 2006-2006 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

include $(DIRPROJECT_PREFIX)/lib/project_dir.mk
default:
	@echo $(DIRPROJECT)

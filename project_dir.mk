# DESCRIPTION: Dir::Project: Makefile include to define DIRPROJECT envvar
######################################################################
#
# Copyright 2001-2008 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
######################################################################

ifndef _DIRPROJECT_MK_
  _DIRPROJECT_MK_ = 1

  ifndef _DIRPROJECT_MKFILE_
     # first time, not called from a submake, so generate the variables
     # Call project bin, it will generate a include file and return the
     # filename.
     _DIRPROJECT_MKFILE_ := $(shell \
		$(DIRPROJECT_PREFIX)/bin/project_dir \
		--makefile)
     export _DIRPROJECT_MKFILE_
     # Include the file it requested
     include $(_DIRPROJECT_MKFILE_)
  endif

  # Remove this file at the end
  .INTERMEDIATE: $(_DIRPROJECT_MKFILE_)

endif

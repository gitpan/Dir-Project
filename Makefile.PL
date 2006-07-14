# $Id: Makefile.PL,v 1.3 2006/07/14 15:14:12 wsnyder Exp $
# DESCRIPTION: Perl ExtUtils: Type 'perl Makefile.PL' to create a Makefile for this package
#
# Copyright 2001-2006 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License or the Perl Artistic License.

require 5.005;
use ExtUtils::MakeMaker;
use Carp;

sub MY::postamble {
"
XDESTDIR = $ENV{DIRPROJECT_PREFIX}

install::
	cp project_dir.mk \$(XDESTDIR)/lib

DIST_DEFAULT += manifest

README: readme.texi
	-rm -rf \$@
	makeinfo \$< --output \$@ --no-headers --no-validate

## Maintainer use:
preexist:
	test ! -r \$(HOME)/src/kits/\$(DISTVNAME).tar.gz

tag:
	svnorcvs tag  \$(DISTNAME)_\$(VERSION_SYM)

maintainer-diff:
	svnorcvs diff \$(DISTNAME)_\$(VERSION_SYM) 

maintainer-dist: preexist dist tag
	cp \$(DISTVNAME).tar.gz \$(HOME)/src/kits
	mv \$(DISTVNAME).tar.gz \$(HOME)/backpack

maintainer-clean: distclean
	-rm -rf README

maintainer-copy: README

clean::
	-rm -rf test_dir
";
}

WriteMakefile(
	      DISTNAME  => 'Dir-Project',
	      NAME      => 'Dir::Project',
	      AUTHOR	=> 'Wilson Snyder <wsnyder@wsnyder.org>',
	      ABSTRACT  => 'Determine utility paths relative to version controlled directories',
	      VERSION_FROM => 'Project.pm',
	      EXE_FILES => ['project_dir', 'project_bin',],
	      INSTALLSCRIPT => "$ENV{DIRPROJECT_PREFIX}/bin",
	      PREREQ_PM => {'Pod::Text' => 0,
			},
	      'dist'    => {COMPRESS => 'gzip -9f',
			    SUFFIX   => '.gz', 
			    DIST_DEFAULT => 'README all tardist',
			},
	      );


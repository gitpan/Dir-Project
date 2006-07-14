# Dir::Project.pm -- Project's cvfs routine library
# $Id: Project.pm,v 1.8 2006/07/14 15:48:53 wsnyder Exp $
######################################################################
#
# Copyright 2001-2006 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
######################################################################

package Dir::Project;
require 5.005;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( $Project $HostDir );

use FindBin qw($RealBin);
use Carp;
use Cwd qw(abs_path getcwd);
use File::Basename;
use IO::File;
use IO::Handle;
use IO::Dir;
use Sys::Hostname;

use strict;
use vars qw($VERSION $Debug $Project %Env_Vars $Set_Defaults);

######################################################################
#### Configuration Section

$VERSION = '3.000';

# List of all environment variables we might generate
%Env_Vars = (
	     DIRPROJECT		=> \&_get_project,
	     );

# Set to 0 to suppress defaulting of variables
$Set_Defaults = 1 if (!defined $Set_Defaults);

######################################################################
#### Begin

######################################################################
######################################################################
######################################################################
#### User callable

sub default_script_dir {
    return "$ENV{DIRPROJECT_PREFIX}/bin";
}

sub get_set_project {
    get_set_all();
}
sub get_set_all {
    # This ordering matters
    {	# Compute temporary DIRPROJECT... We may end up changing the chip number,
	# which will cause DIRPROJECT to change.
	local $ENV{DIRPROJECT};
	_get_set("DIRPROJECT");
    }
    # Project may have changed, make sure by recomputing
    _get_set("DIRPROJECT");
    # DIRPROJECT now correct
    foreach (sort (keys %Env_Vars)) {
	print "$_ = $ENV{$_}\n" if $Debug && $Debug > 1;
    }
}

######################################################################
######################################################################
######################################################################
#### File utilities

sub simplify_dirnames {
    my $file = shift;
    return undef if !defined $file;
    #$file =~ s!^/nfs/remote/home!/home!;
    return $file;
}

sub program_paths {
    my %params = (#program =>		# Name of program without path
		  #default_exe =>	# Name of default program if not found
		  @_);
    $params{default_exe} ||= Dir::Project::default_script_dir()."/$params{program}__notfound";

    my @paths;
    if (defined $Project) {
	my $path = ($ENV{DIRPROJECT_PATH}||"");
	foreach my $ppath (split (':', $path)) {
	    my $try = $ppath."/".$params{program};
	    $try =~ s/^project/$Project/;
	    push @paths, $try;
	}
    }
    push @paths, $params{default_exe};
    
    return @paths;
}

sub program_bin {
    my %params = (paths=>[],		# From program_paths
		  @_);

    foreach my $ppath (@{$params{paths}}) {
	if (-r $ppath) {
	    return $ppath;
	}
    }
    return undef;
}

######################################################################
######################################################################
######################################################################
#### Makefile

sub makefile_path {
    return ($ENV{TEMP}||$ENV{TMP}||"/tmp")."/project_dir";
}

sub _makefile_lines {
    my $fh = shift;

    foreach (sort (keys %Env_Vars)) {
	my $val = $ENV{$_};
	$val = "%Error_".$_."_not_found" if (!defined $val);
	print $fh "$_ = $val\n";
    }
    print $fh "\n";
    foreach (sort (keys %Env_Vars)) {
	print $fh "export $_\n";
    }
}    

sub makefile {
    # Produce a makefile that will be included by project_bin.mk

    my $umask = umask();
    umask 0;

    get_set_all();

    my $makefile_path = makefile_path();
    mkdir $makefile_path, 0777;
    _makefile_clean();
    my $filename = "${makefile_path}/mktmp_$$";
    my $fh = IO::File->new ($filename, ">", 0666) or die "%Error: $! $filename\n";

    print $fh "DIRPROJECT_MK_FILENAME = $filename\n";
    _makefile_lines ($fh);
    $fh->close();

    # Tell make to include this file
    print "$filename\n";

    umask $umask;
}

sub makefile_cat {
    get_set_all();
    my $fh = new IO::Handle;
    $fh->fdopen(fileno(STDOUT),"w");
    _makefile_lines ($fh);
}

sub undefine_all {
    foreach (keys %Env_Vars) {
	delete $ENV{$_};
    }
}

sub _makefile_clean {
    # See if we can clean up our clutter
    my $clean_age = 600;	# Seconds of time to leave them around

    my $now = time();

    my $makefile_path = makefile_path();
    my $dir = new IO::Dir $makefile_path or return;
    my $basefile;
    while (defined($basefile = $dir->read)) {
	my $file = "$makefile_path/$basefile";
	next if ($file eq "." || $file eq "..");
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime)
	    = stat($file);
	if (($atime-$now) > $clean_age) {
	    #print "Cleaning tmp $file $atime $now ", $now - $atime, "\n" if $Debug;
	    unlink $file;
	}
    }
}

######################################################################
######################################################################
######################################################################
#### Setting each of the variables

sub _get {
    my $envvar = shift;
    # Get the value for what would be the given environment variable
    # without setting the environment at all
    my $func = $Env_Vars{$envvar} or die "%Error: $envvar is unknown in Env_Vars";
    my $value = &{$func};
    return $value;
}

sub _get_set {
    my $envvar = shift;
    # Get the value for the given environment variable
    # and set it
    my $value = _get($envvar);
    #print "_get_set($envvar) = $value\n" if $Debug;
    if (defined $value) {
	$ENV{$envvar} = $value;
    } else {
	delete $ENV{$envvar};
    }
}

sub _get_project {
    # Get the workarea/project pointer and set the DIRPROJECT environment variable
    $Project = _get_root ("DIRPROJECT", 'project', undef);
    return $Project;
}

sub _get_proj_dir {
    my $dirname = shift;

    my $value = undef;
    if ($ENV{DIRPROJECT} && -r "$ENV{DIRPROJECT}/$dirname") {
	$value = "$ENV{DIRPROJECT}/$dirname";
    }
    return $value
}

######################################################################
######################################################################
######################################################################
#### Internals

sub _get_root {
    my $envvar = shift;		# if $ENV{envvar}...
    my $linkfile = shift;	# if readlink $linkfile...
    my $default = shift;
    # 

    my $value = undef;
    my $comment = "undef";
  search:
    while (1) {
	if (defined $ENV{$envvar}) {
	    $value = _resolve ($ENV{$envvar});
	    $comment = "set from environment $ENV{$envvar}";
	    last search;
	}

	# Look for magic under cwd
	my $cwd = getcwd();
	print "_get_root: PWD=$cwd\n" if $Debug && $envvar eq "DIRPROJECT";
	my $dir = $cwd."/.";
	while ($dir =~ s/^(.*)\/.*$/$1/) {
	    last if $dir =~ m!/homes?/?$!;   # Else automounter goes berserk
	    if (-r "$dir/Project_Root") {
		$value = $dir;
		$comment = "set from Project_Root under cwd";
		last search;
	    }
	    if (-r "$dir/$linkfile" && readlink "$dir/$linkfile") {
		$value = _resolve ("$dir/$linkfile");
		$comment = "set from $dir/$linkfile link under cwd";
		last search;
	    }
	}

	# Look for magic under binary directory
	$cwd = $RealBin;
	print "_get_root: BINDIR=$cwd\n" if $Debug && $envvar eq "DIRPROJECT";
	$dir = $cwd."/.";
	while ($dir =~ s/^(.*)\/.*$/$1/) {
	    last if $dir =~ m!/homes?/?$!;   # Else automounter goes bezerk
	    if (-r "$dir/Project_Root") {
		$value = $dir;
		$comment = "set from Project_Root under bin dir";
		last search;
	    }
	    if (-r "$dir/$linkfile" && readlink "$dir/$linkfile") {
		$value = _resolve ("$dir/$linkfile");
		$comment = "set from $dir/$linkfile link under bin dir";
		last search;
	    }
	}

	if (defined $default) {
	    $value = $default;
	    $comment = "default";
	    last search;
	}

	last;
    }

    $value = simplify_dirnames($value);

    print "_get_root: $envvar=",$value||'undef',"; $comment\n" if $Debug;
    return ($value);
}

sub _resolve {
    # Rip apart any links in the path
    my $file = shift;

    $file = abs_path($file);
    if ($file =~ m!^/sim!) {
	my $hostname = hostname();
	$file =~ s!/sim!/nfs/$hostname/sim!;
    }
    return $file if ($file =~ /^\//);
    if (readlink $file) {
	$file = readlink $file;
	$file = _resolve($file);
    }
    return $file;
}

######################################################################
######################################################################
######################################################################
#### Package return
1;

__END__

=pod

=head1 NAME

Dir::Project - Project Environment determination

=head1 SYNOPSIS

  use Dir::Project;
  Dir::Project::get_set_all();

=head1 DESCRIPTION

L<Dir::Project> provides a way to locate a source-controlled directory
(CVS, Subversion, Perforce, etc) using only the current working directory
(cd).  This prevents users from having to set other environment variables
when they switch between areas, and allows scripts and such inside the
directory to be executed without changing the user's PATH.

=over 4

=item get_set_all()

Set all variables, including get_set_project.

=item get_set_project()

Set $Project and $ENV{DIRPROJECT}.

=item makefile()

Create a makefile with the appropriate L<make> code to set DIRPROJECT.
This file is then included by make to set the variable.

=item makefile_cat()

Print the makefile with the appropriate L<make> code to set DIRPROJECT.

=item program_paths(program=>I<name>)

Return a list of paths the program may live at.  Uses $DIRPROJECT_PATH and
$DIRPROJECT_PREFIX resolved with the current project to determine the list.

=item program_bin(paths=>\I<@list>)

Return the first readable file in the list of paths, or undef if none found.

=item undefine_all()

Remove all environment variables.

=back

=head1 USAGE IN SCRIPTS

L<Dir::Project> may be used three different ways inside scripts.

First, a script may be totally ignorant of Dir::Project.  Simply by placing
it in a directory that is part of DIRPROJECT_PATH, and creating a symlink
from project_bin, it will be executed automatically based on the cwd.

Second, a script that is always executed by project_bin can get the root of
the checkout by using $DIRPROJECT.  Generally I cache the value of DIRPROJECT
in a variable called simply $Project.

    BEGIN {
        $Project = $ENV{DIRPROJECT} or die "%Error: Can't determine DIRPROJECT: Call me with project_bin, stopped";
    }
    ....
    my $path_to_file = "$Project/under/project/file/path...";

Third, a script may determine DIRPROJECT itself by using Dir::Project directly.
This does not require project_bin to be used to call the program.

    use Dir::Project;
    BEGIN {
        Dir::Project::get_set_project(); 
        $Project = $ENV{DIRPROJECT} or die "%Error: Can't determine PROJECT: Call me with project_bin, stopped";
    }
    ....
    my $path_to_file = "$Project/under/project/file/path...";

=head1 USAGE IN MAKEFILES

L<Dir::Project> may be called from inside a Makefile.  The include will set
the DIRPROJECT variable that can then be used to replace absolute paths
inside the makefile.

    include $(DIRPROJECT_PREFIX)/lib/project_dir.mk
    ....
    PATHS = $(DIRPROJECT)/...

=head1 ENVIRONMENT

=over 4

=item DIRPROJECT

Points to the top directory of the project source-controlled area.  It is
created by Dir::Project::get_set_all.

=item DIRPROJECT_DEBUG

Set when project_bin is invoked with --debug.

=item DIRPROJECT_PATH

A colon-separated list of directories that program_paths() and
L<project_bin> should search for executables within.  Generally contains a
leading project/ in front of all directories, this will be converted to
$DIRPROJECT.  Set by the user's .bashrc or similar login script

=item DIRPROJECT_PREFIX

A global directory like the --prefix passed to most configure scripts.
Used by program_paths() and L<project_bin> to create the default
$DIRPROJECT_PREFIX/bin/{program}__not_found link.  Set by the user's
.bashrc or similar login script

=item DIRPROJECT_EXE

The last executable run by L<project_bin>.  Set by L<project_bin>.

=back

=head1 DISTRIBUTION

Dir-Project is part of the L<http://www.veripool.com/> free EDA software
tool suite.  The latest version is available from CPAN and from
L<http://www.veripool.com/>.

Copyright 2001-2006 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<project_bin>, L<project_dir>, 

=cut

######################################################################

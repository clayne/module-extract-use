#!/usr/bin/perl

use strict;
use warnings;

use Pod::Usage;

=head1 NAME

extractuse - determine what Perl modules are used in a given file

=head1 VERSION

Version 1.1

=cut

use version; our $VERSION = qv('1.0');

=head1 SYNOPSIS

Use: extractuse filename [...]

Given filenames, extract and report the Perl modules included 
with C<use> or C<require>.

=head1 DESCRIPTION

This script does not execute the code in the files it examines. It
uses the C<Module::Extract::Use> or C<Module::ExtractUse> modules
which statically analyze the source without compiling or running it.
These modules cannot discover modules loaded dynamically through a a
string eval.


=cut

# if no parameters are passed, give usage information
unless( @ARGV ) 
	{
	pod2usage( msg => 'Please supply at least one filename to analyze' );
	exit;
	}

my( $object, $method );
my @classes = qw( Module::Extract::Use Module::ExtractUse );
my %methods = qw(
	Module::Extract::Use get_modules
	Module::ExtractUse   extract_use
	);
	
foreach my $module ( @classes )
	{
	eval "require $module";
	next if $@;
	( $object, $method ) = ( $module->new, $methods{$module} );
	}	

die "No usable file scanner module found; exiting...\n" unless defined $object;


foreach my $file ( @ARGV ) 
	{
	unless ( -r $file ) 
		{
		printf STDERR "Failed to open file '$file' for reading\n";
		next;
		}

	dump_list( $file, sort $object->$method( $file ) );
	}
	

BEGIN {
my $corelist = eval { require Module::CoreList };

sub dump_list 
	{
	my( $file, @modules ) = @_;

	printf "Modules required by %s:\n", $file;

	my( $core, $extern ) = ( 0, 0 );

	foreach my $module ( @modules ) 
		{
		printf " - $module%s\n",
				$corelist
					?
					do {
						my $v = Module::CoreList->first_release( $module );
						$core++ if $v;
						$v ? " (first released with Perl $v)" : '';
						}
					:
					do { $extern++; '' }
		}

	printf "%d module(s) in core, %d external module(s)\n\n", $core, $extern;
	}
	
}

=head1 AUTHORS

Jonathan Yu C<< <frequency@cpan.org> >>

brian d foy C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 by Jonathan Yu <frequency@cpan.org>

You can use this script under the same terms as Perl itself.

=head1 SEE ALSO

L<Module::Extract::Use>,
L<Module::ExtractUse>,
L<Module::ScanDeps>,

=cut

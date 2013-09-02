package Dependencies::Searcher;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Data::Printer;
use feature qw(say);
use Module::CoreList qw();
use autodie;
use Moose;

# Use these modules throught a system call
require Module::Version;
require App::Ack;


=head1 NAME

Dependencies::Searcher - Search recursively dependencies used in a module's 
directory and build a report that can be used as a Carton cpanfile.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Maybe you don't want to have to list all the dependencies of your application by hand,
or maybe you forgot to do it for a long time ago. During this time, you've add lots of
CPAN modules. Carton is here to help you manage dependencies between your development 
environment and production, but how to keep track of the list of modules you will give
to Carton?

You will need a tool that will check for any 'requires' or 'use' in your module package, 
and report it into a file that could be used as a Carton cpanfile. Any duplicated entry 
will be removed and versions are available. 

This project has begun because it happens to me, and I don't want to search for modules
 to install, I just want to run a simple script that update the list in a simple way.

Perhaps a little code snippet.

    use Dependencies::Searcher;

    my $foo = Dependencies::Searcher->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

# Init
my $use_pattern = "^use ";
my $requires_pattern = "^requires ";
# BUG : this is not generic
my $path = "./lib/Shurf.pm ./lib/Shurf/ ./script ./Makefile.PL";

# Only pm files
# No filename
# Ignore case
my $parameters = "--perl -hi";

my @uses = `ack $parameters $use_pattern $path`;
my @requires = `ack $parameters $requires_pattern $path`;
my @merged_dependancies = (@uses, @requires);

sub get_uses {
    my $self = shift;
    my @uses = `ack $parameters $use_pattern $path`;
    if (!$uses[0]) {
	return @uses;
    } else {
	warn "Failed to retrieve uses with Ack";
    }
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

smonff, C<< <smonff at gmail.com> >>

=head1 BUGS

Bugtracker : https://github.com/smonff/dependencies-searcher/issues

Please report any bugs or feature requests to C<bug-dependencies-searcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dependencies-Searcher>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

  * BUG non generic path
  * BUG remove qw()

=head1 TODOs

  * Test if Ack L<http://beyondgrep.com> is installed
  * Add "our $VERSION = '0.03';" to all Shurf::Wax modules"
  * Compare how many modules are found at the beginning of the process
    and at the end. If it's different, it's bad...
  * Modularize and use functions
  * Should mention version of the installed module
  * Output the script non-core-modules to Carton's cpanfile
  * Search for lines containings "require" => ok
  * test if modules are Core modules (don't need to install it then) => OK

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dependencies::Searcher


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dependencies-Searcher>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dependencies-Searcher>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dependencies-Searcher>

=item * Search CPAN

L<http://search.cpan.org/dist/Dependencies-Searcher/>

=back


=head1 ACKNOWLEDGEMENTS

=over

=item * Brian D. Foy's Module::Extract::Use

Was the main inspiration for this one. First, I want to use it for my needs
but is was not recursive...

See L<https://metacpan.org/module/Module::Extract::Use>

=item * Module::CoreList

What modules shipped with versions of perl. I use it extensively to detect
if the module is from Perl Core or not.

See L<http://perldoc.perl.org/Module/CoreList.html>

=item * Andy Lester's Ack

Use it as the main source for the module. It was pure Perl so I've choose 
it, even if Ack is not meant for being used programatically, this use do the
job.

See L<http://beyondgrep.com/>

See also
   https://metacpan.org/module/Perl::PrereqScanner
   http://stackoverflow.com/questions/17771725/

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 smonff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Dependencies::Searcher

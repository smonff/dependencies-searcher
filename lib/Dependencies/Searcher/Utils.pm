package Dependencies::Searcher::Utils;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Data::Printer;
use feature qw(say);
use Module::CoreList qw();
use autodie;
use Moose;

=head1 NAME

Dependencies::Searcher::Utils - Provides main treatments for Dependancies::Searcher

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Perhaps a little code snippet.

    use Dependencies::Searcher;

    my $foo = Dependencies::Searcher->new();
    ...


=head1 SUBROUTINES/METHODS

=head2 get_modules()

=cut

=head2 get_files()

=cut

sub get_modules {
    my $self = shift;
    # say $self;
    # p @_;
    my ($params, $patrn, $p) = @_;
    my $request = "$params $patrn $p";
    # p $request;
    my @moduls = `ack $request`;


    if ( defined $moduls[0]) {
	if ($moduls[0] =~ m/^use/ or $moduls[0] =~ m/^require/) {
	    return @moduls;
	} else {
	    die "Failed to retrieve modules with Ack";
	}
    } else {
	say "No $patrn found !";
    }
}

sub get_files {
    my $self = shift;
    my @structure;
    $structure[0] = "";
    $structure[1] = "";
    $structure[2] = "";
    if (-d "lib") {
	$structure[0] = "lib";
    } else {
	die "Don't look like we are working on a Perl module";
    }

    if (-f "Makefile.PL") {
	$structure[1] = "Makefile.PL";
    }

    if (-d "script") {
	$structure[2] = "script";
    }
    # p @structure;
    return @structure;
}

=head1 AUTHOR

smonff, C<< <smonff at gmail.com> >>

=head1 BUGS

See dstribution main module

Bugtracker : https://github.com/smonff/dependencies-searcher/issues

Please report any bugs or feature requests to C<bug-dependencies-searcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dependencies-Searcher>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dependencies::Searcher

=head1 LICENSE AND COPYRIGHT

Copyright 2013 smonff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Dependencies::Searcher

package Dependencies::Searcher::AckRequester;

use 5.010;
use Data::Printer;
use feature qw(say);
use Module::CoreList qw();
use autodie;
use Moose;
use IPC::Cmd qw[can_run run];

# These modules will be used throught a system call
# Module::Version;
# App::Ack;

our $VERSION = '0.05_02';
has 'full_path' => (
  is  => 'rw',
  isa => 'Str',
);

sub get_path {
    my $self = shift;

    my $tmp_full_path = can_run('ack') or warn 'Ack is not installed!';
    $self->full_path($tmp_full_path);
    # p $self->full_path;

  return $self->full_path;

}

sub build_cmd {

    my ($self, @params) = @_;

    my @cmd = ($self->full_path, @params);
    my $cmd_href = \@cmd;

    # p $cmd_href;

    return $cmd_href;
}

# This is VERY DIRTY AND BAD stuff
# Have to to it in a better way...
# Maybe use IPC::System::Simple
sub ack {

    my ($self, $cmd) = @_;

    p $cmd;

    # Here get the current dirctory
    #my $distrib_path = cwd();

    my $distrib_path = `pwd`;
    #p $distrib_path;
    #p $distrib_path;

    my($success, $error_message, $full_buffer, $stdout_buffer, $stderr_buffer) = run( command => $cmd, verbose => 0 );

    my $cmd2 = ['pwd'];

    my($success2, $error_message2, $full_buffer2, $stdout_buffer2, $stderr_buffer2) = run( 
	command => $cmd2,
	verbose => 0
    );

    p $full_buffer2;
    p $full_buffer2;

    my @modules;

    # p @$stdout_buffer;
    if ($success) {

	push @modules, split(/\n/m, $$full_buffer[0]);
    } else {
	die "IPC::Cmd failed with error $error_message";
    }

    p @modules;
    return @modules;
}

=head1 NAME

Dependencies::Searcher::AckRequester - Helps DependenciesSearcher to use Ack

=cut

=head1 SYNOPSIS

    # A nice code example

=head1 SUBROUTINES/METHODS

This is work in progress...

=head2 get_path()

Returns the Ack full path if installed. It will be used by ICP::Cmd.

=cut

=head2 ack

Returns an array of potentially interesting lines, containing dependencies names 

=cut

=head1 AUTHOR

smonff, C<< <smonff at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dependencies-searcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dependencies-Searcher>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 TODOs

=head1 ACKNOWLEDGEMENTS

=over

=item * Andy Lester's Ack

I've use it as the main source for the module. It was pure Perl so I've choose 
it, even if Ack is not meant for being used programatically, this use do the
job.

See L<http://beyondgrep.com/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 smonff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;

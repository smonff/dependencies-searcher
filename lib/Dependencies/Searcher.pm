package Dependencies::Searcher;

use 5.010;
use Data::Printer;
use feature qw(say);
use Module::CoreList qw();
use autodie;
use Moose;

# Use these modules throught a system call
# requires Module::Version;
# requires App::Ack;


=head1 NAME

Dependencies::Searcher - Search recursively dependencies used in a module's 
directory and build a report that can be used as a Carton cpanfile.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';


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


=head1 SUBROUTINES/METHODS

=head2 function1

=cut

=head2 function2

=cut

# Init parameters
has 'use_pattern' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'requires_pattern' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'parameters' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'non_core_modules' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    handles    => {
	add_non_core_module    => 'push',
	count_non_core_modules => 'count',
    },
);

has 'core_modules' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default => sub { [] },
    handles    => {
	add_core_module    => 'push',
	count_core_modules => 'count',
    },
);

# TODO with test  impl !!!!
# my @requires = $util->get_modules($self->parameters, $self->requires_pattern, $self->path);

# Use Ack to get modules and store lines into arrays
sub get_modules {
    my ($self, $path, $flag) = @_;

    my $request = "";

    if ($flag eq "use") {
	$request = $self->parameters . " " . $self->use_pattern . " " . $path;
    } elsif ($flag eq "require") {
	$request = $self->parameters . " " . $self->requires_pattern . " " . $path;
    } else {
	die "Pattern flag is required : use or require"
    }

    my @moduls = `ack $request`;

    if ( defined $moduls[0]) {
	if ($moduls[0] =~ m/^use/ or $moduls[0] =~ m/^require/) {
	    return @moduls;
	} else {
	    die "Failed to retrieve modules with Ack";
	}
    } else {
	say "No $self->pattern found !";
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
    return @structure;
}

# Retrieve names of :
#  * lib/ directory, if it don't exist, we don't care and die
#  * Makefile.PL
#  * script/ directory, if we use a Catalyst application
# ... only if they exists !
sub build_full_path {
    my ($self, @elements) = @_;
    my $path = "";
    foreach my $element ( @elements ) {
	$path .= " ./" .  $element;
    }

    # Remove endings " ./"
    $path =~ s/\s\.\/$//;
    return $path;
}

sub merge_dependencies {
    my ($self, @uses, @requires) = @_;
    my @merged_dependencies = (@uses, @requires);
    return @merged_dependencies;
}

# Remove special cases
sub make_it_real {
    my ($self, @merged) = @_;
    my @real_modules;
    foreach my $module ( @merged ) {
	push(@real_modules, $module) unless

	$module =~ m/say/
	# Contains qw()
	or $module =~ m/qw\(\)/
	# Describes a minimal Perl version
	or $module =~ m/^use\s[0-9]\.[0-9]+?/
	or $module =~ m/^use\sautodie?/
	or $module =~ m/^use\sautodie?/;
    }
    return @real_modules;
}

# Remove everything but the module name
# Remove dirt, clean...
sub clean_everything {
    my @clean_modules = ();
    my ($self, @dirty_modules) = @_;
    foreach my $module ( @dirty_modules ) {

	# remove the 'use' and the space next
	$module =~ s/use\s//i;

	# remove the 'require', quotes and the space next
	# but returns the captured module name (non-greedy)
	$module =~ s/requires\s'(.*?)'/$1/i;
	                                  # i = not case-sensitive
	# Remove the ';' at the end of the line
	$module =~ s/;//i;

	# Remove any qw(xxxx)
	# BUG, should remove spaces
	$module =~ s/\sqw\([A-Za-z]+\)//i;

	# Remove dirty bases and quotes.
	# This regex that substitute My::Module::Name
	# to a "base 'My::Module::Name'" by capturing
	# the name in a non-greedy way
	$module =~ s/base\s'(.*?)'/$1/i;

	# Remove some warning sugar
	$module =~ s/([a-z]+)\sFATAL\s=>\s'all'/$1/i;

	push @clean_modules, $module;
    }
    return @clean_modules;
}

# Make each array element uniq
sub uniq {
    my ($self, @many_modules) = @_;
    my @unique_modules = ();
    my %seen = ();
    foreach my $element ( @many_modules ) {
	next if $seen{ $element }++;
	push @unique_modules, $element;
    }
    return @unique_modules;
}

# Dissociate core / non-core modules
sub dissociate {
    my ($self, @common_modules) = @_;

    foreach my $nc_module (@common_modules) {

	my $core_list_answer = `corelist $nc_module`;
	# print "Found " . $nc_module;
	if (
	    (exists $Module::CoreList::version{ $] }{"$nc_module"})
	    or
	    ($core_list_answer =~ m/released/)
	) {
	    # Add to core_module

	    # The old way
	    # You have to push to an array ref (Moose)
	    # http://www.perlmonks.org/?node_id=695034
	    # push @{ $self->core_modules }, $nc_module;

	    # The "Moose" trait way
	    $self->add_core_module($nc_module);

	} else {
	    $self->add_non_core_module($nc_module);
	    # push @{ $self->non_core_modules }, $nc_module;
	}
    }
    # p $self->non_core_modules;
    # p $self->core_modules;
}


=head1 AUTHOR

smonff, C<< <smonff at gmail.com> >>

=head1 BUGS

Bugtracker : https://github.com/smonff/dependencies-searcher/issues

Please report any bugs or feature requests to C<bug-dependencies-searcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dependencies-Searcher>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

  * BUG non generic path
  * BUG remove qw() and spaces

=head1 TODOs

  * Transfer script to module
  * Add dependencies to Makefile.PL => OK
  * Manage case when documentation line starts with "use" 
  * Must be implemented from a script that use this module. The module itself
    must stay generic => OK
  * Tests => OK
  * Test if Ack L<http://beyondgrep.com> is installed =>  OK
  * Compare how many modules are found at the beginning of the process
    and at the end. If it's different, it's bad...
  * Modularize and use functions => OK
  * Should mention version of the installed module => OK
  * Output the script non-core-modules to Carton's cpanfile => OK
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

I've use it as the main source for the module. It was pure Perl so I've choose 
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

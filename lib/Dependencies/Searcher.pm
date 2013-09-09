package Dependencies::Searcher;

use 5.010;
use Data::Printer;
use feature qw(say);
use Module::CoreList qw();
use autodie;
use Moose;

# These modules will be used throught a system call
# Module::Version;
# App::Ack;

our $VERSION = '0.03_01';



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
}

# Open a file handle to > cpanfile
sub generate_report {

    my $self = shift;

    open my $cpanfile_fh, '>', 'cpanfile';

    foreach my $module_name ( @{$self->non_core_modules} ) {

	# From Module::Version command line utility
	my $version = `mversion $module_name`;

	# Add the "requires $module_name\n" to the next line of the file
	chomp($module_name, $version);

	if ($version =~ m/[0-9]\.[0-9]+/ ) {
	    say $cpanfile_fh "requires " . $module_name . ", " . $version;
	} else {
	    say $cpanfile_fh "requires " . $module_name;
	}

    }
    close $cpanfile_fh;
}

=head1 NAME

Dependencies::Searcher - Search recursively dependencies used in a module's 
directory and build a report that can be used as a Carton cpanfile.

=cut

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

    use Dependencies::Searcher;

    my $searcher = Dependencies::Searcher->new();
    my @elements = $searcher->get_files();
    my $path = $searcher->build_full_path(@elements);
    my @uses = $searcher->get_modules($path, "use");		
    my @uniq_modules = $searcher->uniq(@uses);

    $searcher->dissociate(@uniq_modules);

    $searcher->generate_report($searcher->non_core_modules);

=head1 SUBROUTINES/METHODS

This is work in progress...

=head2 get_modules

Us-e Ack to get modules and store lines into arrays

=cut

=head2 get_files

=cut

=head2 build_full_path

Retrieve names of :
 * lib/ directory, if it don't exist, we don't care and die
 * Makefile.PL
 * script/ directory, if we use a Catalyst application
 * ... only if they exists !

=cut

=head2 merge_dependencies 

Merge use and requires

=cut

=head2 make_it_real

Remove special cases that can't be interesting.

=cut

=head2 clean_everything

Remove everything but the module name. Remove dirt, clean stuffs...

=cut

=head2 uniq

Make each array element uniq

=cut

=head2 dissociate

Dissociate core / non-core modules

=cut

=head2 generate_report

Generate the cpanfile for Carton, with optionnal version number

=cut

=head2

=cut

=head2

=cut

=head1 AUTHOR

smonff, C<< <smonff at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dependencies-searcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dependencies-Searcher>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 TODOs

https://github.com/smonff/dependencies-searcher/issues

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

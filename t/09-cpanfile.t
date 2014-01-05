use strict;
use warnings;
use Test::More 'no_plan';
use Dependencies::Searcher;
use IO::File;
use Path::Class;

my $searcher = Dependencies::Searcher->new();

my @non_core_modules = (
    "Data::Printer",
    "Module::CoreList",
    "Module::Version",
    "Moose",
    "Log::Minimal",
    "File::Stamped",
    "File::HomeDir",
    "File::Spec::Functions",
    "Version::Compare",
    "IPC::Run",
    "ExtUtils::MakeMaker",
    "Path::Class",
);

my @bug = (
    "This::Is::Crap",
    "And::This::Is::Too",
    "Because::We::Love::Tests",
    "Even::When::It:Is::Stupid",
);

my @bugged_non_core_modules = (@non_core_modules, @bug);

$searcher->dissociate(@non_core_modules);
$searcher->generate_report();

my $cpanfile = file('cpanfile'); # Should check possible errors
if (not defined $cpanfile) {
    die "Can't open cpanfile";
} else {
    my @lines = $cpanfile->slurp;

    # For some reason, the array comparison through the 2 arrays in
    # scalar context don't work on some cpantesters reports.
    # That's maybe because the ok(xx, ,xx , xx) is a list context ???
    # http://www.perlmonks.org/?node_id=296455
    # See issue #39
    my $lines_number   = @lines;
    my $modules_number = @non_core_modules;
    my $bugged_modules_number = @bugged_non_core_modules;

    cmp_ok($modules_number, '!=', $bugged_modules_number,
       "The 2 arrays should not contain same number of elements");

    cmp_ok($modules_number, '==', $lines_number, 'modules number is the same than cpanfile lines' );

    cmp_ok($bugged_modules_number, '!=', $lines_number, 'modules =! cpanfile lines');

}

# More stuff to test

# only one space between require and name, etc
# same number of lines in cpanfile than in final modules array
# cpanfile contains a known number of lines (number of modules)

ok 1;


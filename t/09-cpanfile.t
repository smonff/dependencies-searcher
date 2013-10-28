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
    "Cwd",
    "Log::Minimal",
    "File::Stamped",
    "File::Temp",
    "File::HomeDir",
    "File::Spec::Functions",
    "Version::Compare",
    "IPC::Run",
    "ExtUtils::MakeMaker",
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

my $fh = file ( 'cpanfile' );
if (not defined $fh) {
    die "Can't open cpanfile";
} else {
    my @lines = $fh->slurp;

    ok(
	@non_core_modules == @lines,
	'@uniq_modules should contain same number of element than cpanfile lines'
    );

    ok(
	@bugged_non_core_modules != @lines,
	'@bugged_non_core_modules should not contain same number of element than cpanfile lines'
    );
}

ok 1;

__END__

Stuff to test

* only one space between require and name, etc
* same number of lines in cpanfile than in final modules array
* cpanfile contains a known number of lines (number of modules)

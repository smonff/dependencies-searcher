use strict;
use warnings FATAL => 'all';
use Test::More tests => 16;
use Data::Printer;
use feature qw(say);
# This is not necessary, but a simple test, see Ovid's Book
use Dependencies::Searcher;


my $use_pattern = "^use ";
my $requires_pattern = "^requires ";
# Parameters for Ack2 :
    #  * Only pm files
    #  * No filename
    #  * Ignore case
my $parameters = "--perl -hi";

my $searcher = Dependencies::Searcher->new({
    use_pattern  => $use_pattern,
    requires_pattern => $requires_pattern,
    parameters => $parameters,
});

ok($searcher, "Searcher can not be created");
ok($searcher->use_pattern eq $use_pattern, '$searcher->use_pattern can\'t be accessed');
ok($searcher->requires_pattern eq $requires_pattern, '$searcher->requires_pattern can\'t be accessed');
ok($searcher->parameters eq $parameters, '$searcher->parameters can\'t be accessed');

my @elements = $searcher->get_files();
can_ok($searcher, 'get_files');
ok($elements[0] eq "lib", 'The current directory don\'t seem to be a Perl module');

my $path = $searcher->build_full_path(@elements);
can_ok($searcher, 'build_full_path');
ok($path =~ m/\s\.\/lib \.\/Makefile\.PL/, 'The generated path is not conform');

my @uses = $searcher->get_modules($path, "use");

my $uses_length = @uses - 1;
my $mid_length = $uses_length / 2;

ok($uses[0] =~ m/use\s/i, "Ack should return a used modules list");
ok($uses[$mid_length] =~ m/use\s/i, "Ack should return a used modules list");
ok($uses[$uses_length] =~ m/use\s/i, "Ack should return a used modules list");

my @requires = $searcher->get_modules($path, "require");
can_ok($searcher, 'get_modules');
my $requires_length = @requires -1;

my @merged_dependencies = $searcher->merge_dependencies(@uses, @requires);
my $merged_length = @merged_dependencies;

ok($merged_length == $uses_length + $requires_length + 2);

my @real_modules = $searcher->make_it_real(@merged_dependencies);
can_ok($searcher, 'make_it_real');

my @clean_modules = $searcher->clean_everything(@real_modules);

my @uniq_modules = $searcher->uniq(@clean_modules);

$searcher->dissociate(@uniq_modules);

# This is a shitty test, have to increment it each time we add modules...
ok($searcher->count_core_modules eq 4, "core numbers :()");
ok($searcher->count_non_core_modules eq 2, "non core numbers :()");

$searcher->generate_report($searcher->non_core_modules);


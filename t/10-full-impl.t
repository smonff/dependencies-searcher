use strict;
use warnings FATAL => 'all';
use Test::More tests => 11;
use Data::Printer;
use feature qw(say);
use IO::File;
use IPC::Cmd qw[can_run run];
# This is not necessary, but a simple test, see Ovid's Book
use Dependencies::Searcher;


my $searcher = Dependencies::Searcher->new();

ok($searcher, "Searcher creation");
#ok($searcher->use_pattern eq $use_pattern, '$searcher->use_pattern can\'t be accessed');
#ok($searcher->requires_pattern eq $requires_pattern, '$searcher->requires_pattern can\'t be accessed');
#ok($searcher->parameters eq $parameters, '$searcher->parameters can\'t be accessed');

my @elements = $searcher->get_files();
can_ok($searcher, 'get_files');
ok($elements[0] =~ /lib/, 'The current directory should be a Perl module');

my @uses = $searcher->get_modules("^use", @elements);

my $uses_length = @uses - 1;
my $mid_length = $uses_length / 2;

ok($uses[0] =~ m/use\s/i, "Ack should return a used modules list");
ok($uses[$mid_length] =~ m/use\s/i, "Ack should return a used modules list");
ok($uses[$uses_length] =~ m/use\s/i, "Ack should return a used modules list");

my @requires = $searcher->get_modules("^require", @elements);
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
# ok($searcher->count_core_modules eq 4, "core numbers :()");
# ok($searcher->count_non_core_modules eq 2, "non core numbers :()");

my $cpanfile = IO::File->new('cpanfile', '>');
ok($cpanfile, "Open a file handle on cpanfile");
$cpanfile->close;

$searcher->generate_report($searcher->non_core_modules);

$cpanfile = IO::File->new('cpanfile', '<');

my $line = $cpanfile->getline;
ok($line =~ m/^requires\s[A-Za-z]/, "Cpanfile contains requires lines");

# Have to test if cpanfile contains modules names and stuff
#ok($line =~ m/^requires\s[A-Za-z]+{[::]*[A-Za-z]}*/, "Cpanfile containes requires lines");

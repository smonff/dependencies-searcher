use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;
use Data::Printer;
use feature qw(say);
# This is not necessary, but a simple teset, see Ovid's Book
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
ok($elements[0] eq "lib", 'The current directory don\'t seem to be a Perl module');

my $path = $searcher->build_full_path(@elements);
ok($path =~ m/\s\.\/lib \.\/Makefile\.PL/, 'The generated path is not conform');






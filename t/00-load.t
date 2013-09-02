use strict;
use warnings FATAL => 'all';
use Test::More;
use Dependencies::Searcher;

plan tests => 2;

can_use(Dependencies::Searcher);

my $searcher = Dependencies::Searcher->new();
can_ok( $searcher, 'get_uses', "Should be able to get uses using Ack");

my @uses = $searcher->get_uses();
ok( $uses[0], "Ack should return lines, that will be storedd into an array" );


# diag( "Testing Dependencies::Searcher $Dependencies::Searcher::VERSION, Perl $], $^X" );



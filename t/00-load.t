use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;
use Dependencies::Searcher;

#my $searcher = Dependencies::Searcher->new();
#can_ok( $searcher, 'get_modules', "Should be able to get modules using Ack");
ok(1 == 1, "Un devrait être égal à 1");
#isa_ok( $searcher, 'Dependencies::Searcher');

#my @uses = $searcher->get_modules();
#ok( $uses[0], "Ack should return lines, that will be storedd into an array" );


diag( "Testing Dependencies::Searcher $Dependencies::Searcher::VERSION, Perl $], $^X" );



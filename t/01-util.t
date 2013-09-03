use strict;
use warnings FATAL => 'all';
use Test::More;
use Dependencies::Searcher::Utils;

plan tests => 1;

my $util = Dependencies::Searcher::Utils->new();

ok(1 == 1, "Un devrait être égal à 1");
# isa_ok( $util, 'Dependencies::Searcher::Utils');

# my @methods = ('get_modules', 'get_files');

# can_ok( $util, @methods, "Should be able to reach methods");;

#my @uses = $searcher->get_modules();
#ok( $uses[0], "Ack should return lines, that will be storedd into an array" );





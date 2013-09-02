#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Dependencies::Searcher' ) || print "Bail out!\n";
}

diag( "Testing Dependencies::Searcher $Dependencies::Searcher::VERSION, Perl $], $^X" );

use 5.010;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Dependencies::Searcher',
    AUTHOR           => q{smonff <smonff@gmail.com>},
    VERSION_FROM     => 'lib/Dependencies/Searcher.pm',
    ABSTRACT_FROM    => 'lib/Dependencies/Searcher.pm',
    LICENSE          => 'Perl_5',
    PL_FILES         => {},
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
	'App::Ack'        => 0,
	'Data::Printer'   => 0,
        'Module::Version' => 0,
	'Moose'           => 0,
	'Test::More'      => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Dependencies-Searcher-*' },
);

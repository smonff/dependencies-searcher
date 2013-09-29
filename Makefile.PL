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
	'IO::File'   => 0,
    },
    TEST_REQUIRES => {
	'App::Ack'        => 0,
	'Module::Version' => 0,
    },
    PREREQ_PM => {
	'App::Ack'         => 0,
	'Data::Printer'    => 0,
	'File::HomeDir'    => 0,
	'File::Stamped'    => 0,
	'IPC::Cmd'         => 0,
	'IPC::Run'         => 0,
	'Log::Minimal'     => 0,
	'Module::CoreList' => 2.99,
	'Module::Version'  => 0,
	'Moose'            => 0,
	'Test::More'       => 0,
	'Version::Compare' => 0,
    },

    MIN_PERL_VERSION => '5.010',
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Dependencies-Searcher-*' },
);

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
        'ExtUtils::MakeMaker' => 6.74,
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
	'App::Ack'              => 2.10,
	'Cwd'                   => 3.40,
	'Data::Printer'         => 0.35,
	'File::HomeDir'         => 1.00,
	'File::Spec::Functions' => 3.40,
	'File::Stamped'         => 0.03,
	'IPC::Cmd'              => 0,
	'IPC::Run'              => 0.90,
	'Log::Minimal'          => 0.16,
	'Module::CoreList'      => 2.99,
	'Module::Version'       => 0.12,
	'Moose'                 => 2.0602,
	'Test::More'            => 0,
	'Version::Compare'      => 0.14,
    },

    MIN_PERL_VERSION => '5.010',
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Dependencies-Searcher-*' },
);

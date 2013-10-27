use strict;
use warnings;
use Test::More 'no_plan';
use Dependencies::Searcher;

my @dirty_modules = (
    "use Data::Printer;",
    "use Module::CoreList 2.99;",
    "use Module::Version 'get_version';",
    "use Moose;",
    "use IPC::Cmd qw[can_run run];",
    "use Cwd;",
    "use Log::Minimal env_debug => 'LM_DEBUG';",
    "use File::Stamped;",
    "use IO::File;",
    "use File::Temp;",
    "use File::HomeDir;",
    "use File::Spec::Functions qw(catdir catfile);",
    "use Version::Compare;",
    "use Data::Printer;",
    "use Module::CoreList qw();",
    "use Moose;",
    "use IPC::Cmd qw[can_run run];",
    "use IPC::Run;",
    "use Log::Minimal env_debug => 'LM_DEBUG';",
    "use File::Stamped;",
    "use File::HomeDir;",
    "use File::Spec::Functions qw(catdir catfile);",
    "use strict;",
    "use ExtUtils::MakeMaker;",
);

my @imaginary_modules = ();
my @failing_stuff = ();

my $searcher = Dependencies::Searcher->new();

for my $dirty_module (@dirty_modules) {
    like $dirty_module, qr/use \s /x, "Line should contain 'use '";
}

my @clean_modules = $searcher->clean_everything(@dirty_modules);

for my $module (@clean_modules) {
    unlike $module, qr/use \s /x, "Line should not contain 'use '";
}

ok 1;

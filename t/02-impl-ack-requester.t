use strict;
use warnings FATAL => 'all';
use Test::More tests => 9;
use Data::Printer;
use feature qw(say);
use IPC::Cmd qw[can_run run];
# This is not necessary, but a simple test, see Ovid's Book
use Dependencies::Searcher::AckRequester;

my $use_pattern = "^use ";
my $requires_pattern = "^requires ";

# Parameters for Ack2 :
    #  * Only pm files
    #  * No filename
    #  * Ignore case
    #  * use or requires
my @params_for_use = ('--perl', '-hi', $use_pattern);
my @params_for_require = ('--perl', '-hi', $requires_pattern);

my $requester = Dependencies::Searcher::AckRequester->new();
ok($requester, "Ack requester cannot be created !");

can_ok($requester, 'ack');
can_ok($requester, 'build_cmd');
can_ok($requester, 'get_path');

my $ack_path = $requester->get_path();
ok($ack_path =~ /ack/, 'Ack don\'t seem to be installed');

my $cmd_use = $requester->build_cmd(@params_for_use);
ok($cmd_use, 'Cmd can\'t be build');

my $cmd_require = $requester->build_cmd(@params_for_require);
ok($cmd_require, 'Cmd can\'t be build');

my @ack_result_use = $requester->ack($cmd_use);
ok($ack_result_use[0] =~ /use/, 'Can\'t find any use');

my @ack_result_require = $requester->ack($cmd_require);

# Return nothing as long this distribution includes no requires
ok(not(exists $ack_result_require[0]), 'This module should not return any requires');

my @ack_results = (@ack_result_use, @ack_result_require);


use strict;
use warnings FATAL => 'all';
use Test::More tests => 4;
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


my $ack_path = $requester->get_path();
ok($ack_path =~ /ack/, 'Ack don\'t seem to be installed');

my $cmd_use = $requester->build_cmd(@params_for_use);
ok($cmd_use, 'Cmd can\'t be build');

my $cmd_require = $requester->build_cmd(@params_for_require);
ok($cmd_require, 'Cmd can\'t be build');

my @ack_result_use = $requester->ack($cmd_use);
# p @ack_result_use;

my @ack_result_require = $requester->ack($cmd_require);
# p @ack_result_require;

my @ack_results = (@ack_result_use, @ack_result_require);


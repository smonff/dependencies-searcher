use strict;
use warnings FATAL => 'all';
use Test::More tests => 3;
use Data::Printer;
use feature qw(say);
use IPC::Cmd qw[can_run run];
# This is not necessary, but a simple test, see Ovid's Book
use Dependencies::Searcher::AckRequester;

my @params = ('--perl', '-hi', 'use');

my $requester = Dependencies::Searcher::AckRequester->new();
ok($requester, "Ack requester cannot be created !");


my $ack_path = $requester->get_path();

ok($ack_path =~ /ack/, 'Ack don\'t seem to be installed');

my $cmd = $requester->build_cmd(@params);
ok($cmd, 'Cmd can\'t be build');


my @ack_result = $requester->ack($cmd);
p @ack_result;


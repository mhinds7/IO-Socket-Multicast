#!/usr/bin/perl

use strict;
use lib '../blib/lib','../blib/arch';
use IO::Socket::Multicast;

use constant DESTINATION => '226.1.1.2:2000';

my $sock = IO::Socket::INET->new(Proto=>'udp',PeerAddr=>DESTINATION);

while (1) {
  my $message = localtime;
  $message .= "\n" . `who`;
  $sock->send($message) || die "Couldn't send: $!";
} continue {
  sleep 10;
}

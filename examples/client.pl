#!/usr/bin/perl

use strict;
use lib '../blib/lib','../blib/arch';
use IO::Socket::Multicast;

use constant GROUP => '226.1.1.2';
use constant PORT  => '2000';

my $sock = IO::Socket::INET->new(Proto=>'udp',LocalPort=>PORT);
$sock->mcast_add(GROUP) || die "Couldn't set group: $!\n";

while (1) {
  my $data;
  next unless $sock->recv($data,1024);
  print $data;
}

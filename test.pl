# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use lib './blib/lib','./blib/arch';

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use IO::Socket::Multicast;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub test {
  my ($flag,$test) = @_;
  print $flag ? "ok " : "not ok ",$test,"\n";
}

my $s = IO::Socket::Multicast->new;
test ($s->mcast_add('225.0.1.1'),     2);
test ($s->mcast_drop(inet_aton('225.0.1.1')),    3);
test (!$s->mcast_drop('225.0.1.1'),   4);
test ($s->mcast_ttl         == 1,     5);
test ($s->mcast_ttl(10)     == 1,     6);
test ($s->mcast_ttl         == 10,    7);
test ($s->mcast_loopback    == 1,     8);
test ($s->mcast_loopback(0) == 1,     9);
test ($s->mcast_loopback    == 0,    10);
if ((`uname -sr` !~ /^Linux 2\.0/)             # getsockopt for if screwed up on early linux
    && (eval "use IO::Interface ':flags'; 1;") 
    && (my $mcast_if = find_a_mcast_if())) {
  test ($s->mcast_if  eq 'any'    ,    11);
  test ($s->mcast_if($mcast_if) eq 'any', 12);
  test ($s->mcast_if eq $mcast_if       , 13);
  test ($s->mcast_add('225.0.1.1',$mcast_if)  , 14);
} else {
  print "ok $_ # Skip. IO::Interface not available, no multicast interface found, or using bad version of linux\n"
    foreach (11..14);
}

sub find_a_mcast_if {
  my @ifs = $s->if_list;
  foreach (@ifs) {
    return $_ if $s->if_flags($_) & IFF_MULTICAST();
  }
}

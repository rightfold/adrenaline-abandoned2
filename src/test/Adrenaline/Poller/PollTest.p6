use Adrenaline::Poller::Monitor :Ping;
use Adrenaline::Poller::Poll :poll;
use Test;

plan(4);

# Pinging an irresolvable address fails.
{
    my $host    = '0100::'; # See RFC 6666.
    my $timeout = Duration.new(1);
    my $object  = Ping.new(:$host, :$timeout);
    my $status  = poll($object);
    cmp-ok(poll($object), '==', ∞);
}

# Pinging with an unrealistic timeout fails.
{
    my $host    = 'localhost';
    my $timeout = Duration.new(0);
    my $object  = Ping.new(:$host, :$timeout);
    my $status  = poll($object);
    cmp-ok($status, '==', ∞);
}

# Pinging localhost succeeds.
{
    my $host    = 'localhost';
    my $timeout = Duration.new(1);
    my $object  = Ping.new(:$host, :$timeout);
    my $status  = poll($object);
    cmp-ok($status, '≥', 0);
    cmp-ok($status, '≤', 1);
}

unit module Adrenaline::Poller::Poll;

use Adrenaline::Poller::Monitor :Object, :Ping;

proto poll(Object:D $o --> Real:D) is export(:poll) {*}

multi poll(Ping:D $o --> Real:D) {
    # The ping program does not accept non-integer timeouts, nor timeouts
    # smaller than one. If a timeout of zero is passed, it is interpreted as an
    # infinite timeout instead; avoid that.
    my $timeout = ceiling($o.timeout);
    return ∞ if $timeout ≤ 0;

    # XXX: The ping program will resolve the host; we don't have to. Maybe we
    # XXX: want to, though?
    my $host = $o.host;

    # Invoke the ping program because implementing ICMP ourselves is a
    # nightmare. It would require opening an ICMP socket, which requires root
    # privileges. Running Perl 6 code as root is an incredibly stupid idea.
    my Str:D @command = «ping -c 1 -W "$timeout" -- "$host"»;
    my $proc = run(|@command, :out);

    # Convert the output of the ping program to a number.
    sub time($_) { m/time\=(.+?) ms/[0] / 1000 };
    $proc.exitcode ?? ∞ !! time($proc.out.slurp);
}

=begin pod

=head1 NAME

Adrenaline::Poller::Poll - Polling an object to discover its status.

=head1 SYNOPSYS

    use Adrenaline::Poller::Monitor :Ping;
    use Adrenaline::Poller::Poll :poll;

    my $host    = 'example.com';
    my $timeout = Duration.new(1);
    my $object  = Ping.new(:$host, :$timeout);
    my $status  = poll($object);

=head1 DESCRIPTION

How to poll an object, and how to interpret its status, depends on the type
of object.

=defn Ping
Send an echo request to the specified host. If an echo reply arrives within
the specified timeout, the time it took for the echo reply to arrive is the
status of the object. Otherwise, or if sending the echo request failed, the
status of the object is ∞.

=head2 poll(Object:D $o --> Real:D)

Poll an object and return its status. How this works and how the status is to
be interpreted are documented above.

=head1 BUGS

The only information returned by C<poll> is the status of the object, which is
just a number. In the future we may investigate whether we can return more
information, such as error messages.

=end pod

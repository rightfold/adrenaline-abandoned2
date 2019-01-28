unit module Adrenaline::Poller::Loop;

use Adrenaline::Poller::Poll :poll;
use Adrenaline::Poller::Schedule :pop-monitor;
use Adrenaline::Poller::Status :update-status;
use Database::PostgreSQL :Connection;

sub poll-loop(Connection:D $c) is export(:poll-loop) {
    loop {
        poll-step($c);
        sleep(1);
    }
}

sub poll-step(Connection:D $c) is export(:poll-step) {
    my $poll = pop-monitor($c);
    my $status = poll($poll.monitor.object);
    update-status($c, $poll, $status);
}

=begin pod

=head1 NAME

Adrenaline::Poller::Loop - Poll loop.

=head1 DESCRIPTION

The poll loop is the driver of the poller. It repeatedly performs poll steps. A
poll step pops a monitor, polls its object, and updates the status.

=head2 poll-loop(Connection:D $c)

The poll loop. Does not return.

=head2 poll-step(Connection:D $c)

A single poll step.

=head1 BUGS

No logging takes place, so it is difficult to find out what is happening.

There is no exception handling in place; any exception will cause the loop to
terminate.

=end pod

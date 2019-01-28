unit module Adrenaline::Poller::Status;

use Adrenaline::Poller::Monitor :OngoingPoll;
use Database::PostgreSQL :Connection;

my constant UPDATE-STATUS = q:to/SQL/;
    UPDATE
        adrenaline.polls
    SET
        status = $3
    WHERE
        monitor_id = $1 AND
        timestamp = $2
SQL

proto update-status(|) is export(:update-status) {*}

multi update-status(Connection:D $c, OngoingPoll:D $poll, Real:D $status) {
    update-status($c, $poll.monitor.id, $poll.timestamp, $status);
}

multi update-status(Connection:D $c, Str:D $monitor, Str:D $timestamp,
                    Real:D $status) {
    $c.execute(UPDATE-STATUS, $monitor, $timestamp, ~$status);
}

=begin pod

=head1 NAME

Adrenaline::Poller::Status - Update the status of a poll.

=head1 DESCRIPTION

=head2 update-status(Connection:D $c, OngoingPoll:D $poll, Real:D $status)

Update the status of the given ongoing poll.

=head2 update-status(Connection:D $c, Str:D $monitor, Str:D $timestamp, Real:D $status)

Similar to the other overload, but does not require an entire monitor to be
given, only its ID.

=end pod

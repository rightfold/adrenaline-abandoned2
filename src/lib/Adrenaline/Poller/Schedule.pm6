unit module Adrenaline::Poller::Schedule;

use Adrenaline::Poller::Monitor :Monitor, :OngoingPoll, :Ping;
use Database::PostgreSQL :Connection;

my constant FIND-MONITOR = q:to/SQL/;
    SELECT
        monitors.id,
        monitors.object_type,
        monitors.object_ping_host,
        EXTRACT(epoch FROM monitors.object_ping_timeout)
    FROM
        adrenaline.monitors
    LEFT OUTER JOIN
        adrenaline.polls
        ON polls.monitor_id = monitors.id
    GROUP BY
        monitors.id
    HAVING
        count(polls.*) = 0 OR
        now() - max(polls.timestamp) > monitors.poll_interval
    ORDER BY
        random()
    LIMIT
        1
SQL

my constant INSERT-ONGOING-POLL = q:to/SQL/;
    INSERT INTO adrenaline.polls (monitor_id, timestamp)
    VALUES ($1, now())
    RETURNING timestamp
SQL

sub make-monitor(Str:D $id, Str:D $o-type, Str $o-ping-host,
                 Str $o-ping-timeout --> Monitor:D) {
    my $object = do given $o-type {
        when 'P' {
            my $host    = $o-ping-host;
            my $timeout = Duration.new(+$o-ping-timeout);
            Ping.new(:$host, :$timeout);
        }
        default {
            die("Invalid object type: $o-type");
        }
    };
    Monitor.new(:$id, :$object);
}

sub find-monitor(Connection:D $c --> Monitor) {
    my @result := $c.execute(FIND-MONITOR);
    @result.elems ?? make-monitor(|@result[0])
                  !! Monitor;
}

sub insert-ongoing-poll(Connection:D $c, Str:D $monitor-id) {
    my @result := $c.execute(INSERT-ONGOING-POLL, $monitor-id);
    @result[0][0];
}

sub pop-monitor(Connection:D $c --> OngoingPoll) is export(:pop-monitor) {
    # The SERIALIZABLE transaction isolation level is necessary to avoid the
    # scenario in which FIND-MONITOR returns the same monitor in two pollers,
    # prior to either performing INSERT-ONGOING-POLL.
    my $mode = 'ISOLATION LEVEL SERIALIZABLE';

    $c.transaction($mode, {
        my $monitor = find-monitor($c);
        if $monitor.defined {
            my $timestamp = insert-ongoing-poll($c, $monitor.id);
            OngoingPoll.new(:$monitor, :$timestamp);
        } else {
            OngoingPoll;
        }
    });
}

=begin pod

=head1 NAME

Adrenaline::Poller::Schedule - Find monitors that need polling.

=head1 SYNOPSYS

    use Adrenaline::Poller::Schedule :pop-monitor;
    use Database::PostgreSQL :Connection;

    my $c = Connection.new('');
    my $m = pop-monitor($c);
    if defined($m) {
        say $m.perl;
    } else {
        say 'No monitor available.';
    }

=head1 DESCRIPTION

The monitors and polls tables in the database together form a virtual queue of
monitors that need to be polled. This module provides a routine that pops a
monitor off the queue.

This involves two steps:

=item # Find a monitor that has not been polled since its poll interval ago.
=item # Insert an ongoing poll into the polls table for this monitor.

=head2 pop-monitor(Connection:D $c --> OngoingPoll)

This is the routine that was talked about previously. It returns an ongoing
poll that can be used to update the status of the poll later. In case the
queue is empty, this returns an undefined value.

=head1 BUGS

The current implementation may get slower as there are more tuples in the polls
table, because it uses the count aggregate.

=end pod

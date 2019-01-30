use Adrenaline::Poller::Schedule :pop-monitor;
use Adrenaline::Poller::Status :update-status;
use Database::PostgreSQL :Connection;
use Test;

plan(2);

my constant DSN =
    'host=localhost user=adrenaline_test password=adrenaline_test';
my $connection = Connection.new(DSN);

$connection.execute(q:to/SQL/);
    DELETE FROM adrenaline.organizations
SQL

$connection.execute(q:to/SQL/);
    INSERT INTO adrenaline.organizations (id)
    VALUES ('74ca4117-c9ed-432c-99b4-b2dbe6dcd370')
SQL

$connection.execute(q:to/SQL/);
    INSERT INTO adrenaline.groups (id, organization_id)
    VALUES ('f1704f7b-1932-48c4-9eea-e4dd35db255b',
            '74ca4117-c9ed-432c-99b4-b2dbe6dcd370')
SQL

$connection.execute(q:to/SQL/);
    INSERT INTO adrenaline.monitors (id, group_id, poll_interval, object_type,
                                     object_ping_host, object_ping_timeout)
    VALUES
        ('124dfe98-6646-461b-83dc-9892907c6a0f',
         'f1704f7b-1932-48c4-9eea-e4dd35db255b',
         '00:00:01', 'P', 'localhost', '00:00:00.5'),
        ('77883a3b-b097-4f2e-b3af-47a24a7cf8d9',
         'f1704f7b-1932-48c4-9eea-e4dd35db255b',
         '00:00:02', 'P', 'localhost', '00:00:01')
SQL

# Popping a monitor inserts the poll with no status.
my $m1 = pop-monitor($connection);
my $m2 = pop-monitor($connection);

# Set the status of the poll that was created when popping the monitor.
update-status($connection, $m1, 3.14);
update-status($connection, $m2, 6.28);

# Verify that the status is indeed updated.
my @result := $connection.execute(q:to/SQL/);
    SELECT status
    FROM adrenaline.polls
    ORDER BY timestamp ASC
SQL
is(@result[0][0], '3.14');
is(@result[1][0], '6.28');

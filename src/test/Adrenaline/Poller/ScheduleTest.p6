use Adrenaline::Poller::Schedule :pop-monitor;
use Database::PostgreSQL :Connection;
use Test;

plan(6);

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
    VALUES ('124dfe98-6646-461b-83dc-9892907c6a0f',
            'f1704f7b-1932-48c4-9eea-e4dd35db255b',
            '00:00:01', 'P', 'localhost', '00:00:00.5')
SQL

my $m1 = pop-monitor($connection);
my $m2 = pop-monitor($connection);
sleep(0.2);
my $m3 = pop-monitor($connection);
sleep(1.2);
my $m4 = pop-monitor($connection);

ok(?$m1.defined);
ok(!$m2.defined);
ok(!$m2.defined);
ok(?$m4.defined);

is($m1.monitor.id, '124dfe98-6646-461b-83dc-9892907c6a0f');
is($m4.monitor.id, '124dfe98-6646-461b-83dc-9892907c6a0f');

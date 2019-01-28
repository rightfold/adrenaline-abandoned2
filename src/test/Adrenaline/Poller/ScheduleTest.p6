use Adrenaline::Poller::Schedule :pop-monitor;
use Database::PostgreSQL :Connection;
use Test;

plan(6);

my constant DSN =
    'host=localhost user=adrenaline_test password=adrenaline_test';
my $connection = Connection.new(DSN);

$connection.execute(q:to/SQL/);
    DELETE FROM adrenaline.monitors
SQL

$connection.execute(q:to/SQL/);
    INSERT INTO adrenaline.monitors (id, poll_interval, object_type,
                                     object_ping_host, object_ping_timeout)
    VALUES ('124dfe98-6646-461b-83dc-9892907c6a0f', '00:00:01', 'P',
            'localhost', '00:00:00.5')
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

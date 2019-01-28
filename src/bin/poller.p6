use Adrenaline::Poller::Loop :poll-loop;
use Database::PostgreSQL :Connection;

my constant DSN =
    'host=localhost user=adrenaline_test password=adrenaline_test';

sub MAIN {
    my $c = Connection.new(DSN);
    poll-loop($c);
}

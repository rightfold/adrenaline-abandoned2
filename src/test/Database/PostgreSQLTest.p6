use Database::PostgreSQL :Connection;
use Test;

plan(11);

my constant DSN =
    'host=localhost user=adrenaline_test password=adrenaline_test';

# Executing a command with an empty result.
{
    my $connection = Connection.new(DSN);
    my @result := $connection.execute('SELECT WHERE FALSE');
    cmp-ok(@result.elems, '==', 0);
}

# Executing a command with a non-empty result.
{
    my $connection = Connection.new(DSN);
    my @result := $connection.execute('VALUES (1, NULL), (3, 4)');
    cmp-ok(@result.elems, '==', 2);
    cmp-ok(@result[0], 'eqv', ('1', Str));
    cmp-ok(@result[1], 'eqv', qw｢3 4｣);
}

# Executing a command with arguments.
{
    my $connection = Connection.new(DSN);
    my @result := $connection.execute('SELECT $1::int, $2::int', '1', '2');
    cmp-ok(@result.elems, '==', 1);
    cmp-ok(@result[0], 'eqv', qw｢1 2｣);
}

# Executing a command with NULL arguments.
{
    my $connection = Connection.new(DSN);
    my @result := $connection.execute('SELECT $1::int + $2::int', Str, '2');
    cmp-ok(@result.elems, '==', 1);
    cmp-ok(@result[0], 'eqv', (Str,));
}

# Iterating a result;
{
    my $connection = Connection.new(DSN);
    my @result := $connection.execute('VALUES (1, 2), (3, 4), (5, 6)');
    for 0 .. ∞ Z @result -> ($i, $tuple) {
        cmp-ok($tuple, 'eqv', qw｢1 2｣) if $i == 0;
        cmp-ok($tuple, 'eqv', qw｢3 4｣) if $i == 1;
        cmp-ok($tuple, 'eqv', qw｢5 6｣) if $i == 2;
    }
}

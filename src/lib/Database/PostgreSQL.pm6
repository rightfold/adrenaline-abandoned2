unit module Database::PostgreSQL;

use NativeCall;

class Connection is repr('CPointer') is export(:Connection) {...}
class Result does Iterable does Positional is repr('CPointer')
             is export(:Result) {...}
class ResultIterator does Iterator is export(:ResultIterator) {...}

my constant libpq = 'pq';
my constant CONNECTION_OK      = 0;
my constant PGRES_EMPTY_QUERY  = 0;
my constant PGRES_COMMAND_OK   = 1;
my constant PGRES_TUPLES_OK    = 2;
my constant PGRES_SINGLE_TUPLE = 9;
sub PQclear(Result:D $res) is native(libpq) {*}
sub PQconnectdb(Str:D $conninfo --> Connection) is native(libpq) {*}
sub PQerrorMessage(Connection:D $conn --> Str) is native(libpq) {*}
sub PQexecParams(Connection:D $conn, Str:D $command, int32 $nParams,
                 CArray:D[int32] $paramTypes, CArray:D[Str] $paramValues,
                 CArray:D[int32] $paramLengths, CArray:D[int32] $paramFormats,
                 int32 $resultFormat --> Result) is native(libpq) {*}
sub PQfinish(Connection:D $conn) is native(libpq) {*}
sub PQgetisnull(Result:D $res, int32 $row_number,
                int32 $column_number --> int32) is native(libpq) {*}
sub PQgetvalue(Result:D $res, int32 $row_number,
               int32 $column_number --> Str) is native(libpq) {*}
sub PQnfields(Result:D $res --> int32) is native(libpq) {*}
sub PQntuples(Result:D $res --> int32) is native(libpq) {*}
sub PQresultErrorMessage(Result:D $conn --> Str) is native(libpq) {*}
sub PQresultStatus(Result:D $conn --> int32) is native(libpq) {*}
sub PQstatus(Connection:D $conn --> int32) is native(libpq) {*}

class Connection {
    method new(Connection:U: Str:D $dsn --> Connection:D) {
        my $conn = PQconnectdb($dsn) // die('PQconnectdb');
        die("PQconnectdb: {PQerrorMessage($conn)}")
            if PQstatus($conn) != CONNECTION_OK;
        $conn;
    }

    submethod DESTROY {
        PQfinish(self);
    }

    method execute(Connection:D: Str:D $command, *@arguments --> Result:D) {
        my $nParams = @arguments.elems;
        my $paramTypes = Nil;
        my $paramValues := CArray[Str].new(@arguments);
        my $paramLengths = Nil;
        my $paramFormats = Nil;
        my $resultFormat = 0;
        my $res = PQexecParams(self, $command, $nParams, $paramTypes,
                               $paramValues, $paramLengths, $paramFormats,
                               $resultFormat)
            // die('PQexecParams');
        die("PQexecParams: {PQresultErrorMessage($res)}")
            if PQresultStatus($res) ∉ set(PGRES_EMPTY_QUERY, PGRES_COMMAND_OK,
                                          PGRES_TUPLES_OK, PGRES_SINGLE_TUPLE);
        $res;
    }
}

class Result {
    submethod DESTROY {
        PQclear(self);
    }

    method iterator {
        ResultIterator.new(result => self);
    }

    method elems(Result:D: --> Int:D) {
        PQntuples(self);
    }

    method AT-POS(Result:D: Int:D $tuple --> List) {
        my @values;
        for 0 ..^ PQnfields(self) -> $field {
            my $value = PQgetisnull(self, $tuple, $field)
                            ?? Str !! PQgetvalue(self, $tuple, $field);
            push(@values, $value);
        }
        @values.List;
    }
}

class ResultIterator {
    has Int    $!index = 0;
    has Result $.result;

    method pull-one {
        return IterationEnd if $!index == $.result.elems;
        $.result.AT-POS($!index++);
    }
}

=begin pod

=head1 NAME

Database::PostgreSQL - PostgreSQL client library.

=head1 SYNOPSYS

    use Database::PostgreSQL :Connection;

    my $conn = Connection.new('');
    my @res := $conn.execute(q:to/SQL/, 'Acme', 'paid');
        SELECT id, amount
        FROM invoices
        WHERE client = $1 AND
              status = $2
    SQL
    for @res -> ($id, $amount) {
        ...
    }

=head1 BUGS

The routines in this module die with a C<X::AdHoc>, but should die with more
specific error types.

=end pod

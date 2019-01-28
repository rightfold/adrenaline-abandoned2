<?php
declare(strict_types = 1);
namespace Adrenaline\Configurator;

use Adrenaline\Configurator\CreateMonitor\RequestBody;
use Data\UUID;
use Database\PostgreSQL\Connection;
use Web\Request;
use Web\Response;

final class CreateMonitor {
    private const INSERT_MONITOR = '
        INSERT INTO adrenaline.monitors (
            id, group_id, poll_interval, object_type,
            object_ping_host, object_ping_timeout
        )
        SELECT
            $3, $2, INTERVAL \'00:00:01\' * $4,
            \'P\', $5, INTERVAL \'00:00:01\' * $6
        FROM
            adrenaline.groups
        WHERE
            id = $2 AND
            organization_id = $1
    ';

    /** @var Connection */
    private $database;

    public function __construct(Connection $database) {
        $this->database = $database;
    }

    public function handleRequest(Request $request, string $organizationID,
                                  string $groupID): Response {
        $body = RequestBody::fromCSV($request->csv());
        $monitorID = $this->createMonitor(
            $organizationID, $groupID, $body->pollInterval,
            $body->pingHost, $body->pingTimeout
        );
        return Response::csv(Response::STATUS_OK, [], [[$monitorID]]);
    }

    public function createMonitor(string $organizationID, string $groupID,
                                  float $pollInterval, string $pingHost,
                                  float $pingTimeout): string {
        $monitorID = UUID::v4();

        $arguments = [
            $organizationID, $groupID, $monitorID,
            (string)$pollInterval, $pingHost,
            (string)$pingTimeout,
        ];
        $affected = $this->database->execute(self::INSERT_MONITOR, $arguments);

        if ($affected !== 1) {
            // TODO: Throw exception about unknown group.
            die('createMonitor');
        }
        return $monitorID;
    }
}

/*

=begin pod

=head1 NAME

Adrenaline\Configurator\CreateMonitor - Create a monitor.

=head1 SYNOPSYS

    use Adrenaline\Configurator\CreateMonitor;

    $createMonitor = new CreateMonitor($database);
    $monitorID = $createMonitor->createMonitor(
        $organizationID, $groupID, $pollInterval,
        $pingHost, $pingTimeout
    );

=head1 DESCRIPTION

Create a new monitor. The group must belong to the organization, otherwise this
will fail.

=head1 BUGS

At the moment, die is used instead of throw.

No authorization is performed.

=end pod

*/

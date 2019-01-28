<?php
declare(strict_types = 1);
namespace Adrenaline\Configurator\CreateMonitor;

final class RequestBody {
    /** @var float */
    public $pollInterval;

    /** @var string */
    public $pingHost;

    /** @var float */
    public $pingTimeout;

    public function __construct(float $pollInterval, string $pingHost,
                                float $pingTimeout) {
        $this->pollInterval = $pollInterval;
        $this->pingHost = $pingHost;
        $this->pingTimeout = $pingTimeout;
    }

    /** @param iterable<string[]> $rows */
    public static function fromCSV(iterable $rows): RequestBody {
        foreach ($rows as $row) {
            if (\count($row) < 2) goto invalid;
            $pollInterval = (float)$row[0];
            $objectType   =        $row[1];
            switch ($objectType) {
            case 'ping':
                if (\count($row) !== 4) goto invalid;
                $pingHost     =        $row[2];
                $pingTimeout  = (float)$row[3];
                return new RequestBody($pollInterval, $pingHost,
                                       $pingTimeout);
            default:
                goto invalid;
            }
        }

    invalid:
        // TODO: Throw exception.
        die('fromCSV');
    }
}

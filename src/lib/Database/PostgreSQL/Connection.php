<?php
declare(strict_types = 1);
namespace Database\PostgreSQL;

final class Connection {
    /** @var resource */
    private $handle;

    public function __construct(string $dsn) {
        $this->handle = \pg_connect($dsn);
    }

    /** @param array<?string> $arguments */
    public function execute(string $command, array $arguments): int {
        $result = \pg_query_params($this->handle, $command, $arguments);
        return \pg_affected_rows($result);
    }
}

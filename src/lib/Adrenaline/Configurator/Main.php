<?php
declare(strict_types = 1);
namespace Adrenaline\Configurator;

use Database\PostgreSQL\Connection;
use Web\Request;
use Web\Response;

final class Main {
    private const DSN = 'host=localhost user=adrenaline_test password=adrenaline_test';

    private function __construct() {
    }

    public static function main(): void {
        $database = new Connection(self::DSN);
        $createMonitor = new CreateMonitor($database);
        $router = new Router($createMonitor);

        $request = self::retrieveRequest();
        $response = $router->route($request);
        self::sendResponse($response);
    }

    private static function retrieveRequest(): Request {
        return new Request(
            (string)$_SERVER['REQUEST_METHOD'],
            (string)$_SERVER['REQUEST_URI'],
            \fopen('php://input', 'r')
        );
    }

    private static function sendResponse(Response $response): void {
        header('HTTP/1.1 ' . $response->status);
        foreach ($response->headers as $key => $value) {
            header($key . ': ' . $value);
        }
        ($response->body)();
    }
}

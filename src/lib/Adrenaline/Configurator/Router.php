<?php
declare(strict_types = 1);
namespace Adrenaline\Configurator;

use Web\Request;
use Web\Response;

final class Router {
    /** @var CreateMonitor */
    private $createMonitor;

    public function __construct(CreateMonitor $createMonitor) {
        $this->createMonitor = $createMonitor;
    }

    public function route(Request $request): Response {
        $m = $request->method;
        $p = $request->requestURI;

        if ($m === 'GET' && $p === '/ping') {
            return $this->handlePing($request);
        }

        if ($m === 'POST' && \preg_match('#^/organizations/([^/]+)/groups/([^/]+)/monitors$#', $p, $s)) {
            return $this->createMonitor->handleRequest($request, $s[1], $s[2]);
        }

        return $this->handleNotFound($request);
    }

    public function handlePing(Request $request): Response {
        return Response::csv(Response::STATUS_OK, [], [['pong']]);
    }

    public function handleNotFound(Request $request): Response {
        $body = [[$request->method, $request->requestURI]];
        return Response::csv(Response::STATUS_NOT_FOUND, [], $body);
    }
}

/*

=begin pod

=head1 NAME

Adrenaline\Configurator\Router - Route requests to handlers.

=head1 SYNOPSYS

    use Adrenaline\Configurator\Router;

    $router = new Router(...);
    $response = $router->route($request);

=head1 BUGS

If the request URI matches but the method does not, the response has the status
404 Not Found instead of 405 Method Not Allowed.

=end pod

*/

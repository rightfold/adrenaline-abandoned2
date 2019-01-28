<?php
declare(strict_types = 1);
namespace Web;

final class Request {
    /** @var string */
    public $method;

    /** @var string */
    public $requestURI;

    /** @var resource */
    public $body;

    /** @param resource $body */
    public function __construct(string $method, string $requestURI, $body) {
        $this->method = $method;
        $this->requestURI = $requestURI;
        $this->body = $body;
    }

    /** @return iterable<string[]> */
    public function csv(): iterable {
        for (;;) {
            $row = \fgetcsv($this->body);
            if ($row === FALSE) break;
            yield $row;
        }
    }
}

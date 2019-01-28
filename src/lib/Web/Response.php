<?php
declare(strict_types = 1);
namespace Web;

final class Response {
    public const STATUS_OK        = '200 OK';
    public const STATUS_NOT_FOUND = '404 Not Found';

    /** @var string */
    public $status;

    /** @var array<string,string> */
    public $headers;

    /** @var callable():void */
    public $body;

    /**
     * @param array<string,string> $headers
     * @param callable():void $body
     */
    public function __construct(string $status, array $headers, callable $body) {
        $this->status = $status;
        $this->headers = $headers;
        $this->body = $body;
    }

    /**
     * @param array<string,string> $headers
     * @param iterable<string[]> $rows
     */
    public static function csv(string $status, array $headers, iterable $rows): Response {
        $headers['Content-Type'] = 'text/csv';
        $body = function() use($rows): void {
            $file = \fopen('php://output', 'ab');
            foreach ($rows as $row) {
                \fputcsv($file, $row);
            }
        };
        return new Response($status, $headers, $body);
    }
}

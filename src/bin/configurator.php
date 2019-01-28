<?php
set_error_handler(function($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});
require_once __DIR__ . '/../share/vendor/autoload.php';
Adrenaline\Configurator\Main::main();

<?php
// CORS helper for local development (Apache + VS Code Live Server)
// Allows credentialed requests from localhost/127.0.0.1 origins (any port).

if (PHP_SAPI !== 'cli') {
    // APIs should always return valid JSON; avoid emitting PHP notices/warnings into responses.
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    error_reporting(E_ALL);

    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';

    if ($origin) {
        $isAllowed = (bool)preg_match('#^https?://(localhost|127\.0\.0\.1)(:\d+)?$#', $origin);
        if ($isAllowed) {
            header('Access-Control-Allow-Origin: ' . $origin);
            header('Access-Control-Allow-Credentials: true');
            header('Vary: Origin');
        } else {
            // Deliberately do not reflect unknown origins.
            header('Access-Control-Allow-Origin: null');
        }
    } else {
        // No Origin header: typically same-origin navigation or CLI tools.
        header('Access-Control-Allow-Origin: *');
    }

    header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Access-Control-Max-Age: 600');

    if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

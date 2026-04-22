<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../utils/cors.php';
require_once __DIR__ . '/../utils/auth.php';

auth_start_session();

if (!headers_sent()) {
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('Expires: 0');
}

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

auth_logout();
respond(['success' => true, 'message' => 'Logged out']);
?>

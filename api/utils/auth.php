<?php
function auth_send_no_cache_headers(): void {
    if (headers_sent()) {
        return;
    }
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('Expires: 0');
}

function auth_get_idle_timeout_seconds(): int {
    $raw = getenv('AUTH_IDLE_TIMEOUT_SECONDS');
    $n = is_string($raw) ? (int)$raw : 0;
    // Default: 30 minutes.
    return $n > 0 ? $n : 1800;
}

function auth_start_session(): void {
    if (session_status() === PHP_SESSION_NONE) {
        $isHttps = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $sameSite = $isHttps ? 'None' : 'Lax';
        if (!headers_sent()) {
            session_set_cookie_params([
                'path' => '/',
                'httponly' => true,
                'secure' => $isHttps,
                'samesite' => $sameSite
            ]);
        }
        // Suppress warnings (we return our own JSON error if this fails).
        $ok = @session_start();
        if ($ok !== true) {
            http_response_code(500);
            if (!headers_sent()) {
                header('Content-Type: application/json');
            }
            echo json_encode([
                'success' => false,
                'message' => 'Session could not be started. Check PHP session save path permissions.'
            ]);
            exit;
        }
    }
}

function auth_logout(): void {
    auth_start_session();

    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(
            session_name(),
            '',
            time() - 42000,
            $params['path'] ?? '/',
            $params['domain'] ?? '',
            (bool)($params['secure'] ?? false),
            (bool)($params['httponly'] ?? true)
        );
    }

    @session_destroy();
}

function auth_abort(int $code, string $message): void {
    auth_send_no_cache_headers();
    http_response_code($code);
    if (!headers_sent()) {
        header('Content-Type: application/json');
    }
    echo json_encode(['success' => false, 'message' => $message]);
    exit;
}

function auth_normalize_role(string $roleName): string {
    $normalized = strtolower(trim($roleName));
    if ($normalized === '') {
        return '';
    }
    if (str_contains($normalized, 'admin')) {
        return 'admin';
    }
    if (str_contains($normalized, 'teacher')) {
        return 'teacher';
    }
    if (str_contains($normalized, 'learner') || str_contains($normalized, 'student')) {
        return 'learners';
    }
    return $normalized;
}

function auth_role_key_from_session(): string {
    $rid = (int)($_SESSION['role_id'] ?? 0);
    if ($rid === 8) return 'admin';
    if ($rid === 9) return 'teacher';
    if ($rid === 10) return 'learners';
    return auth_normalize_role((string)($_SESSION['role_name'] ?? ''));
}

function auth_guard_session_freshness(): void {
    // Only enforce if a user is currently logged in.
    if (empty($_SESSION['user_id'])) {
        return;
    }

    $now = time();
    $timeout = auth_get_idle_timeout_seconds();

    $last = isset($_SESSION['last_activity']) ? (int)$_SESSION['last_activity'] : 0;
    if ($last > 0 && ($now - $last) > $timeout) {
        auth_logout();
        auth_abort(401, 'Session expired');
    }

    // Basic session binding (helps against stolen cookies).
    $ua = (string)($_SERVER['HTTP_USER_AGENT'] ?? '');
    if (!isset($_SESSION['user_agent'])) {
        $_SESSION['user_agent'] = $ua;
    } elseif ((string)$_SESSION['user_agent'] !== $ua) {
        auth_logout();
        auth_abort(401, 'Session invalidated');
    }

    // Activity tracking for timeout.
    $_SESSION['last_activity'] = $now;
}

function auth_require(): array {
    auth_start_session();
    auth_send_no_cache_headers();

    auth_guard_session_freshness();

    if (empty($_SESSION['user_id'])) {
        auth_abort(401, 'Not authenticated');
    }

    $roleKey = auth_role_key_from_session();

    return [
        'user_id' => (int)($_SESSION['user_id'] ?? 0),
        'role_id' => (int)($_SESSION['role_id'] ?? 0),
        'role_name' => (string)($_SESSION['role_name'] ?? ''),
        'role_key' => $roleKey,
        'session_idle_timeout_seconds' => auth_get_idle_timeout_seconds(),
        'session_last_activity' => (int)($_SESSION['last_activity'] ?? 0)
    ];
}

function auth_is_admin(array $session): bool {
    return ($session['role_key'] ?? '') === 'admin';
}

function auth_require_roles(array $allowedRoles): array {
    $session = auth_require();
    if (auth_is_admin($session)) {
        return $session;
    }
    $roleKey = $session['role_key'] ?? '';
    $allowed = array_map('strtolower', $allowedRoles);
    if (!in_array($roleKey, $allowed, true)) {
        auth_abort(403, 'Not authorized');
    }
    return $session;
}

function auth_is_read_operation(string $operation): bool {
    $op = strtolower(trim($operation));
    if ($op === '') {
        return false;
    }
    return str_starts_with($op, 'get') || str_starts_with($op, 'list') || str_starts_with($op, 'fetch');
}

function auth_enforce_roles(string $operation, array $readRoles, array $writeRoles): array {
    if (auth_is_read_operation($operation)) {
        return auth_require_roles($readRoles);
    }
    return auth_require_roles($writeRoles);
}
?>

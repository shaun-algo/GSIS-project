<?php
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo "Forbidden\n";
    exit(1);
}

require_once __DIR__ . '/../connection.php';

try {
    $sql = "ALTER TABLE learners ADD COLUMN completed TINYINT(1) DEFAULT 0 AFTER is_indigenous";
    $conn->exec($sql);
    echo json_encode(['success' => true, 'message' => 'Column "completed" added to learners table']);
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo json_encode(['success' => true, 'message' => 'Column already exists']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
    }
}
?>
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo "Forbidden\n";
    exit(1);
}

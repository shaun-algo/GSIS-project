<?php
$corsPath = __DIR__ . '/../utils/cors.php';
if (file_exists($corsPath)) {
    require_once $corsPath;
}

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "dep_ed";
try {
    $dsn = "mysql:host=$servername;dbname=$dbname;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    $conn = new PDO($dsn, $username, $password, $options);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>

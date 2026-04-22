<?php
/**
 * PSGC Importer (CLI)
 *
 * Imports PSA PSGC CSV into:
 *   - geo_provinces
 *   - geo_cities_municipalities
 *   - geo_barangays
 *
 * Usage:
 *   # Option A: one combined CSV containing all geographic levels
 *   php api/database/psgc/import_psgc.php --file=/path/to/psgc.csv --province-name="Misamis Oriental" --truncate
 *
 *   # Option B: separate CSVs per level (common if PSGC came from multi-sheet Excel)
 *   php api/database/psgc/import_psgc.php \
 *     --provinces-file=/path/to/provinces.csv \
 *     --cities-file=/path/to/cities_municipalities.csv \
 *     --barangays-file=/path/to/barangays.csv \
 *     --province-name="Misamis Oriental" --truncate
 *
 *   # Option C: flat barangay list (barangay + psgc_code + municipality + province)
 *   php api/database/psgc/import_psgc.php \
 *     --flat-barangays-file=/path/to/gitagum_barangays.csv \
 *     --truncate
 *
 *   # Filtering by province PSGC code (first 4 digits pattern)
 *   php api/database/psgc/import_psgc.php --file=/path/to/psgc.csv --province-code=1042 --truncate
 *
 * Notes:
 * - It tries to auto-detect header names commonly used in PSGC files.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(400);
    echo "This script must be run via CLI.\n";
    exit(1);
}

require_once __DIR__ . '/../../database/connection.php';

function argValue(string $name): ?string {
    global $argv;
    foreach ($argv as $arg) {
        if (str_starts_with($arg, "--{$name}=")) {
            return substr($arg, strlen("--{$name}="));
        }
    }
    return null;
}

function hasFlag(string $flag): bool {
    global $argv;
    return in_array("--{$flag}", $argv, true);
}

function fail(string $message): void {
    fwrite(STDERR, $message . "\n");
    exit(1);
}

function normalizeHeader(string $h): string {
    $h = trim(mb_strtolower($h));
    $h = preg_replace('/[^a-z0-9]+/u', '_', $h);
    return trim($h, '_');
}

function readCsvAssoc(string $filePath): iterable {
    $fh = fopen($filePath, 'rb');
    if (!$fh) {
        fail("Cannot open file: {$filePath}");
    }

    $header = null;
    while (($row = fgetcsv($fh)) !== false) {
        if ($header === null) {
            $header = array_map(fn($h) => normalizeHeader((string)$h), $row);
            continue;
        }

        if (!$row || count(array_filter($row, fn($v) => $v !== null && trim((string)$v) !== '')) === 0) {
            continue;
        }

        $assoc = [];
        foreach ($header as $i => $key) {
            $assoc[$key] = $row[$i] ?? null;
        }
        yield $assoc;
    }

    fclose($fh);
}

function pick(array $row, array $keys): ?string {
    foreach ($keys as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $v = trim((string)$row[$k]);
            if ($v !== '') return $v;
        }
    }
    return null;
}

function requireFileExists(?string $filePath, string $argName): void {
    if ($filePath === null || trim($filePath) === '') {
        return;
    }
    if (!file_exists($filePath)) {
        fail("File not found for {$argName}: {$filePath}");
    }
}

function onlyDigits(?string $s): ?string {
    if ($s === null) return null;
    $d = preg_replace('/\D+/', '', $s);
    return $d !== '' ? $d : null;
}

function geoLevel(?string $raw): ?string {
    if ($raw === null) return null;
    $v = mb_strtolower(trim($raw));

    // Common PSGC values: Province, City, Municipality, Barangay
    if (str_contains($v, 'barangay') || $v === 'bgy' || $v === 'brgy') return 'BARANGAY';
    if (str_contains($v, 'province') || $v === 'prov') return 'PROVINCE';
    if (str_contains($v, 'city') || $v === 'city') return 'CITY';
    if (str_contains($v, 'municipality') || $v === 'mun') return 'MUNICIPALITY';

    // Some datasets use 'Geographic Level' codes
    if ($v === 'b') return 'BARANGAY';
    if ($v === 'p') return 'PROVINCE';
    if ($v === 'c') return 'CITY';
    if ($v === 'm') return 'MUNICIPALITY';

    return null;
}

function deriveProvinceCode(string $psgcCode): ?string {
    // Common pattern: province is first 4 digits of PSGC
    $d = onlyDigits($psgcCode);
    if (!$d || strlen($d) < 4) return null;
    return substr($d, 0, 4);
}

function deriveCityMunCode(string $psgcCode): ?string {
    // Common pattern: city/mun is first 6 digits of PSGC
    $d = onlyDigits($psgcCode);
    if (!$d || strlen($d) < 6) return null;
    return substr($d, 0, 6);
}

$file = argValue('file');
$provincesFile = argValue('provinces-file');
$citiesFile = argValue('cities-file');
$barangaysFile = argValue('barangays-file');
$flatBarangaysFile = argValue('flat-barangays-file');
$filterProvinceName = argValue('province-name');
$filterProvinceCode = argValue('province-code');
$truncate = hasFlag('truncate');

if (!$file && !$flatBarangaysFile && (!$provincesFile || !$citiesFile || !$barangaysFile)) {
    fail("Missing required input. Provide either:\n" .
        "- --file=/path/to/combined_psgc.csv\n" .
        "OR\n" .
        "- --provinces-file=... --cities-file=... --barangays-file=...\n" .
        "OR\n" .
        "- --flat-barangays-file=/path/to/barangays.csv (with municipality+province columns)\n");
}

requireFileExists($file, '--file');
requireFileExists($provincesFile, '--provinces-file');
requireFileExists($citiesFile, '--cities-file');
requireFileExists($barangaysFile, '--barangays-file');
requireFileExists($flatBarangaysFile, '--flat-barangays-file');

$useFlat = (bool)$flatBarangaysFile;
$useCombined = (bool)$file && !$useFlat;

$provSource = $useFlat ? null : ($useCombined ? $file : $provincesFile);
$citySource = $useFlat ? null : ($useCombined ? $file : $citiesFile);
$brgySource = $useFlat ? $flatBarangaysFile : ($useCombined ? $file : $barangaysFile);

echo "PSGC import starting...\n";
if ($useCombined) {
    echo "Combined CSV: {$file}\n";
} elseif ($useFlat) {
    echo "Flat barangays CSV: {$flatBarangaysFile}\n";
} else {
    echo "Provinces CSV: {$provincesFile}\n";
    echo "Cities/Municipalities CSV: {$citiesFile}\n";
    echo "Barangays CSV: {$barangaysFile}\n";
}
if ($filterProvinceName) echo "Filter province name: {$filterProvinceName}\n";
if ($filterProvinceCode) echo "Filter province code: {$filterProvinceCode}\n";

try {
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    if ($truncate) {
        echo "Truncating geo tables...\n";
        $conn->exec('SET FOREIGN_KEY_CHECKS=0');
        $conn->exec('TRUNCATE TABLE geo_barangays');
        $conn->exec('TRUNCATE TABLE geo_cities_municipalities');
        $conn->exec('TRUNCATE TABLE geo_provinces');
        $conn->exec('SET FOREIGN_KEY_CHECKS=1');
    }

    // Note: TRUNCATE TABLE causes an implicit commit in MySQL.
    // Always start the transaction AFTER truncation so COMMIT/ROLLBACK is valid.
    $conn->beginTransaction();

    // Pass 1: load provinces
    $provStmt = $conn->prepare(
        'INSERT INTO geo_provinces (psgc_code, province_name, is_active)
         VALUES (:psgc_code, :province_name, 1)
         ON DUPLICATE KEY UPDATE province_name = VALUES(province_name), is_active = 1'
    );

    $provinceCodesImported = [];
    $provincesSeen = 0;

    if (!$useFlat) {
        foreach (readCsvAssoc($provSource) as $row) {
            if ($useCombined) {
                $level = geoLevel(pick($row, ['geographic_level', 'geographic_level_name', 'level', 'geo_level']));
                if ($level !== 'PROVINCE') continue;
            }

            $psgc = pick($row, ['psgc_code', 'psgc', 'code', 'psgccode']);
            $name = pick($row, ['name', 'province', 'province_name', 'geographic_name', 'geographicname', 'prov_name']);
            $psgcDigits = onlyDigits($psgc);

            if (!$psgcDigits || !$name) continue;

            if ($filterProvinceCode && deriveProvinceCode($psgcDigits) !== onlyDigits($filterProvinceCode)) {
                continue;
            }
            if ($filterProvinceName && mb_strtolower(trim($name)) !== mb_strtolower(trim($filterProvinceName))) {
                continue;
            }

            $provStmt->execute([
                ':psgc_code' => $psgcDigits,
                ':province_name' => $name
            ]);

            $provinceCodesImported[deriveProvinceCode($psgcDigits) ?? $psgcDigits] = true;
            $provincesSeen++;
        }
    } else {
        // Flat mode: derive province rows from barangay list
        foreach (readCsvAssoc($brgySource) as $row) {
            $provinceName = pick($row, ['province', 'province_name']);
            if (!$provinceName) continue;
            if ($filterProvinceName && mb_strtolower(trim($provinceName)) !== mb_strtolower(trim($filterProvinceName))) {
                continue;
            }

            $psgc = onlyDigits(pick($row, ['psgc_code', 'psgccode', 'code']));
            $provCode = $psgc ? (deriveProvinceCode($psgc) ?? null) : null;

            if ($filterProvinceCode && $provCode !== onlyDigits($filterProvinceCode)) {
                continue;
            }

            $provStmt->execute([
                ':psgc_code' => $provCode,
                ':province_name' => $provinceName
            ]);

            if ($provCode) {
                $provinceCodesImported[$provCode] = true;
            }
            $provincesSeen++;
        }
    }

    if ($provincesSeen === 0) {
        // Many PSGC exports are a single file but may not label provinces as 'Province'.
        // If this happens, user should provide a proper export or adjust headers.
        echo "Warning: no provinces imported (check your CSV headers/values).\n";
    }

    // Build province code -> province_id map
    $provinceIdByCode = [];
    $stmt = $conn->query('SELECT province_id, psgc_code, province_name FROM geo_provinces');
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $p) {
        $code = deriveProvinceCode((string)$p['psgc_code']) ?? (string)$p['psgc_code'];
        $provinceIdByCode[$code] = (int)$p['province_id'];
    }

    // Pass 2: load cities/municipalities
    $cityStmt = $conn->prepare(
        'INSERT INTO geo_cities_municipalities (province_id, psgc_code, city_municipality_name, is_city, is_active)
         VALUES (:province_id, :psgc_code, :name, :is_city, 1)
         ON DUPLICATE KEY UPDATE city_municipality_name = VALUES(city_municipality_name), is_city = VALUES(is_city), is_active = 1'
    );

    $cityMunIdByCode = [];
    $citiesSeen = 0;

    if (!$useFlat) {
        foreach (readCsvAssoc($citySource) as $row) {
            if ($useCombined) {
                $level = geoLevel(pick($row, ['geographic_level', 'geographic_level_name', 'level', 'geo_level']));
                if ($level !== 'CITY' && $level !== 'MUNICIPALITY') continue;
            } else {
                // Separate file mode: infer whether it's city or municipality if present; default to municipality.
                $level = geoLevel(pick($row, ['geographic_level', 'geographic_level_name', 'level', 'geo_level'])) ?? 'MUNICIPALITY';
                if ($level !== 'CITY' && $level !== 'MUNICIPALITY') {
                    $level = 'MUNICIPALITY';
                }
            }

            $psgc = onlyDigits(pick($row, ['psgc_code', 'psgc', 'code', 'psgccode']));
            $name = pick($row, ['name', 'city', 'municipality', 'city_municipality_name', 'geographic_name', 'geographicname', 'citymun_name']);

            if (!$psgc || !$name) continue;

            $provCode = onlyDigits(pick($row, ['province_code', 'prov_code', 'province_psgc_code', 'prov_psgc', 'provpsgc']))
                ?? deriveProvinceCode($psgc);

            if (!$provCode) continue;

            if ($filterProvinceCode && $provCode !== onlyDigits($filterProvinceCode)) continue;
            if ($filterProvinceName) {
                if ($provincesSeen > 0 && !isset($provinceCodesImported[$provCode])) continue;
            }

            if (!isset($provinceIdByCode[$provCode])) {
                continue;
            }

            $cityStmt->execute([
                ':province_id' => $provinceIdByCode[$provCode],
                ':psgc_code' => $psgc,
                ':name' => $name,
                ':is_city' => $level === 'CITY' ? 1 : 0
            ]);

            $citiesSeen++;
        }
    } else {
        // Flat mode: derive city/municipality rows from barangay list
        foreach (readCsvAssoc($brgySource) as $row) {
            $provinceName = pick($row, ['province', 'province_name']);
            $municipalityName = pick($row, ['municipality', 'city', 'city_municipality', 'city_municipality_name', 'citymun']);
            $psgc = onlyDigits(pick($row, ['psgc_code', 'psgccode', 'code']));

            if (!$provinceName || !$municipalityName) continue;
            if ($filterProvinceName && mb_strtolower(trim($provinceName)) !== mb_strtolower(trim($filterProvinceName))) continue;

            $provCode = $psgc ? (deriveProvinceCode($psgc) ?? null) : null;
            if ($filterProvinceCode && $provCode !== onlyDigits($filterProvinceCode)) continue;

            // Find province by name first (more reliable in flat lists)
            $stmt = $conn->prepare('SELECT province_id, psgc_code FROM geo_provinces WHERE province_name = :name LIMIT 1');
            $stmt->execute([':name' => $provinceName]);
            $provRow = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$provRow) continue;
            $provinceId = (int)$provRow['province_id'];

            $cityMunCode = $psgc ? (deriveCityMunCode($psgc) ?? null) : null;

            $cityStmt->execute([
                ':province_id' => $provinceId,
                ':psgc_code' => $cityMunCode,
                ':name' => $municipalityName,
                ':is_city' => 0
            ]);
            $citiesSeen++;
        }
    }

    // Build city/mun code -> id map
    $stmt = $conn->query('SELECT city_municipality_id, psgc_code FROM geo_cities_municipalities');
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $cm) {
        $code = deriveCityMunCode((string)$cm['psgc_code']) ?? (string)$cm['psgc_code'];
        $cityMunIdByCode[$code] = (int)$cm['city_municipality_id'];
    }

    // Pass 3: load barangays
    $brgyStmt = $conn->prepare(
        'INSERT INTO geo_barangays (city_municipality_id, psgc_code, barangay_name, is_active)
         VALUES (:city_municipality_id, :psgc_code, :name, 1)
         ON DUPLICATE KEY UPDATE barangay_name = VALUES(barangay_name), is_active = 1'
    );

    $barangaysSeen = 0;

    foreach (readCsvAssoc($brgySource) as $row) {
        if ($useCombined) {
            $level = geoLevel(pick($row, ['geographic_level', 'geographic_level_name', 'level', 'geo_level']));
            if ($level !== 'BARANGAY') continue;
        }

        $psgc = onlyDigits(pick($row, ['psgc_code', 'psgc', 'code', 'psgccode']));
        $name = pick($row, ['name', 'barangay', 'barangay_name', 'geographic_name', 'geographicname', 'brgy_name', 'brgy']);

        if (!$psgc || !$name) continue;

        if ($useFlat) {
            $provinceName = pick($row, ['province', 'province_name']);
            $municipalityName = pick($row, ['municipality', 'city', 'city_municipality', 'city_municipality_name', 'citymun']);
            if (!$provinceName || !$municipalityName) continue;

            if ($filterProvinceName && mb_strtolower(trim($provinceName)) !== mb_strtolower(trim($filterProvinceName))) continue;

            $provCode = deriveProvinceCode($psgc);
            if ($filterProvinceCode && $provCode !== onlyDigits($filterProvinceCode)) continue;

            // Province lookup by name
            $stmt = $conn->prepare('SELECT province_id FROM geo_provinces WHERE province_name = :name LIMIT 1');
            $stmt->execute([':name' => $provinceName]);
            $provinceId = (int)($stmt->fetchColumn() ?: 0);
            if ($provinceId <= 0) continue;

            // City/Mun lookup by (province_id, name)
            $stmt = $conn->prepare('SELECT city_municipality_id FROM geo_cities_municipalities WHERE province_id = :province_id AND city_municipality_name = :name LIMIT 1');
            $stmt->execute([':province_id' => $provinceId, ':name' => $municipalityName]);
            $cityMunicipalityId = (int)($stmt->fetchColumn() ?: 0);
            if ($cityMunicipalityId <= 0) continue;

            $brgyStmt->execute([
                ':city_municipality_id' => $cityMunicipalityId,
                ':psgc_code' => $psgc,
                ':name' => $name
            ]);
            $barangaysSeen++;
            continue;
        }

        $provCode = onlyDigits(pick($row, ['province_code', 'prov_code', 'province_psgc_code', 'prov_psgc', 'provpsgc']))
            ?? deriveProvinceCode($psgc);

        if ($filterProvinceCode && $provCode !== onlyDigits($filterProvinceCode)) continue;
        if ($filterProvinceName) {
            if ($provincesSeen > 0 && !isset($provinceCodesImported[$provCode])) continue;
        }

        $cityMunCode = onlyDigits(pick($row, [
                'city_municipality_code', 'citymun_code', 'city_mun_code',
                'municipality_code', 'city_code',
                'city_municipality_psgc_code', 'citymun_psgc', 'citymunpsgc'
            ]))
            ?? deriveCityMunCode($psgc);

        if (!$cityMunCode || !isset($cityMunIdByCode[$cityMunCode])) {
            continue;
        }

        $brgyStmt->execute([
            ':city_municipality_id' => $cityMunIdByCode[$cityMunCode],
            ':psgc_code' => $psgc,
            ':name' => $name
        ]);

        $barangaysSeen++;
    }

    $conn->commit();

    echo "Done. Imported/updated:\n";
    echo "- Provinces: {$provincesSeen}\n";
    echo "- Cities/Municipalities: {$citiesSeen}\n";
    echo "- Barangays: {$barangaysSeen}\n";
    echo "\nBarangay dropdown correctness is guaranteed by DB relationship: geo_barangays.city_municipality_id\n";
} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    fail('Import failed: ' . $e->getMessage());
}

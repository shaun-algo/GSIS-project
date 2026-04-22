-- Migration: Add geo lookup tables for addresses (Province -> City/Municipality -> Barangay)
-- Scope: seed only what you need (e.g., Misamis Oriental) for fast dropdowns.
-- Notes:
-- - Keep PSGC codes if you have them, but the schema also works without codes.
-- - Recommended source of master data: PSA PSGC releases (CSV/Excel).

CREATE TABLE IF NOT EXISTS geo_provinces (
    province_id INT AUTO_INCREMENT PRIMARY KEY,
    psgc_code VARCHAR(20) NULL,
    province_name VARCHAR(150) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL,
    UNIQUE KEY uq_geo_provinces_name (province_name),
    UNIQUE KEY uq_geo_provinces_psgc (psgc_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS geo_cities_municipalities (
    city_municipality_id INT AUTO_INCREMENT PRIMARY KEY,
    province_id INT NOT NULL,
    psgc_code VARCHAR(20) NULL,
    city_municipality_name VARCHAR(150) NOT NULL,
    is_city TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL,
    UNIQUE KEY uq_geo_citymun_prov_name (province_id, city_municipality_name),
    UNIQUE KEY uq_geo_citymun_psgc (psgc_code),
    KEY idx_geo_citymun_province (province_id),
    CONSTRAINT fk_geo_citymun_province
        FOREIGN KEY (province_id) REFERENCES geo_provinces(province_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS geo_barangays (
    barangay_id INT AUTO_INCREMENT PRIMARY KEY,
    city_municipality_id INT NOT NULL,
    psgc_code VARCHAR(20) NULL,
    barangay_name VARCHAR(150) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL,
    UNIQUE KEY uq_geo_barangay_city_name (city_municipality_id, barangay_name),
    UNIQUE KEY uq_geo_barangay_psgc (psgc_code),
    KEY idx_geo_barangay_citymun (city_municipality_id),
    CONSTRAINT fk_geo_barangay_citymun
        FOREIGN KEY (city_municipality_id) REFERENCES geo_cities_municipalities(city_municipality_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

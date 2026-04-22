-- Minimal seed example (Misamis Oriental scope)
-- This is NOT a full PSGC dataset.
-- Purpose: give you a working cascading dropdown quickly, then you can import the full/filtered PSGC.
--
-- Recommended: use PSA PSGC CSV and import the full list for Misamis Oriental.

-- 1) Province
INSERT INTO geo_provinces (psgc_code, province_name)
VALUES (NULL, 'Misamis Oriental')
ON DUPLICATE KEY UPDATE province_name = VALUES(province_name);

-- 2) City/Municipality (example)
-- If you want more municipalities/cities, repeat these inserts.
INSERT INTO geo_cities_municipalities (province_id, psgc_code, city_municipality_name, is_city)
SELECT p.province_id, NULL, 'Gitagum', 0
FROM geo_provinces p
WHERE p.province_name = 'Misamis Oriental'
ON DUPLICATE KEY UPDATE city_municipality_name = VALUES(city_municipality_name);

-- 3) Barangays
-- PSGC includes the full official barangay list per municipality.
-- Add barangays by joining the city/municipality you inserted above, example:
-- INSERT INTO geo_barangays (city_municipality_id, psgc_code, barangay_name)
-- SELECT cm.city_municipality_id, NULL, 'YOUR BARANGAY NAME'
-- FROM geo_cities_municipalities cm
-- WHERE cm.city_municipality_name = 'Gitagum';

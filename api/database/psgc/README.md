# PSGC master data (geo lookups)

This project uses lookup tables for `Province → City/Municipality → Barangay` to keep addresses consistent.

## Recommended source
- PSA PSGC (Philippine Standard Geographic Code) releases (CSV/Excel).

## Suggested workflow (Misamis Oriental only)
1. Download the latest PSGC CSV/Excel from PSA.
2. Filter rows to **Misamis Oriental** only (province + its cities/municipalities + barangays).
3. Import into these tables (created by `api/migrations/add_geo_lookup_tables.sql`):
   - `geo_provinces`
   - `geo_cities_municipalities`
   - `geo_barangays`

## Import option A (recommended): CLI importer
1. Export PSGC to a single CSV that includes provinces, cities/municipalities, and barangays.
2. Run:
   - `php api/database/psgc/import_psgc.php --file=/absolute/path/to/psgc.csv --province-name="Misamis Oriental" --truncate`

If you know the province code (common PSGC pattern uses first 4 digits):
- `php api/database/psgc/import_psgc.php --file=/absolute/path/to/psgc.csv --province-code=1042 --truncate`

## Cascading dropdown behavior
The UI calls these endpoints:
- Provinces: `api/geo/provinces.php?operation=getAllProvinces`
- Cities/Municipalities (filtered by province): `api/geo/cities_municipalities.php?operation=getCitiesMunicipalitiesByProvince&province_id=...`
- Barangays (filtered by city/municipality): `api/geo/barangays.php?operation=getBarangaysByCityMunicipality&city_municipality_id=...`

Because `geo_barangays` stores `city_municipality_id`, the barangay dropdown is always based on the selected municipality.

## Import option B (quick): flat barangay list
If you already have a CSV like:
- `barangay,psgc_code,municipality,province,country`

You can import it directly:
- `php api/database/psgc/import_psgc.php --flat-barangays-file=/absolute/path/to/gitagum_barangays.csv --truncate`

This mode will automatically:
- create/upsert the province row (by `province` name)
- create/upsert the municipality row under that province (by `municipality` name)
- insert all barangays linked to that municipality

## Import notes
- Keep `psgc_code` if you have it; it’s optional but helps with stable identifiers.
- Keep names exactly as in PSGC for consistency.

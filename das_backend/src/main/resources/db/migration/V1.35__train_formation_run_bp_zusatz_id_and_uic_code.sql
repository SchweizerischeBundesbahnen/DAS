-- Truncate all data (will be repopulated by initial load)
TRUNCATE TABLE train_formation_run;

-- Drop the unique constraint that references the old columns
ALTER TABLE train_formation_run
    DROP CONSTRAINT IF EXISTS train_formation_run_unique;

-- Drop old columns
ALTER TABLE train_formation_run
    DROP COLUMN IF EXISTS taf_tap_location_reference_start,
    DROP COLUMN IF EXISTS taf_tap_location_reference_end;

-- Add new UIC location columns
ALTER TABLE train_formation_run
    ADD COLUMN IF NOT EXISTS taf_tap_location_uic_start_code       INTEGER,
    ADD COLUMN IF NOT EXISTS taf_tap_location_uic_start_pass_index INTEGER,
    ADD COLUMN IF NOT EXISTS taf_tap_location_uic_end_code         INTEGER;

-- Recreate unique constraint
ALTER TABLE train_formation_run
    ADD CONSTRAINT train_formation_run_unique UNIQUE (
                                                      inspection_date_time,
                                                      operational_train_number,
                                                      operational_day,
                                                      company,
                                                      taf_tap_location_uic_start_code,
                                                      taf_tap_location_uic_end_code
        );

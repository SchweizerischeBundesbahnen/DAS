ALTER TABLE IF EXISTS train_identification
    ADD COLUMN IF NOT EXISTS line TEXT;

ALTER TABLE IF EXISTS train_identification
    ADD COLUMN IF NOT EXISTS vehicle_modes TEXT;

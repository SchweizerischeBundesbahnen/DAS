ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN traction_modes TO traction_mode;
ALTER TABLE IF EXISTS train_formation_run
    ADD COLUMN traction_series TEXT;
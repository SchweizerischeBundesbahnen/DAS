ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN traction_modes TO additional_traction_mode;
ALTER TABLE IF EXISTS train_formation_run
    ADD COLUMN additional_traction_series TEXT;
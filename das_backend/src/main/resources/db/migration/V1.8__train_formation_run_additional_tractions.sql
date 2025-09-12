ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN additional_traction_mode TO additional_tractions;

ALTER TABLE IF EXISTS train_formation_run
    DROP COLUMN additional_traction_series;
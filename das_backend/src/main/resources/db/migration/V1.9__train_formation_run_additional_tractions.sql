ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN additional_traction_mode TO additional_tractions;

UPDATE train_formation_run
SET additional_tractions = NULL;

ALTER TABLE IF EXISTS train_formation_run
    DROP COLUMN additional_traction_series;

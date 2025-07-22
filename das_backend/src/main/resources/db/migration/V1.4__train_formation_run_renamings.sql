ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN start_date TO operational_day;
ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN traction_mode TO traction_modes;
ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN traction_gross_weight_in_t TO traction_weight_in_t;
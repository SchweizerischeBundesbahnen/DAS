CREATE INDEX IF NOT EXISTS train_identification_train_number_start_date_time_idx
    ON train_identification (operational_train_number, start_date_time);

DROP INDEX IF EXISTS train_identification_start_date_time_train_number_idx;

CREATE INDEX IF NOT EXISTS train_identification_preloaded_at_null_idx
    ON train_identification (start_date_time) WHERE preloaded_at IS NULL;

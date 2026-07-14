CREATE INDEX IF NOT EXISTS train_identification_start_date_time_train_number_idx
    ON train_identification (start_date_time, operational_train_number);

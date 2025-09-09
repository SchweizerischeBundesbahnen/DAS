ALTER TABLE IF EXISTS train_formation_run
    RENAME COLUMN modified_date_time TO inspection_date_time;
ALTER TABLE IF EXISTS train_formation_run
    ADD COLUMN IF NOT EXISTS train_path_id TEXT;
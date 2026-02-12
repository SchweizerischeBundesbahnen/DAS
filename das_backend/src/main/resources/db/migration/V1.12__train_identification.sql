DROP INDEX IF EXISTS train_identification_idx;
DROP TABLE IF EXISTS train_identification;

CREATE TABLE IF NOT EXISTS train_identification
(
    id                       INTEGER                  NOT NULL,
    train_path_id            TEXT                     NOT NULL,
    period                   INT                      NOT NULL,
    operational_train_number TEXT                     NOT NULL,
    start_date_time          TIMESTAMP WITH TIME ZONE NOT NULL,
    companies                TEXT                     NOT NULL,
    operational_day          DATE                     NOT NULL
);

ALTER TABLE IF EXISTS train_identification
    ADD CONSTRAINT train_identification_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS train_identification
    ADD CONSTRAINT train_identification_unique UNIQUE (train_path_id, period, operational_day);

CREATE INDEX train_identification_start_date_time_idx ON train_identification (start_date_time);

CREATE INDEX IF NOT EXISTS train_identification_train_path_id_period_idx
    ON train_identification (train_path_id, period);

CREATE SEQUENCE train_identification_id_seq START WITH 1 INCREMENT BY 1;


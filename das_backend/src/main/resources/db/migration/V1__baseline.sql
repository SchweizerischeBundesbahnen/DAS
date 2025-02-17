CREATE TABLE IF NOT EXISTS service_point
(
    uic          INTEGER PRIMARY KEY,
    designation  TEXT NOT NULL,
    abbreviation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS train_identification
(
    operational_train_number TEXT      NOT NULL,
    start_date               DATE      NOT NULL,
    company                  TEXT      NOT NULL,
    start_date_time          TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS train_identification_idx
    ON train_identification (
                             operational_train_number,
                             start_date, company
        );

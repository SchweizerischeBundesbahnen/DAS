CREATE TABLE IF NOT EXISTS train_identifier
(
    identifier      TEXT      NOT NULL,
    operation_date  DATE      NOT NULL,
    ru              TEXT      NOT NULL,
    start_date_time TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS train_identifier_idx
    ON train_identifier (
                         identifier,
                         operation_date, ru
        );

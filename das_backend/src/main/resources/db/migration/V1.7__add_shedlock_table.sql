CREATE TABLE IF NOT EXISTS shedlock
(
    name       TEXT      NOT NULL,
    lock_until TIMESTAMP NOT NULL,
    locked_at  TIMESTAMP NOT NULL,
    locked_by  TEXT      NOT NULL
);

ALTER TABLE IF EXISTS shedlock
    ADD CONSTRAINT name_pk PRIMARY KEY (name);

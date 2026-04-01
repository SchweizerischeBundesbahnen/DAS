CREATE TABLE IF NOT EXISTS location
(
    id                    INTEGER NOT NULL,
    location_reference    TEXT    NOT NULL,
    primary_location_name TEXT    NOT NULL,
    location_abbreviation TEXT,
    valid_from            DATE    NOT NULL,
    valid_to              DATE    NOT NULL
);

ALTER TABLE IF EXISTS location
    ADD CONSTRAINT location_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS location
    ADD CONSTRAINT location_unique UNIQUE (location_reference, valid_from, valid_to);

CREATE SEQUENCE location_id_seq START WITH 1 INCREMENT BY 1;

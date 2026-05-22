CREATE TABLE ru_indication
(
    id                               INTEGER   NOT NULL,
    category                         TEXT,
    title_de                         TEXT,
    text_de                          TEXT,
    title_fr                         TEXT,
    text_fr                          TEXT,
    title_it                         TEXT,
    text_it                          TEXT,
    companies                        TEXT      NOT NULL,
    operational_train_number_filters JSONB,
    taf_tap_location_references      TEXT      NOT NULL,
    periods                          JSONB,
    last_modified_at                 TIMESTAMP NOT NULL,
    last_modified_by                 TEXT      NOT NULL
);

ALTER TABLE IF EXISTS ru_indication
    ADD CONSTRAINT ru_indication_id_pk PRIMARY KEY (id);

CREATE SEQUENCE ru_indication_id_seq START WITH 1 INCREMENT BY 1;

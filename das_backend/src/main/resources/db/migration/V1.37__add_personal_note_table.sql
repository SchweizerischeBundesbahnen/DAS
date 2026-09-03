CREATE TABLE personal_note
(
    id               INTEGER        NOT NULL,
    oid              TEXT           NOT NULL,
    key              TEXT           NOT NULL,
    value            VARCHAR(16384) NOT NULL,
    last_modified_at TIMESTAMP      NOT NULL
);

ALTER TABLE IF EXISTS personal_note
    ADD CONSTRAINT personal_note_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS personal_note
    ADD CONSTRAINT personal_note_oid_key_unique UNIQUE (oid, key);

CREATE INDEX IF NOT EXISTS personal_note_oid_idx
    ON personal_note (oid);

CREATE SEQUENCE personal_note_id_seq START WITH 1 INCREMENT BY 1;

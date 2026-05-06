CREATE TABLE holiday
(
    id               INTEGER   NOT NULL,
    name             TEXT      NOT NULL,
    valid_at         DATE      NOT NULL,
    type             TEXT      NOT NULL,
    companies        TEXT      NOT NULL,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL
);

ALTER TABLE IF EXISTS holiday
    ADD CONSTRAINT holiday_id_pk PRIMARY KEY (id);

CREATE SEQUENCE holiday_id_seq START WITH 1 INCREMENT BY 1;

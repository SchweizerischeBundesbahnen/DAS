CREATE TABLE app_version (
    id                  INTEGER     NOT NULL,
    version             TEXT        NOT NULL,
    minimal_version     BOOLEAN     NOT NULL,
    expiry_date         DATE,
    last_modified_at    TIMESTAMP   NOT NULL,
    last_modified_by    TEXT        NOT NULL
);

ALTER TABLE IF EXISTS app_version
    ADD CONSTRAINT app_version_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS app_version
    ADD CONSTRAINT app_version_unique UNIQUE (version);

CREATE SEQUENCE app_version_id_seq START WITH 1 INCREMENT BY 1;
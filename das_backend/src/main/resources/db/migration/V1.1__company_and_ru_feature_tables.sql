CREATE TABLE IF NOT EXISTS company
(
    id             INTEGER NOT NULL,
    code_rics      TEXT    NOT NULL,
    short_name_zis TEXT
);

ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_code_rics_unique UNIQUE (code_rics);
ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_code_rics_short_name_zis_unique UNIQUE (code_rics, short_name_zis);

CREATE SEQUENCE company_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS ru_feature
(
    id               INTEGER   NOT NULL,
    company_id       INTEGER   NOT NULL,
    name             TEXT      NOT NULL,
    enabled          BOOLEAN   NOT NULL,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL
);

ALTER TABLE IF EXISTS ru_feature
    ADD CONSTRAINT ru_feature_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS ru_feature
    ADD CONSTRAINT ru_feature_company_id_fk FOREIGN KEY (company_id) REFERENCES company (id);
ALTER TABLE IF EXISTS ru_feature
    ADD CONSTRAINT ru_feature_company_id_name_unique UNIQUE (company_id, name);

CREATE SEQUENCE ru_feature_id_seq START WITH 1 INCREMENT BY 1;
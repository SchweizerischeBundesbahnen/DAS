CREATE TABLE IF NOT EXISTS ru_feature
(
    id               INTEGER   NOT NULL,
    company_code     TEXT      NOT NULL,
    name             TEXT      NOT NULL,
    enabled          BOOLEAN   NOT NULL,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL,
    PRIMARY KEY (id)
);

CREATE SEQUENCE ru_feature_seq START 1 INCREMENT 50

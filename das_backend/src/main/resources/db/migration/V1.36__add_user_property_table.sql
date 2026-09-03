CREATE TABLE user_property
(
    id               INTEGER       NOT NULL,
    oid              TEXT          NOT NULL,
    key              TEXT          NOT NULL,
    value            VARCHAR(4096) NOT NULL,
    last_modified_at TIMESTAMP     NOT NULL
);

ALTER TABLE IF EXISTS user_property
    ADD CONSTRAINT user_property_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS user_property
    ADD CONSTRAINT user_property_oid_key_unique UNIQUE (oid, key);

CREATE INDEX IF NOT EXISTS user_property_oid_idx
    ON user_property (oid);

CREATE SEQUENCE user_property_id_seq START WITH 1 INCREMENT BY 1;

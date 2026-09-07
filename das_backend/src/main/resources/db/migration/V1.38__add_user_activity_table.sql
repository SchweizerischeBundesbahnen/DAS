CREATE TABLE IF NOT EXISTS user_activity
(
    id               INTEGER                  NOT NULL,
    oid              TEXT                     NOT NULL,
    last_accessed_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE IF EXISTS user_activity
    ADD CONSTRAINT user_activity_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS user_activity
    ADD CONSTRAINT user_activity_oid_unique UNIQUE (oid);

CREATE INDEX IF NOT EXISTS user_activity_last_accessed_at_idx
    ON user_activity (last_accessed_at);

CREATE SEQUENCE IF NOT EXISTS user_activity_id_seq START WITH 1 INCREMENT BY 1;

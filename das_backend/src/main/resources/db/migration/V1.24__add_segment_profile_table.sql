CREATE TABLE preloaded_segment_profile
(
    id               TEXT       NOT NULL,
    last_seen        TIMESTAMP  NOT NULL,
    file             INTEGER       NOT NULL
);

ALTER TABLE IF EXISTS preloaded_segment_profile
    ADD CONSTRAINT preloaded_segment_profile_pk PRIMARY KEY (id);
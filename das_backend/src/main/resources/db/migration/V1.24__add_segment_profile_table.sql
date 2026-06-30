CREATE TABLE preloaded_segment_profile
(
    id               INTEGER    NOT NULL,
    sp_id_version    TEXT       NOT NULL,
    last_seen        TIMESTAMP  NOT NULL,
    file_id          INTEGER    NOT NULL
);

ALTER TABLE IF EXISTS preloaded_segment_profile
    ADD CONSTRAINT preloaded_segment_profile_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS preloaded_segment_profile
    ADD CONSTRAINT preloaded_segment_unique UNIQUE (sp_id_version);

CREATE SEQUENCE preloaded_segment_id_seq START WITH 1 INCREMENT BY 1;
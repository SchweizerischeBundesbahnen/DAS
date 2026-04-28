CREATE TABLE notice_template
(
    id               INTEGER   NOT NULL,
    category         TEXT      NOT NULL,
    title_de         TEXT,
    text_de          TEXT,
    title_fr         TEXT,
    text_fr          TEXT,
    title_it         TEXT,
    text_it          TEXT,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL
);

ALTER TABLE IF EXISTS notice_template
    ADD CONSTRAINT notice_template_id_pk PRIMARY KEY (id);

CREATE SEQUENCE notice_template_id_seq START WITH 1 INCREMENT BY 1;

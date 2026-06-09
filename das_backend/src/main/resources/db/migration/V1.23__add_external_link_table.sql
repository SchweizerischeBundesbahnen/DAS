CREATE TABLE external_link
(
    id               INTEGER   NOT NULL,
    companies        TEXT      NOT NULL,
    title_de         TEXT,
    link_de          TEXT,
    title_fr         TEXT,
    link_fr          TEXT,
    title_it         TEXT,
    link_it          TEXT,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL
);

ALTER TABLE IF EXISTS external_link
    ADD CONSTRAINT external_link_id_pk PRIMARY KEY (id);

CREATE SEQUENCE external_link_id_seq START WITH 1 INCREMENT BY 1;

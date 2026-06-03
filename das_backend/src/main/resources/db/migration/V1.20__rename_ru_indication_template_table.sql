ALTER TABLE IF EXISTS notice_template
    RENAME TO ru_indication_template;
ALTER TABLE IF EXISTS ru_indication_template
    RENAME CONSTRAINT notice_template_id_pk TO ru_indication_template_id_pk;
ALTER SEQUENCE IF EXISTS notice_template_id_seq RENAME TO ru_indication_template_id_seq;

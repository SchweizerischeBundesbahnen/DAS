ALTER SEQUENCE company_id_seq RESTART WITH 1;
ALTER SEQUENCE ru_feature_id_seq RESTART WITH 1;

INSERT INTO company(id, code_rics, short_name_zis)
VALUES (nextval('company_id_seq'), '1111', 'SHORT1'),
       (nextval('company_id_seq'), '2222', 'SHORT2');

INSERT INTO ru_feature(id, company_id, key_value, enabled, last_modified_at, last_modified_by)
VALUES (nextval('ru_feature_id_seq'), 1, 'CHECKLIST_DEPARTURE_PROCESS', TRUE, '2025-04-17 10:18:34',
        'unit_test');
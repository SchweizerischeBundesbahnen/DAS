ALTER SEQUENCE ru_feature_id_seq RESTART WITH 1;

INSERT INTO ru_feature(id, company_code, key_value, enabled, last_modified_at, last_modified_by)
VALUES (nextval('ru_feature_id_seq'), '1111', 'CHECKLIST_DEPARTURE_PROCESS', TRUE, '2025-04-17 10:18:34',
        'unit_test');

TRUNCATE TABLE app_version;
TRUNCATE TABLE company CASCADE;
TRUNCATE TABLE ru_feature;

ALTER SEQUENCE app_version_id_seq RESTART WITH 1;
ALTER SEQUENCE company_id_seq RESTART WITH 1;
ALTER SEQUENCE ru_feature_id_seq RESTART WITH 1;

INSERT INTO app_version(id, version, minimal_version, expiry_date, last_modified_at,
                        last_modified_by)
VALUES (nextval('app_version_id_seq'), '2.4.1', FALSE, '2026-12-31', '2025-04-17 10:18:34',
        'unit_test'),
       (nextval('app_version_id_seq'), '2.1.0', FALSE, null, '2025-04-03 11:12:11', 'unit_test');

INSERT INTO company(id, code_rics, short_name_zis)
VALUES (nextval('company_id_seq'), '1111', 'SHORT1'),
       (nextval('company_id_seq'), '2222', 'SHORT2');

INSERT INTO ru_feature(id, company_id, key_value, enabled, last_modified_at, last_modified_by)
VALUES (nextval('ru_feature_id_seq'), 1, 'CHECKLIST_DEPARTURE_PROCESS', TRUE, '2025-04-17 10:18:34',
        'unit_test');

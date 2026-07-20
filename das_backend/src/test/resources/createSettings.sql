TRUNCATE TABLE app_version;
TRUNCATE TABLE ru_feature;
TRUNCATE TABLE tenant CASCADE;
TRUNCATE TABLE company CASCADE;

ALTER SEQUENCE app_version_id_seq RESTART WITH 1;
ALTER SEQUENCE ru_feature_id_seq RESTART WITH 1;
ALTER SEQUENCE tenant_id_seq RESTART WITH 1;
ALTER SEQUENCE company_id_seq RESTART WITH 1;

INSERT INTO app_version(id, version, minimal_version, expiry_date, last_modified_at,
                        last_modified_by)
VALUES (nextval('app_version_id_seq'), '2.4.1', FALSE, '2026-12-31', '2025-04-17 10:18:34',
        'unit_test'),
       (nextval('app_version_id_seq'), '2.1.0', FALSE, null, '2025-04-03 11:12:11', 'unit_test');

INSERT INTO ru_feature(id, company_code, key_value, enabled, last_modified_at, last_modified_by)
VALUES (nextval('ru_feature_id_seq'), '1111', 'CHECKLIST_DEPARTURE_PROCESS', TRUE,
        '2025-04-17 10:18:34', 'unit_test');

INSERT INTO tenant(id, name, tenant_id, is_admin_role_allowed)
VALUES (nextval('tenant_id_seq'), 'sbb', '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a', TRUE),
       (nextval('tenant_id_seq'), 'unknown-tenant', '3409e798-d567-49b1-9bae-f0be66427c54', FALSE);

INSERT INTO company(id, code, short_name, tenant_id)
VALUES (nextval('company_id_seq'), '1111', 'MOCK_A',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '2222', 'MOCK_B',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '3333', 'MOCK_C',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9999', 'MOCK_OTHER',
        (SELECT id FROM tenant WHERE tenant_id = '3409e798-d567-49b1-9bae-f0be66427c54'));

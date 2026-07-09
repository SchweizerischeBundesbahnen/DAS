DELETE
FROM company;
DELETE
FROM tenant;

ALTER SEQUENCE tenant_id_seq RESTART WITH 1;
ALTER SEQUENCE company_id_seq RESTART WITH 1;

INSERT INTO tenant(id, name, tenant_id, is_admin)
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

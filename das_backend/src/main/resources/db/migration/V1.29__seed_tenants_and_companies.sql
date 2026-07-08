INSERT INTO tenant(id, name, tenant_id, is_admin_role_allowed)
VALUES (nextval('tenant_id_seq'), 'sbb', '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a', TRUE),
       (nextval('tenant_id_seq'), 'sob', 'd653d01f-17a4-48a1-9aab-b780b61b4273', FALSE),
       (nextval('tenant_id_seq'), 'bls', 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326', FALSE)
ON CONFLICT (tenant_id) DO NOTHING;

DELETE
FROM ru_feature
WHERE company_code NOT IN
      ('3356', '2263', '1163', '9013', '9043', '9048', '2185', '2585', '2385', '5184', '1285',
       '9058', '9062', '3917', '9068', '9070', '9071', '9072', '9083');

DELETE
FROM company
WHERE code NOT IN
      ('3356', '2263', '1163', '9013', '9043', '9048', '2185', '2585', '2385', '5184', '1285',
       '9058', '9062', '3917', '9068', '9070', '9071', '9072', '9083');

INSERT INTO company(id, code, short_name, tenant_id)
VALUES (nextval('company_id_seq'), '3356', 'BLSC',
        (SELECT id FROM tenant WHERE tenant_id = 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326')),
       (nextval('company_id_seq'), '2263', 'BLSI',
        (SELECT id FROM tenant WHERE tenant_id = 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326')),
       (nextval('company_id_seq'), '1163', 'BLSP',
        (SELECT id FROM tenant WHERE tenant_id = 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326')),
       (nextval('company_id_seq'), '9013', 'CJ',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9043', 'OeBB',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9048', 'RA',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '2185', 'SBBCH',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '2585', 'SBBCIN',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '2385', 'SBBD',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '5184', 'SBBI',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '1285', 'SBBP',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9058', 'SOB',
        (SELECT id FROM tenant WHERE tenant_id = 'd653d01f-17a4-48a1-9aab-b780b61b4273')),
       (nextval('company_id_seq'), '9062', 'SZU',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '3917', 'THURBO',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9068', 'TMR',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9070', 'TPF',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9071', 'TRAVYS',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9072', 'TRN',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a')),
       (nextval('company_id_seq'), '9083', 'ZB',
        (SELECT id FROM tenant WHERE tenant_id = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a'))
ON CONFLICT (code) DO UPDATE SET short_name = EXCLUDED.short_name,
                                 tenant_id  = EXCLUDED.tenant_id;

-- Fix sequence to be above the max existing ID, preventing duplicate key errors.
SELECT setval('company_id_seq', (SELECT COALESCE(MAX(id), 1) FROM company));

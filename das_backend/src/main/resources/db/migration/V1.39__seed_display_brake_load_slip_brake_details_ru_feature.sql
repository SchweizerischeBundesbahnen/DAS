-- Fix sequence to be above the max existing ID, preventing duplicate key errors.
SELECT setval('ru_feature_id_seq', (SELECT COALESCE(MAX(id), 1) FROM ru_feature));

-- Initially the brake details are only shown for BLSC (3356) and SBBI (5184).
INSERT INTO ru_feature(id, company_code, key_value, enabled, last_modified_at, last_modified_by)
VALUES (nextval('ru_feature_id_seq'), '3356', 'DISPLAY_BRAKE_LOAD_SLIP_BRAKE_DETAILS', TRUE,
        CURRENT_TIMESTAMP, 'das@sbb.ch'),
       (nextval('ru_feature_id_seq'), '5184', 'DISPLAY_BRAKE_LOAD_SLIP_BRAKE_DETAILS', TRUE,
        CURRENT_TIMESTAMP, 'das@sbb.ch')
ON CONFLICT ON CONSTRAINT ru_feature_company_code_key_value_unique DO NOTHING;

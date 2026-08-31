INSERT INTO personal_note (id, oid, key, value, last_modified_at)
VALUES (nextval('personal_note_id_seq'), 'test-oid', 'train-12345',
        '{"text": "Achtung Baustelle km 45"}', NOW());

INSERT INTO personal_note (id, oid, key, value, last_modified_at)
VALUES (nextval('personal_note_id_seq'), 'test-oid', 'bp-67890', '{"text": "Text"}', NOW());

INSERT INTO personal_note (id, oid, key, value, last_modified_at)
VALUES (nextval('personal_note_id_seq'), 'other-oid', 'train-12345', '{"text": "Other users note"}',
        NOW());

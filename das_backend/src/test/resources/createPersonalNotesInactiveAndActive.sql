INSERT INTO personal_note (id, oid, key, value, last_modified_at)
VALUES (nextval('personal_note_id_seq'), '11111111-1111-1111-1111-111111111111', 'note-key',
        '{"text": "old"}', NOW());

INSERT INTO personal_note (id, oid, key, value, last_modified_at)
VALUES (nextval('personal_note_id_seq'), '22222222-2222-2222-2222-222222222222', 'note-key',
        '{"text": "fresh"}', NOW());

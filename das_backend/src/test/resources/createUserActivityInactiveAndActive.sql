INSERT INTO user_activity (id, oid, last_accessed_at)
VALUES (nextval('user_activity_id_seq'), '11111111-1111-1111-1111-111111111111',
        NOW() - INTERVAL '400 days');

INSERT INTO user_activity (id, oid, last_accessed_at)
VALUES (nextval('user_activity_id_seq'), '22222222-2222-2222-2222-222222222222', NOW());

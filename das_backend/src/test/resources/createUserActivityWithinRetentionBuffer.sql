INSERT INTO user_activity (id, oid, last_accessed_at)
VALUES (nextval('user_activity_id_seq'), '33333333-3333-3333-3333-333333333333',
        NOW() - INTERVAL '182 days');

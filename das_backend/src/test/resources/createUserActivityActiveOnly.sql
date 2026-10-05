INSERT INTO user_activity (id, oid, last_accessed_on)
VALUES (nextval('user_activity_id_seq'), '22222222-2222-2222-2222-222222222222',
        CURRENT_DATE - 1);

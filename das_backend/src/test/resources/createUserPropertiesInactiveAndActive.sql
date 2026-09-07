INSERT INTO user_property (id, oid, key, value, last_modified_at)
VALUES (nextval('user_property_id_seq'), '11111111-1111-1111-1111-111111111111', 'prop-key',
        '"old"', NOW());

INSERT INTO user_property (id, oid, key, value, last_modified_at)
VALUES (nextval('user_property_id_seq'), '22222222-2222-2222-2222-222222222222', 'prop-key',
        '"fresh"', NOW());

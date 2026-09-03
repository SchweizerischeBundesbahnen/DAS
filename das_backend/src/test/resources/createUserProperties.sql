INSERT INTO user_property (id, oid, key, value, last_modified_at)
VALUES (nextval('user_property_id_seq'), 'test-oid', 'tourSystem', '"tour1"', NOW());

INSERT INTO user_property (id, oid, key, value, last_modified_at)
VALUES (nextval('user_property_id_seq'), 'test-oid', 'companyCodes', '["2185", "3356"]', NOW());

INSERT INTO user_property (id, oid, key, value, last_modified_at)
VALUES (nextval('user_property_id_seq'), 'other-oid', 'tourSystem', '"tour2"', NOW());

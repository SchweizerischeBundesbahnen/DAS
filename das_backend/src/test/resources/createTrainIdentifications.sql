DELETE
FROM train_identification;

INSERT INTO train_identification (id, train_path_id, period, operational_train_number,
                                  start_date_time, companies, operational_day)
VALUES (nextval('train_identification_id_seq'), '728-1', 2025, '728', now() + INTERVAL '1 hour',
        'MOCK_A,MOCK_B', CURRENT_DATE),
       (nextval('train_identification_id_seq'), '728-2', 2025, '728', now() + INTERVAL '6 hours',
        'MOCK_C', CURRENT_DATE),
       (nextval('train_identification_id_seq'), '999-3', 2025, '999', now() + INTERVAL '2 hours',
        'MOCK_A', CURRENT_DATE),
       (nextval('train_identification_id_seq'), '555-1', 2025, '555', now() + INTERVAL '3 hours',
        'MOCK_A,NOT_IN_DB', CURRENT_DATE);

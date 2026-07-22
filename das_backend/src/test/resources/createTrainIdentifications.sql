DELETE
FROM train_identification;

INSERT INTO train_identification (id, train_path_id, period, operational_train_number,
                                  start_date_time, companies, operational_day)
VALUES (nextval('train_identification_id_seq'), '728-1', 2025, '728',
        (CURRENT_DATE + INTERVAL '8 hours 30 minutes') AT TIME ZONE 'Europe/Zurich',
        'MOCK_A,MOCK_B', CURRENT_DATE),
       (nextval('train_identification_id_seq'), '728-2', 2025, '728',
        (CURRENT_DATE + INTERVAL '1 day 8 hours 30 minutes') AT TIME ZONE 'Europe/Zurich',
        'MOCK_C', CURRENT_DATE + 1),
       (nextval('train_identification_id_seq'), '999-3', 2025, '999',
        (CURRENT_DATE + INTERVAL '10 hours') AT TIME ZONE 'Europe/Zurich',
        'MOCK_A', CURRENT_DATE),
       (nextval('train_identification_id_seq'), '555-1', 2025, '555',
        (CURRENT_DATE + INTERVAL '12 hours') AT TIME ZONE 'Europe/Zurich',
        'MOCK_A,NOT_IN_DB', CURRENT_DATE);
